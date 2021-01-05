//
//  GMAppleMusicPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation
import MediaPlayer

class GMAppleMusicPlayer: ObservableObject, Playable {
    @Published var queue: GMAppleMusicQueue
    @Published var state: State = State()
    private let socketManager: GMSockets
    private let notificationCenter: NotificationCenter
    private let appleMusicManager: GMAppleMusic // TODO: Remove this dependancy. It is only for testing
    let player: MPMusicPlayerApplicationController
    
    init(musicPlayer: MPMusicPlayerApplicationController = MPMusicPlayerApplicationController.applicationQueuePlayer,
         socketManager: GMSockets = GMSockets.sharedInstance,
         notificationCenter: NotificationCenter = .default,
         queue: GMAppleMusicQueue = GMAppleMusicQueue.sharedInstance,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.player = musicPlayer
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.queue = queue
        self.appleMusicManager = appleMusicManager
        self.fillQueueWithTestItems()
        
        self.setupQueueStateUpdateHandler()
        self.setupNotificationCenterObservers()
    }
    
    static let sharedInstance = GMAppleMusicPlayer()
    
    private func fillQueueWithTestItems() {
        self.appleMusicManager.search(term: "Young Thug", limit: 10) { (results: SearchResults?, error: Error?) in
            if let error = error {
                print("ERROR: Could not retrive search results: \(error)")
                return
            }
            guard let results = results else {
                print("ERROR: Could not retrive search results")
                return
            }
            if let songs = results.songs?.data {
                print("WE HAVE SONG DATA:")
                print(songs)
                DispatchQueue.main.async {
                    self.queue.append(tracks: songs)
                    self.player.setQueue(with: songs.map({ (song) -> String in
                        song.id
                    })) // TODO: Come up with a better way to keep the queues in sync
                }
            }
        }

    }
    
    public func playAllSongs() {
        self.player.setQueue(with: .songs())
        self.player.play()
    }
    
    // MARK: Playback Controls
    /// Starts playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func play(shouldEmitEvent: Bool = true) {
        self.player.play()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPlayEvent() }
        } catch {
            fatalError(error.localizedDescription)
            // TODO: Should revert to previous state in case of error (do this for all the events)
        }
    }
    
    /// Pauses playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func pause(shouldEmitEvent: Bool = true) {
        self.player.pause()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPauseEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    /// Starts playback of the next media item in the playback queue; or, the music player is not playing, designates the next media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToNextItem(shouldEmitEvent: Bool = true) {
        self.player.skipToNextItem()
        self.queue.skipToNextItem()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitForwardEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Starts playback of the previous media item in the playback queue; or, the music player is not playing, designates the previous media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToBeginning(shouldEmitEvent: Bool = true) {
        self.player.skipToBeginning()
        do {
            // TODO: Need to setup event to emit
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    /// Starts playback of the previous media item in the playback queue; or, the music player is not playing, designates the previous media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToPreviousItem(shouldEmitEvent: Bool = true) {
        self.player.skipToPreviousItem()
        self.queue.skipToPreviousItem()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPreviousEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: Notification Center
    
    private func setupNotificationCenterObservers() {
        self.notificationCenter.addObserver(self,
                                            selector: #selector(self.playbackStateDidChange),
                                            name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                            object: nil)
        
        self.player.beginGeneratingPlaybackNotifications()
        
        self.notificationCenter.addObserver(self,
                                            selector: #selector(stateUpdateRequested),
                                            name: .stateUpdateRequested,
                                            object: nil)
        
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePlayEvent),
                                            name: .playEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePauseEvent),
                                            name: .pauseEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecieveForwardEvent),
                                            name: .forwardEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePreviousEvent),
                                            name: .previousEvent,
                                            object: nil)
    }
    
    @objc private func stateUpdateRequested() {
        self.socketManager.updateQueuePlayerState(with: self.state)
    }
    
    @objc private func playbackStateDidChange() {
        self.state.playbackState = player.playbackState
    }
    
    @objc private func didRecievePlayEvent() {
        self.play(shouldEmitEvent: false)
    }

    @objc private func didRecievePauseEvent() {
        self.pause(shouldEmitEvent: false)
    }

    @objc private func didRecieveForwardEvent() {
        self.skipToNextItem(shouldEmitEvent: false)
    }

    @objc private func didRecievePreviousEvent() {
        self.skipToPreviousItem(shouldEmitEvent: false)
    }
    
    // MARK: State Update Handler
    private func setupQueueStateUpdateHandler() {
        self.queue.updateHandler = { newState in
            self.state.queueState = newState
        }
        self.queue.triggerUpdateHandler()
    }
}

extension GMAppleMusicPlayer {
    struct State: Codable {
        var playbackState: MPMusicPlaybackState = .stopped
        var queueState: GMAppleMusicQueue.State?
        var playbackPosition: TimeInterval = 0.0
    }
}
