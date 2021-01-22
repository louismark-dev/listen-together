//
//  GMAppleMusicPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation
import MediaPlayer
import Combine

class GMAppleMusicPlayer: ObservableObject, PlayerProtocol {
    @Published var state: State = State()
    var statePublisher: Published<GMAppleMusicPlayer.State>.Publisher { $state }
    
    let socketManager: GMSockets
    let notificationCenter: NotificationCenter
    private let appleMusicManager: GMAppleMusic // TODO: Remove this dependancy. It is only for testing
    let player: MPMusicPlayerApplicationController
        
    init(musicPlayer: MPMusicPlayerApplicationController = MPMusicPlayerApplicationController.applicationQueuePlayer,
         socketManager: GMSockets = GMSockets.sharedInstance,
         notificationCenter: NotificationCenter = .default,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.player = musicPlayer
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.appleMusicManager = appleMusicManager
        self.fillQueueWithTestItems()
        
        self.setupNotificationCenterObservers()
    }
        
    private func fillQueueWithTestItems() {
        self.appleMusicManager.search(term: "Beyonce", limit: 25) { (results: SearchResults?, error: Error?) in
            if let error = error {
                print("ERROR: Could not retrive search results: \(error)")
                return
            }
            guard let results = results else {
                print("ERROR: Could not retrive search results")
                return
            }
            if let songs = results.songs?.data {
                DispatchQueue.main.async {
                    self.state.queue.append(tracks: songs)
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
    
    func updateState(with state: State) {
        self.state = state
    }
    
    // MARK: Playback Controls
    /// Starts playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func play(completion: (() -> Void)?) {
        self.player.play()
        if let completion = completion {
            completion()
        }
    }
    
    /// Pauses playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func pause(completion: (() -> Void)?) {
        self.player.pause()
        if let completion = completion {
            completion()
        }
        
    }
    
    /// Starts playback of the next media item in the playback queue; or, the music player is not playing, designates the next media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToNextItem(completion: (() -> Void)?) {
        self.player.skipToNextItem()
        self.state.queue.skipToNextItem()
        if let completion = completion {
            completion()
        }
    }
    
    /// Starts playback of the previous media item in the playback queue; or, the music player is not playing, designates the previous media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToBeginning(completion: (() -> Void)?) {
        self.player.skipToBeginning()
        if let completion = completion {
            completion()
        }
    }
    
    
    /// Starts playback of the previous media item in the playback queue; or, the music player is not playing, designates the previous media item as the next to be played.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToPreviousItem(completion: (() -> Void)?) {
        self.player.skipToPreviousItem()
        self.state.queue.skipToPreviousItem()
        if let completion = completion {
            completion()
        }
    }
    
    // MARK: Notification Center
    
    func setupNotificationCenterObservers() {
        self.notificationCenter.addObserver(self,
                                            selector: #selector(self.playbackStateDidChange),
                                            name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                            object: nil)
        
        self.player.beginGeneratingPlaybackNotifications()
        
        // Notifications originating from GMSockets
        self.notificationCenter.addObserver(self,
                                            selector: #selector(stateUpdateRequested),
                                            name: .stateUpdateRequested,
                                            object: nil)
    }
    
    @objc private func stateUpdateRequested() {
        self.socketManager.updateQueuePlayerState(with: self.state)
    }
    
    @objc private func playbackStateDidChange() {
        self.state.playbackState = player.playbackState
    }
    
    // MARK: Queue Operations
    
    /// Appends track to the song queue
    /// - Parameters:
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.appendToMPMusicPlayerQueue(withTracks: tracks, completion: completion)
    }
    
    /// Prepends track to the song queue
    /// - Parameters:
    public func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.prependToMPMusicPlayerQueue(withTracks: tracks, completion: completion)
    }
    
    private func appendToMPMusicPlayerQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.perform { (queue: MPMusicPlayerControllerMutableQueue) in
            let storeIDs = tracks.map({ (song) -> String in
                song.id
            })
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
            let lastItem = queue.items.last
            queue.insert(descriptor, after: lastItem)
        } completionHandler: { (newQueue: MPMusicPlayerControllerQueue, error) in
            if let error = error {
                print(error)
                return
            }
            do {
                try self.state.queue.setQueueTo(mpMediaItems: newQueue.items, withNewTracks: tracks)
                if (completion != nil) {
                    completion!()
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func prependToMPMusicPlayerQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.perform { (queue: MPMusicPlayerControllerMutableQueue) in
            let storeIDs = tracks.map({ (song) -> String in
                song.id
            })
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
            let indexOfNowPlayingItem = self.state.queue.state.indexOfNowPlayingItem
            let currentItem = queue.items[indexOfNowPlayingItem]
            queue.insert(descriptor, after: currentItem)
        } completionHandler: { (newQueue: MPMusicPlayerControllerQueue, error) in
            if let error = error {
                print(error)
                return
            }
            do {
                try self.state.queue.setQueueTo(mpMediaItems: newQueue.items, withNewTracks: tracks)
                if (completion != nil) {
                    completion!()
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func emitAppendToQueueEvent(withTracks tracks: [Track]) throws {
        try self.socketManager.emitAppendToQueueEvent(withTracks: tracks)
    }
    
    private func emitPrependToQueueEvent(withTracks tracks: [Track]) throws {
        try self.socketManager.emitPrependToQueueEvent(withTracks: tracks)
    }
}

extension GMAppleMusicPlayer {
    struct State: Codable {
        var playbackState: MPMusicPlaybackState = .stopped
        var playbackPosition: TimeInterval = 0.0
        var queue: GMAppleMusicQueue = GMAppleMusicQueue()
    }
}
