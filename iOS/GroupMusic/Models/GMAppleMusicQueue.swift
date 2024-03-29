//
//  GMAppleMusicQueue.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation
import MediaPlayer

struct GMAppleMusicQueue: Codable {
    public var state: GMAppleMusicQueue.State
    
    init() {
        self.state = GMAppleMusicQueue.State(queue: [], indexOfNowPlayingItem: 0)
    }
    
    init(withQueue queue: [Track]) {
        self.state = GMAppleMusicQueue.State(queue: [], indexOfNowPlayingItem: 0)
    }
        
    // MARK: Queue Mangagement
    
    /// This function is designed to be used with the MPMusicPlayerApplicationController.
    /// This function sets the items and sorting of the Tracks in GMAppleMusicQueue equal to the sorting of the equivalent MPMediaItems
    /// - Parameters:
    ///     - mpMediaItems: The sorted MPMediaItems returned by the MPMusicPlayerApplicationController.perform() completion handler
    ///     - withNewTracks: The new Track objects that are being added to the queue
    public mutating func setQueueTo(mpMediaItems: [MPMediaItem], withNewTracks tracks: [Track]) throws {
        var unsortedTracks = self.state.queue
        unsortedTracks.append(contentsOf: tracks)
        let sortedTracks: [Track?] = mpMediaItems.map { (mediaItem) -> Track? in
            let matchedItems = unsortedTracks.filter { (track: Track) -> Bool in
                track.storeID == mediaItem.playbackStoreID
            }
            if (matchedItems.count == 0) {
                print("COULD NOT SET ITEM. NOTIFY USER: \(mediaItem.title ?? "")")
                return nil
            } else {
                return matchedItems[0]
            }
        }
        let filteredTracks: [Track] = sortedTracks.filter({ (track: Track?) -> Bool in
            return track != nil
        }) as! [Track]
        self.state.queue = filteredTracks
    }
    
    /// Inserts the media item  after the last media item in the current queue.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public mutating func append(track: Track) {
        self.state.queue.append(track)
    }
    
    public mutating func append(tracks: [Track]) {
        self.state.queue.append(contentsOf: tracks)
    }
    
    /// Inserts the media item defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public mutating func prepend(track: Track) {
        self.state.queue.insert(track, at: self.state.indexOfNowPlayingItem + 1)
    }
    
    public mutating func remove(atIndex index: Int, completion: (() -> Void)? = nil) {
        self.state.queue.remove(at: index)
        completion?()
    }
    
    /// Inserts the media items defined into the current queue immediately after the currently playing media item.
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public mutating func prepend(tracks: [Track]) {
        self.state.queue.insert(contentsOf: tracks, at: self.state.indexOfNowPlayingItem + 1)
    }
    
    public func playbackStatusFor(track: Track) -> PlaybackStatus {
        let index = self.state.queue.firstIndex(of: track)
        guard let index = index else { return .inQueue }
        if (index < self.state.indexOfNowPlayingItem) {
            return .played
        } else if (index > self.state.indexOfNowPlayingItem) {
            return .inQueue
        } else if (index == self.state.indexOfNowPlayingItem) {
            return .playing
        } else {
            return .notInQueue
        }
    }
    
    public func indexFor(track: Track) -> Int? {
        return self.state.queue.firstIndex(of: track)
    }
    
    enum PlaybackStatus {
        case played
        case playing
        case inQueue
        case notInQueue
    }
    
    // MARK: Play State Management
    
    /// Marks the currently playing item as the next media item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public mutating func skipToNextItem() {
        let nextIndex = self.state.indexOfNowPlayingItem + 1
        if self.state.queue.indices.contains(nextIndex) {
            self.state.indexOfNowPlayingItem = nextIndex
        }
    }
    
    /// Marks the previously playing item as the current item in the playback queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    public mutating func skipToPreviousItem() {
        let previousIndex = self.state.indexOfNowPlayingItem - 1
        if self.state.queue.indices.contains(previousIndex) {
            self.state.indexOfNowPlayingItem = previousIndex
        }
    }
    
    struct State: Codable {
        
        init(queue: [Track], indexOfNowPlayingItem: Int) {
            self.indexOfNowPlayingItem = indexOfNowPlayingItem
            self._queue = queue
        }
        
        public var queue: [Track] {
            // Setter is used to set UUID value of each track in the queue. This ensures that each UUID is always unique.
            // Failure to do this could result in issues with Identifiable.
            
            get { return self._queue }
            
            set { self._queue = newValue }
            
            // TODO: Uncomment this if app can't handle identical items in queue
//            set {
//                self._queue = newValue.map({ (track: Track) -> Track in
//                    var trackWithUUID = track
//                    trackWithUUID.id = UUID()
//                    return trackWithUUID
//                })
//            }
        }
        
        public var indexOfNowPlayingItem: Int
        public var nowPlayingItem: Track? {
            if (queue.indices.contains(indexOfNowPlayingItem)) {
                return queue[indexOfNowPlayingItem]
            } else {
                return nil
            }
        }
        public var itemsToBePlayed: [Track] {
            Array(self.queue[(indexOfNowPlayingItem + 1)..<self.queue.count])
        }
        private var _queue: [Track]
        
    }
    
    enum QueueUpdateError: Error, LocalizedError {
        case failedToSetQueueEqualToMPMusicPlayerControllerQueue
        
        public var errorDescription: String {
                switch self {
                case .failedToSetQueueEqualToMPMusicPlayerControllerQueue:
                    return "Faield to set queue equal to MPMusicPlayerControllerQueue."
                }
            }
    }
}
