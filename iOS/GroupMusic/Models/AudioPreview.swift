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
    @Published var ready: Bool = false // Indicates if ready to play
    @Published var playbackStatus: PlaybackStatus = .stopped
    
    public func setAudioStreamURL(audioStreamURL: String) {
        self.audioStreamURL = URL(string: audioStreamURL)!
        self.audioPlayer = AVPlayer(url: self.audioStreamURL!)
        self.ready = true
    }
    
    public func play() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.play()
        self.playbackStatus = .playing
    }
    
    public func stop() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.seek(to: .zero)
        audioPlayer.pause()
        self.playbackStatus = .stopped
    }
    
    enum AudioPreviewError: Error {
        case streamURLNotSet
    }
    
    enum PlaybackStatus {
        case playing
        case stopped
    }
}
