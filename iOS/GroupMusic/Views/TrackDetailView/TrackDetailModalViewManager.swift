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
    
    func open(withTrack track: Track) {
        self.track = track
        self.isOpen = true
    }
    
    func close() {
        self.isOpen = false
    }
}
