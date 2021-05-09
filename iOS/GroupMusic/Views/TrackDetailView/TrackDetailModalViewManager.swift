//
//  TrackDetailModalViewManager.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import Foundation

class TrackDetailModalViewManager: ObservableObject {
    @Published var isOpen: Bool = false
    @Published var track: Track?
    @Published var trackIsInQueue: Bool = false
    var audioPreviewPlayer: AudioPreview = AudioPreview()
    
    public func open(withTrack track: Track, trackIsInQueue: Bool) {
        self.track = track
        self.trackIsInQueue = trackIsInQueue
        self.isOpen = true
        
        if let previewURL = self.track?.attributes?.previews.first?.url {
            self.audioPreviewPlayer.setAudioStreamURL(audioStreamURL: previewURL)
        }
    }
    
    public func close() {
        self.isOpen = false
        
        try? self.audioPreviewPlayer.stop()
    }
}
