//
//  GMObserverPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation
import Combine

class GMAppleMusicController: ObservableObject, PlayerProtocol {
        
    @Published var state: GMAppleMusicPlayer.State = GMAppleMusicPlayer.State()
    var statePublisher: Published<GMAppleMusicPlayer.State>.Publisher { $state }
    
    let socketManager: GMSockets
    let notificationCenter: NotificationCenter
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         notificationCenter: NotificationCenter = .default) {
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.setupNotificationCenterObservers()
    }
    
    func updateState(with state: GMAppleMusicPlayer.State) {
        self.state = state
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
        self.state.queue.skipToNextItem()
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
        self.state.queue.skipToPreviousItem()
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
        self.state.queue.append(tracks: tracks)
        print(self.state.queue.state.queue)
    }
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.state.queue.prepend(tracks: tracks)
        print(self.state.queue.state.queue)
    }
    
}
