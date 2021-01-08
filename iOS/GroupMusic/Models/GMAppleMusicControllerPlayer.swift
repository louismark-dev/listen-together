//
//  GMObserverPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation

class GMAppleMusicControllerPlayer: ObservableObject, Playable {
    @Published var queue: GMAppleMusicQueue
    @Published var state: GMAppleMusicPlayer.State = GMAppleMusicPlayer.State()
    private let socketManager: GMSockets
    private let notificationCenter: NotificationCenter
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         queue: GMAppleMusicQueue = GMAppleMusicQueue.sharedInstance,
         notificationCenter: NotificationCenter = .default) {
        self.queue = queue
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.setupQueueStateUpdateHandler()
    }
    
    static let sharedInstance = GMAppleMusicControllerPlayer()
    
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
    private func setupNotificationCenterObservers() {
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
        self.queue.updateHandler = { newState, event in
            self.state.queueState = newState
        }
        self.queue.triggerUpdateHandler(withEvent: .none)
    }
    
}
