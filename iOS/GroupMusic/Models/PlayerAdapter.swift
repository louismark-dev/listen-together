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
    @Published var state: GMAppleMusicPlayer.State = GMAppleMusicPlayer.State()
    private var socketManager: GMSockets
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.player = GMAppleMusicController()
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
                self.player = GMAppleMusicPlayer()
            } else {
                self.player = GMAppleMusicController()
            }
            self.subscribeToPlayerPublishers()
        }.store(in: &cancellables)
    }
    
    func updateState(with state: GMAppleMusicPlayer.State) {
        self.player.updateState(with: state)
    }
    
    func play(shouldEmitEvent: Bool  = true) {
        self.player.play(shouldEmitEvent: shouldEmitEvent)
    }
    
    func pause(shouldEmitEvent: Bool  = true) {
        self.player.pause(shouldEmitEvent: shouldEmitEvent)
    }
    
    func skipToNextItem(shouldEmitEvent: Bool  = true) {
        self.player.skipToNextItem(shouldEmitEvent: shouldEmitEvent)
    }
    
    func skipToPreviousItem(shouldEmitEvent: Bool = true) {
        self.player.skipToPreviousItem(shouldEmitEvent: shouldEmitEvent)
    }
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.prependToQueue(withTracks: tracks, completion: completion)
    }
    
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?) {
        self.player.appendToQueue(withTracks: tracks, completion: completion)
    }
}
