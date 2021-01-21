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
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         playerAdapter: PlayerAdapter = PlayerAdapter()) {
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
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
            Color("RussianViolet")
                .ignoresSafeArea(.all, edges: .all)
//            BackgroundBlurView(selectedCell: self.$selectedCell, queueItems: sampleData)
            VStack {
                QueueView()
                    .environmentObject(self.playerAdapter)
                Spacer()
                PlaybackControlsView()
                    .scaleEffect()
                    .padding()
                BottomBarView()
                
            }
                .padding()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
