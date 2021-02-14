//
//  RootView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-20.
//

import SwiftUI

struct RootView: View {
    @State var isShowingSheet: Bool = false
    @ObservedObject private var socketManager: GMSockets
    let notificationMonitor: NotificationMonitor
    let playerAdapter: PlayerAdapter
//    let backgroundAudio: BackgroundAudio
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         playerAdapter: PlayerAdapter = PlayerAdapter()) {
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
        
//        self.backgroundAudio = BackgroundAudio()
    }
    
    let sampleData = [
        SampleData(artistName: "DaBaby", songName: "Practice", artworkName: "DaBaby"),
        SampleData(artistName: "Lil Nas X", songName: "Holiday", artworkName: "LilNasX"),
        SampleData(artistName: "NAV", songName: "Friends & Family", artworkName: "NAV"),
        SampleData(artistName: "Juice WRLD & Young Thug", songName: "Bad Boy", artworkName: "YoungThug")
    ]
    @State var selectedCell: Int = 0
    
    var body: some View {
        ZStack {
            BackgroundBlurView()
                .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                .ignoresSafeArea()
            VStack {
                QueueView()
                Spacer()
                PlaybackProgressView()
                Group {
                    if (socketManager.state.isCoordinator) {
                        PlaybackHostControllerView()
                    } else {
                        PlaybackGuestControllerView()
                    }
                }
                    .scaleEffect()
                    .padding()
                BottomBarView()
                
            }
                .padding()
        }
        .environmentObject(self.playerAdapter)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
