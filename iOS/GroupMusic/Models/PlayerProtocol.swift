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
    
    func play(completion: (() -> Void)?)
    
    func pause(completion: (() -> Void)?)
    
    func skipToNextItem(completion: (() -> Void)?)
    
    func skipToBeginning(completion: (() -> Void)?)
    
    func skipToPreviousItem(completion: (() -> Void)?)
    
    func prependToQueue(withTracks tracks: [Track], completion: (() -> Void)?)
    
    func appendToQueue(withTracks tracks: [Track], completion: (() -> Void)?)
    
    func setupNotificationCenterObservers()
    
}
