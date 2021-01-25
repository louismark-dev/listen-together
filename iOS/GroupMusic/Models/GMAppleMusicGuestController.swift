//
//  GMObserverPlayer.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation
import Combine

class GMAppleMusicGuestController: ObservableObject, PlayerProtocol {
        
    @Published var state: GMAppleMusicHostController.State = GMAppleMusicHostController.State()
    var statePublisher: Published<GMAppleMusicHostController.State>.Publisher { $state }
    
    let socketManager: GMSockets
    let notificationCenter: NotificationCenter
    var playbackProgressTimer: Timer?
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         notificationCenter: NotificationCenter = .default) {
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.setupNotificationCenterObservers()
    }
    
    func startPlaybackProgressTimer() {
        let interval = 0.25
        if (self.playbackProgressTimer == nil) { // Only set new timer if the existing timer is nil
            self.playbackProgressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer: Timer) in
                self.state.playbackPosition.currentPlaybackTime = self.state.playbackPosition.currentPlaybackTime + interval
            }
        }
    }
    
    func updateState(with state: GMAppleMusicHostController.State) {
        self.state = state
        if (self.state.playbackState == .playing) {
            self.startPlaybackProgressTimer()
        }
    }
    
    // MARK: Playback Controls
    
    func play(completion: (() -> Void)?) {
        self.state.playbackState = .playing
        if let completion = completion {
            completion()
        }
        self.startPlaybackProgressTimer()
    }
    
    func pause(completion: (() -> Void)?) {
        self.state.playbackState = .paused
        if let completion = completion {
            completion()
        }
        self.playbackProgressTimer?.invalidate()
        self.playbackProgressTimer = nil
    }
    
    func skipToNextItem(completion: (() -> Void)?) {
        self.state.queue.skipToNextItem()
        if let completion = completion {
            completion()
        }
        self.state.playbackPosition.currentPlaybackTime = 0
        self.startPlaybackProgressTimer()
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
        self.state.playbackPosition.currentPlaybackTime = 0
        self.startPlaybackProgressTimer()
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
