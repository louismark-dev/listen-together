//
//  GMAppleMusicQueue.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation

class GMAppleMusicQueue: ObservableObject {
    @Published public var queue: [Track]
    public var indexOfNowPlayingItem: Int
    public var nowPlayingItem: Track {
        return queue[indexOfNowPlayingItem]
    }
    
    init() {
        self.queue = []
        self.indexOfNowPlayingItem = 0
    }
    
    init(withQueue queue: [Track]) {
        self.queue = queue
        self.indexOfNowPlayingItem = 0
    }
    
    static let sharedInstance = GMAppleMusicQueue()
    
    // MARK: Queue Mangagement
    
    /// Inserts the media item  after the last media item in the current queue.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func append(track: Track) {
        self.queue.append(track)
    }
    
    public func append(tracks: [Track]) {
        self.queue.append(contentsOf: tracks)
    }
    
    /// Inserts the media item defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func prepend(track: Track) {
        self.queue.insert(track, at: self.indexOfNowPlayingItem)
    }
    
    /// Inserts the media items defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func prepend(tracks: [Track]) {
        self.queue.insert(contentsOf: tracks, at: self.indexOfNowPlayingItem)
    }
    
    // MARK: Play State Management
    
    /// Marks the currently playing item as the next media item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToNextItem() {
        let nextIndex = self.indexOfNowPlayingItem + 1
        if queue.indices.contains(nextIndex) {
            self.indexOfNowPlayingItem = nextIndex
        }
    }
    
    /// Marks the previously playing item as the current item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToPreviousItem() {
        let previousIndex = self.indexOfNowPlayingItem - 1
        if queue.indices.contains(previousIndex) {
            self.indexOfNowPlayingItem = previousIndex
        }
    }
}
