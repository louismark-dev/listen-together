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
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(withPlayerAdapter playerAdapter: PlayerAdapter) {
        self.playerAdapter = playerAdapter
        
        self.subscribeToQueueStatePublisher()
    }
    
    public func open(with track: Track?) {
        self.track = track
        self.isOpen = true
        
        self.trackPlaybackStatus = self.generateTrackPlaybackStatus()
    }
    
    private func subscribeToQueueStatePublisher() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .removeDuplicates(by: { previousState, nextState in
                (previousState.queue.state.indexOfNowPlayingItem == nextState.queue.state.indexOfNowPlayingItem)
            })
            .sink { _ in
                self.trackPlaybackStatus = self.generateTrackPlaybackStatus()
            }
            .store(in: &cancellables)
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
