//
//  PlayerAdapter.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-16.
//

import Foundation
import Combine

class PlayerAdapter: ObservableObject {
    var player: PlayerProtocol
    @Published var state: GMAppleMusicHostController.State = GMAppleMusicHostController.State()
    private var socketManager: GMSockets
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.player = GMAppleMusicGuestController()
        self.socketManager = socketManager
        
        self.subscribeToSocketManagerStatePublisher()
        self.subscribeToPlayerPublishers()
    }
    
    private func subscribeToPlayerPublishers() {
        self.player.statePublisher
            .receive(on: RunLoop.main)
            .sink { (state) in
                self.state = state
        }.store(in: &cancellables)
        
    }
    
    /**
     Subscribes to GMSocketManager's State publisher. This enables automaitc switching between GMAppleMusicPlayer and GMAppleMusicControllerPlayer.
     */
    private func subscribeToSocketManagerStatePublisher() {
        // Automatically switches between GMAppleMusicPlayer and GMAppleMusicControllerPlayer when isCoordinator changes
        self.socketManager.$state
            .filter({ (newState: GMSockets.State) -> Bool in
            // Filter out state updates where isCoordinator has not changed
            // Failure to do this will result in new players being initialized when the state changes.
            newState.isCoordinator != self.socketManager.state.isCoordinator
            })
            .sink { (newState: GMSockets.State) in
            if (newState.isCoordinator) {
                self.player = GMAppleMusicHostController()
            } else {
                self.player = GMAppleMusicGuestController()
            }
            self.subscribeToPlayerPublishers()
        }.store(in: &cancellables)
    }
    
    func updateState(with state: GMAppleMusicHostController.State) {
        self.player.updateState(with: state)
    }
    
    func play(completion: (() -> Void)?) {
        self.player.play(completion: completion)
    }
    
    func pause(completion: (() -> Void)?) {
        self.player.pause(completion: completion)
    }
    
    func skipToNextItem(completion: (() -> Void)?) {
        self.player.skipToNextItem(completion: completion)
    }
    
    func skipToPreviousItem(completion: (() -> Void)?) {
        self.player.skipToPreviousItem(completion: completion)
    }
    
    func seek(toPlaybackTime playbackTime: TimeInterval) {
        self.player.seek(toPlaybackTime: playbackTime)
    }
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.prependToQueue(withTracks: tracks, completion: completion)
    }
    
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.appendToQueue(withTracks: tracks, completion: completion)
    }
    
    func moveToStartOfQueue(fromIndex index: Int, completion: (() -> Void)?) {
        self.player.moveToStartOfQueue(fromIndex: index, completion: completion)
    }
    
    func remove(atIndex index: Int, completion: (() -> Void)?) {
        self.player.remove(atIndex: index, completion: completion)
    }
    
    func nowPlayingIndexDidChange(to index: Int) {
        self.player.nowPlayingIndexDidChange(to: index)
    }
}
