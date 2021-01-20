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
    
    func play(completion: (() -> Void)?) {
        self.state.playbackState = .playing
        if let completion = completion {
            completion()
        }
    }
    
    func pause(completion: (() -> Void)?) {
        self.state.playbackState = .paused
        if let completion = completion {
            completion()
        }
    }
    
    func skipToNextItem(completion: (() -> Void)?) {
        self.state.queue.skipToNextItem()
        if let completion = completion {
            completion()
        }
    }
    
    func skipToBeginning(completion: (() -> Void)?) {
        // TODO: Adjust playback time
        // TODO: Emit event
    }
    
    func skipToPreviousItem(completion: (() -> Void)?) {
        self.state.queue.skipToPreviousItem()
        if let completion = completion {
            completion()
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
