//
//  TrackDetailModalViewModel.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-25.
//

import Foundation
import Combine

class TrackDetailModalViewModel: ObservableObject {
    let playerAdapter: PlayerAdapter
    /// The track to be dispplayed by the TrackDetailModalView
    @Published var track: Track?
    @Published var trackPlaybackStatus: PlaybackStatus = .notInQueue
    /// Set to true to open the TrackDetailModalView
    @Published var isOpen: Bool = false
    
    init(withPlayerAdapter playerAdapter: PlayerAdapter) {
        self.playerAdapter = playerAdapter
    }
    
    public func open(with track: Track?) {
        self.track = track
        self.isOpen = true
        
        self.trackPlaybackStatus = self.generateTrackPlaybackStatus()
    }
    
    private func generateTrackPlaybackStatus() -> PlaybackStatus {
        let indexOfNowPlaying = self.playerAdapter.state.queue.state.indexOfNowPlayingItem
        guard let track = self.track,
              let trackIndex = self.playerAdapter.state.queue.state.queue.firstIndex(of: track) else {
            return .notInQueue
        }
        
        if (trackIndex < indexOfNowPlaying) {
            return .played
        } else if (trackIndex == indexOfNowPlaying) {
            return .nowPlaying
        } else if (trackIndex > indexOfNowPlaying){
            return .inQueue
        } else {
            return .notInQueue
        }
    }
    
    enum PlaybackStatus: Equatable {
        case played
        case nowPlaying
        case inQueue
        case notInQueue
    }
}
