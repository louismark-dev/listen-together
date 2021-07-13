//
//  BackgroundAudio.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-25.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer

class BackgroundAudio {
    private let audioURL = Bundle.main.url(forResource: "15-sec", withExtension: "mp3")!
    private var player: AVAudioPlayer? = nil
    private let notificationCenter: NotificationCenter
    private var musicPlayerApplicationController: MPMusicPlayerApplicationController
    private var musicIsPlaying: Bool = false
    private var timeoutTimer: Timer? = nil
    
    init(notificationCenter: NotificationCenter = NotificationCenter.default,
         musicPlayerApplicationController: MPMusicPlayerApplicationController) {
        self.notificationCenter = notificationCenter
        self.musicPlayerApplicationController = musicPlayerApplicationController
        
        self.setupNotificationCentreObservers()
        
        self.start()
    }
    
    @objc func playbackStateDidChange() {
        if (musicPlayerApplicationController.playbackState == .playing) {
            self.musicIsPlaying = true
            self.invalidateTimer()
            self.start()
        } else {
            self.musicIsPlaying = false
            if (UIApplication.shared.applicationState == .background) {
                self.setTimeout()
            }
        }
    }
        
    private func start() {
        do {
            try self.player = AVAudioPlayer(contentsOf: self.audioURL)
            self.player!.rate = 1.0
            self.player!.numberOfLoops = -1
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers])
            
            print("Starting background audio")
            self.player!.play()
        } catch {
            print("ERROR starting background audio: \(error.localizedDescription)")
        }
    }
    
    public func stop() {
        print("Stopping background audio")
        self.player?.stop()
    }
    
    /// Call this when the application goes to background to trigger timeout
    private func setTimeout() {
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = nil
        
        if (self.timeoutTimer == nil) {
            self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 3 * 60, repeats: false) { (timer: Timer) in
                self.stop()
            }
            print("Timeout set")
        }
    }
    
    private func invalidateTimer() {
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = nil
    }
    
    @objc private func applicationWillEnterBackground() {
        if (self.musicIsPlaying == false) {
            self.setTimeout()
        }
    }
    
    private func setupNotificationCentreObservers() {
        self.notificationCenter.addObserver(self,
                                            selector: #selector(self.applicationWillEnterBackground),
                                            name: UIApplication.willResignActiveNotification,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(self.playbackStateDidChange),
                                            name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                            object: nil)
    }
}
