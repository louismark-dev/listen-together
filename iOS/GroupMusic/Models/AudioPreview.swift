//
//  AudioPreview.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-01.
//

import AVFoundation

class AudioPreview: ObservableObject {
    private var audioPlayer: AVPlayer?
    private var audioStreamURL: URL?
    private var timer: Timer?
    @Published var ready: Bool = false // Indicates if ready to play
    @Published var playbackStatus: PlaybackStatus = .stopped
    @Published var playbackPosition: PlaybackPosition = PlaybackPosition()
    
    public func setAudioStreamURL(audioStreamURL: String) {
        self.audioStreamURL = URL(string: audioStreamURL)!
        self.audioPlayer = AVPlayer(url: self.audioStreamURL!)
        self.ready = true
    }
    
    public func play() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.play()
        self.playbackStatus = .playing
        
        self.startTimer()
    }
    
    public func stop() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.seek(to: .zero)
        audioPlayer.pause()
        self.playbackStatus = .stopped
        
        self.resetTimer()
    }
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer: Timer) in
            if let duration = self.audioPlayer?.currentItem?.duration,
               let currentTime = self.audioPlayer?.currentTime() {
                self.playbackPosition.playbackDuration = CMTimeGetSeconds(duration)
                self.playbackPosition.currentPlaybackTime = CMTimeGetSeconds(currentTime)
            }
            
            if (self.playbackPosition.playbackFraction >= 1.0) {
                try? self.stop()
            }
        }
    }
    
    private func resetTimer() {
        self.timer?.invalidate()
        self.playbackPosition.currentPlaybackTime = 0.0
    }
    
    enum AudioPreviewError: Error {
        case streamURLNotSet
    }
    
    enum PlaybackStatus {
        case playing
        case stopped
    }
}
