//
//  BackgroundAudio.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-25.
//

import Foundation
import AVFoundation
import UIKit

class BackgroundAudio {
    private let audioURL = Bundle.main.url(forResource: "sample-1", withExtension: "mp3")!
    private var player: AVAudioPlayer? = nil
    private let notificationCenter: NotificationCenter
    
    init(notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
        self.start()
        
        self.notificationCenter.addObserver(self, selector: #selector(self.setToPlayback), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    public func start() {
        do {
            try self.player = AVAudioPlayer(contentsOf: self.audioURL)
            self.player!.rate = 1.0
            self.player!.numberOfLoops = -1
            
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            
            print("Starting background audio")
            self.player!.play()
            self.setTimeout()
        } catch {
            print("ERROR \(error.localizedDescription)")
        }
    }
    
    public func stop() {
        print("Stopping background audio")
        self.player?.stop()
    }
    
    private func setTimeout() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer: Timer) in
            self.stop()
        }
    }
    
    @objc func setToPlayback() {
        do {
            self.start()
            try AVAudioSession.sharedInstance().setCategory(.playback)
            print("Set category to playback")
        } catch {
            print("ERROR \(error.localizedDescription)")
        }
    }
}
