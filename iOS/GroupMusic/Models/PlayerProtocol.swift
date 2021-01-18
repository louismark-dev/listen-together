//
//  PlayerProtocol.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-16.
//

import Foundation

protocol PlayerProtocol {
    var statePublisher: Published<GMAppleMusicPlayer.State>.Publisher { get }
    var socketManager: GMSockets { get }
    var notificationCenter: NotificationCenter { get }
    
    func updateState(with state: GMAppleMusicPlayer.State)
    
    func play(shouldEmitEvent: Bool)
    
    func pause(shouldEmitEvent: Bool)
    
    func skipToNextItem(shouldEmitEvent: Bool)
    
    func skipToBeginning(shouldEmitEvent: Bool)
    
    func skipToPreviousItem(shouldEmitEvent: Bool)
    
    func setupNotificationCenterObservers()
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?)
    
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?)
    
}
