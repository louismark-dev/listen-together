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
    let playbackTimer: PlaybackTimer
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         notificationCenter: NotificationCenter = .default,
         playbackTimer: PlaybackTimer = PlaybackTimer()) {
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
        self.playbackTimer = playbackTimer
        self.setupPlaybackTimer()
        self.setupNotificationCenterObservers()
    }
    
    private func setupPlaybackTimer() {
        self.playbackTimer.onPlaybackTimeUpdate = { (newPlaybackTime: TimeInterval) in
            self.state.playbackPosition.currentPlaybackTime = newPlaybackTime
        }
    }
    
    func updateState(with state: GMAppleMusicHostController.State) {
        self.state = state
        if (self.state.playbackState == .playing) {
            self.playbackTimer.didPlay()
        }
    }
    
    // MARK: Playback Controls
    
    func play(completion: (() -> Void)?) {
        self.state.playbackState = .playing
        if let completion = completion {
            completion()
        }
        self.playbackTimer.didPlay()
    }
    
    func pause(completion: (() -> Void)?) {
        self.state.playbackState = .paused
        if let completion = completion {
            completion()
        }
        self.playbackTimer.didPause()
    }
    
    func skipToNextItem(completion: (() -> Void)?) {
        self.state.queue.skipToNextItem()
        if let completion = completion {
            completion()
        }
        self.playbackTimer.didSkip()
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
        self.playbackTimer.didSkip()
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
