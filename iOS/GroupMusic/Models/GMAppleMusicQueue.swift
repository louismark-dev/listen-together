//
//  GMAppleMusicQueue.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation

class GMAppleMusicQueue: ObservableObject {
    @Published public var state: GMAppleMusicQueue.State
    public var updateHandler: ((GMAppleMusicQueue.State) -> Void)?
    
    init() {
        self.state = GMAppleMusicQueue.State(queue: [], indexOfNowPlayingItem: 0)
        self.updateHandler = nil
    }
    
    init(withQueue queue: [Track]) {
        self.state = GMAppleMusicQueue.State(queue: [], indexOfNowPlayingItem: 0)
        self.updateHandler = nil
    }
    
    static let sharedInstance = GMAppleMusicQueue()
    
    // MARK: Queue Mangagement
    
    /// Inserts the media item  after the last media item in the current queue.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func append(track: Track) {
        self.state.queue.append(track)
        self.triggerUpdateHandler()
    }
    
    public func append(tracks: [Track]) {
        self.state.queue.append(contentsOf: tracks)
        self.triggerUpdateHandler()
    }
    
    /// Inserts the media item defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func prepend(track: Track) {
        self.state.queue.insert(track, at: self.state.indexOfNowPlayingItem)
        self.triggerUpdateHandler()
    }
    
    /// Inserts the media items defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func prepend(tracks: [Track]) {
        self.state.queue.insert(contentsOf: tracks, at: self.state.indexOfNowPlayingItem)
        self.triggerUpdateHandler()
    }
    
    // MARK: Play State Management
    
    /// Marks the currently playing item as the next media item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToNextItem() {
        let nextIndex = self.state.indexOfNowPlayingItem + 1
        if self.state.queue.indices.contains(nextIndex) {
            self.state.indexOfNowPlayingItem = nextIndex
            self.triggerUpdateHandler()
        }
    }
    
    /// Marks the previously playing item as the current item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public func skipToPreviousItem() {
        let previousIndex = self.state.indexOfNowPlayingItem - 1
        if self.state.queue.indices.contains(previousIndex) {
            self.state.indexOfNowPlayingItem = previousIndex
            self.triggerUpdateHandler()
        }
    }
    
    public func triggerUpdateHandler() {
        guard let updateHandler = self.updateHandler else { return }
        updateHandler(self.state)
    }
    
    struct State: Codable {
        public var queue: [Track]
        public var indexOfNowPlayingItem: Int
        public var nowPlayingItem: Track {
            return queue[indexOfNowPlayingItem]
        }
    }
}
