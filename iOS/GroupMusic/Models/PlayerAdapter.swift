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
    @Published var queue: GMAppleMusicQueue
    @Published var state: GMAppleMusicPlayer.State = GMAppleMusicPlayer.State()
    private var socketManager: GMSockets
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.player = GMAppleMusicControllerPlayer()
        self.queue = GMAppleMusicQueue.sharedInstance // Just setting initial value
        self.socketManager = socketManager
        
        self.subscribeToSocketManagerPublishers()
        self.subscribeToPlayerPublishers()
    }
    
    private func subscribeToPlayerPublishers() {
        self.player.statePublisher
            .receive(on: RunLoop.main)
            .sink { (state) in
                self.state = state
        }.store(in: &cancellables)
        
        self.player.queuePublisher
            .receive(on: RunLoop.main)
            .sink { (queue) in
                self.queue = queue
        }.store(in: &cancellables)
    }
    
    private func subscribeToSocketManagerPublishers() {
        // Automatically switches between GMAppleMusicPlayer and GMAppleMusicControllerPlayer when isCoordinator changes
        self.socketManager.$state.sink { (newState: GMSockets.State) in
            if (newState.isCoordinator) {
                self.player = GMAppleMusicPlayer()
            } else {
                self.player = GMAppleMusicControllerPlayer()
            }
            self.player.setAsPrimaryPlayer()
            self.subscribeToPlayerPublishers()
        }.store(in: &cancellables)
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
}
