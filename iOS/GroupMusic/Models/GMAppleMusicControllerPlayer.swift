//
//  GMObserverPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation
import Combine

class GMAppleMusicControllerPlayer: ObservableObject, PlayerProtocol {
    
    @Published var queue: GMAppleMusicQueue
    var queuePublisher: Published<GMAppleMusicQueue>.Publisher { $queue }
    
    @Published var state: GMAppleMusicPlayer.State = GMAppleMusicPlayer.State()
    var statePublisher: Published<GMAppleMusicPlayer.State>.Publisher { $state }
    
    let socketManager: GMSockets
    let notificationCenter: NotificationCenter
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         queue: GMAppleMusicQueue = GMAppleMusicQueue(),
         notificationCenter: NotificationCenter = .default) {
        self.queue = queue
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.setupNotificationCenterObservers()
    }
    
    static let sharedInstance = GMAppleMusicControllerPlayer()
    
    private var cancellables: Set<AnyCancellable> = []
    
    /**
     Updates GMAppleMusicPlayer's state whenever GMAppleMusicQueue.state is updated.
     */
    private func subscribeToQueuePublisher() {
        self.queue.$state
            .receive(on: RunLoop.main)
            .sink { (newQueueState) in
                self.state.queueState = newQueueState
            }.store(in: &cancellables)
    }
    
    // MARK: Playback Controls
    
    func play(shouldEmitEvent: Bool  = true) {
        self.state.playbackState = .playing
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPlayEvent() }
        } catch {
            fatalError(error.localizedDescription)
            // TODO: Should revert to previous state in case of error (do this for all the events)
        }
    }
    
    func pause(shouldEmitEvent: Bool = true) {
        self.state.playbackState = .paused
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPauseEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func skipToNextItem(shouldEmitEvent: Bool = true) {
        self.queue.skipToNextItem()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitForwardEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func skipToBeginning(shouldEmitEvent: Bool = true) {
        // TODO: Adjust playback time
        // TODO: Emit event
    }
    
    func skipToPreviousItem(shouldEmitEvent: Bool = true) {
        self.queue.skipToPreviousItem()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPreviousEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: Notification Center
    func setupNotificationCenterObservers() {
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
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecieveAppendToQueueEvent),
                                            name: .appendToQueueEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePrependToQueueEvent),
                                            name: .prependToQueueEvent,
                                            object: nil)
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
    
    @objc private func didRecieveAppendToQueueEvent(_ notification: Notification) {
        let tracks = notification.object as! [Track]
        print(tracks)
        self.queue.append(tracks: tracks)
        print(self.queue.state.queue)
    }

    @objc private func didRecievePrependToQueueEvent(_ notification: Notification) {
        let tracks = notification.object as! [Track]
        print(tracks)
        self.prependToQueue(withTracks: tracks, completion: nil)
    }
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.queue.prepend(tracks: tracks)
        print(self.queue.state.queue)
    }
    
}
