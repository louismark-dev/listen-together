//
//  GMObserverPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation
import Combine

class GMAppleMusicControllerPlayer: ObservableObject, PlayerProtocol {
    
    private var queue: GMAppleMusicQueue
    
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
        
    }
    
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.queue.append(tracks: tracks)
        print(self.queue.state.queue)
    }
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.queue.prepend(tracks: tracks)
        print(self.queue.state.queue)
    }
    
}
