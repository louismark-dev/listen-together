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
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.player = GMAppleMusicControllerPlayer()
        self.queue = GMAppleMusicQueue.sharedInstance // Just setting initial value
        
        self.subscribeToPublishers()
    }
    
    private func subscribeToPublishers() {
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
