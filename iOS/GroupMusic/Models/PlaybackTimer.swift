//
//  PlaybackTimer.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-25.
//

import Foundation

class PlaybackTimer {
    private var timer: Timer?
    private let interval = 0.25
    private var currentPlaybackTime: TimeInterval = 0.0
    public var onPlaybackTimeUpdate: ((TimeInterval) -> Void)? = nil
    
    private func runTimer() {
        if (self.timer == nil) { // Only set new timer if the existing timer is nil
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer: Timer) in
                self.currentPlaybackTime = self.currentPlaybackTime + self.interval
                self.onPlaybackTimeUpdate?(self.currentPlaybackTime)
            }
        }
    }
    
    public func didPlay() {
        self.runTimer()
    }
    
    public func didPause() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public func didSkip() {
        self.currentPlaybackTime = 0.0
        self.runTimer()
    }
    
    public func setPlaybackTime(to timeInterval: TimeInterval) {
        self.currentPlaybackTime = timeInterval
    }
}
