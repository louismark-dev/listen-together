//
//  BannerController.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-14.
//

import Foundation

class BannerController: ObservableObject {
    let playerAdapter: PlayerAdapter
    let notficationCenter: NotificationCenter
    @Published var state: State = State()
    @Published var scrollToTopOfQueue: Bool = false
    
    init(playerAdapter: PlayerAdapter,
         notificationCenter: NotificationCenter = .default) {
        self.playerAdapter = playerAdapter
        self.notficationCenter = notificationCenter
    }
    
    public func returnToNowPlayingTapped() {
        self.scrollToTopOfQueue = true
    }
    
    struct State {
        var bannerState: BannerState = .none
    }
    
    enum BannerState {
        case none
        case showReturnToNowPlayingBanner
    }
}
