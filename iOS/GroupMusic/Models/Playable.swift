//
//  Playable.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import Foundation

protocol Playable: ObservableObject {
    var state: GMAppleMusicPlayer.State { get set } // TODO: Future versions should not depend on GMAppleMusicPlayer
    
    func play(shouldEmitEvent: Bool)
    func pause(shouldEmitEvent: Bool)
    func skipToNextItem(shouldEmitEvent: Bool)
    func skipToBeginning(shouldEmitEvent: Bool)
    func skipToPreviousItem(shouldEmitEvent: Bool)
}
