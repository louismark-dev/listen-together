//
//  TrackDetailModalViewModel.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-25.
//

import Combine

class TrackDetailModalViewModel: ObservableObject {
    /// The track to be dispplayed by the TrackDetailModalView
    @Published var track: Track?
    /// Set to true to open the TrackDetailModalView
    @Published var isOpen: Bool = false
    
    public func open(with track: Track?) {
        self.track = track
        self.isOpen = true
    }
}
