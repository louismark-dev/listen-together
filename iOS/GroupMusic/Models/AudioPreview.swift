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
    
    public func setAudioStreamURL(audioStreamURL: String) {
        self.audioStreamURL = URL(string: audioStreamURL)!
        self.audioPlayer = AVPlayer(url: self.audioStreamURL!)
        self.ready = true
    }
    
    public func play() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.play()
    }
    
    public func pause() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.pause()
    }
    
    public func restartPlayback() throws {
        guard let audioPlayer = self.audioPlayer else { throw AudioPreviewError.streamURLNotSet }
        audioPlayer.seek(to: .zero)
        audioPlayer.play()
    }
    
    enum AudioPreviewError: Error {
        case streamURLNotSet
    }
}
