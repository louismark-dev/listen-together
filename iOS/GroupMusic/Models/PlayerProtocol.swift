//
//  PlayerProtocol.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-16.
//

import Foundation

protocol PlayerProtocol {
    var queuePublisher: Published<GMAppleMusicQueue>.Publisher { get }
    var statePublisher: Published<GMAppleMusicPlayer.State>.Publisher { get }
    var socketManager: GMSockets { get }
    var notificationCenter: NotificationCenter { get }
    
    func play(shouldEmitEvent: Bool)
    
    func pause(shouldEmitEvent: Bool)
    
    func skipToNextItem(shouldEmitEvent: Bool)
    
    func skipToBeginning(shouldEmitEvent: Bool)
    
    func skipToPreviousItem(shouldEmitEvent: Bool)
    
    func setupNotificationCenterObservers()
}
