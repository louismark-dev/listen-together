//
//  RootView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-20.
//

import SwiftUI

struct RootView: View {
    @State var isShowingSheet: Bool = false
    @State var showReturnToNowPlayingBanner: Bool = false
    @ObservedObject private var socketManager: GMSockets
    let notificationMonitor: NotificationMonitor
    let playerAdapter: PlayerAdapter
    let bannerController: BannerController
    let trackDetailModalViewManager: TrackDetailModalViewManager
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         playerAdapter: PlayerAdapter = PlayerAdapter()){
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
        self.bannerController = BannerController(playerAdapter: playerAdapter)
        self.trackDetailModalViewManager = TrackDetailModalViewManager()
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
                    .environmentObject(self.bannerController)
                    .environmentObject(self.trackDetailModalViewManager)
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
            TrackDetailModalView()
                .environmentObject(self.trackDetailModalViewManager)
                .edgesIgnoringSafeArea(.all)
        }
        .overlay(BannerView()
                    .environmentObject(self.bannerController))
        .environmentObject(self.playerAdapter)
        
    }
    
    private struct BannerView: View {
        @EnvironmentObject var bannerController: BannerController
        
        var body: some View {
            VStack {
                ReturnToNowPlayingView()
                    .frame(maxWidth: 300, maxHeight: 30)
                    .padding(4)
                Spacer()
            }
            .offset(x: 0.0, y: (self.bannerController.state.bannerState == .showReturnToNowPlayingBanner) ? 0 : -120)
            .opacity((self.bannerController.state.bannerState == .showReturnToNowPlayingBanner) ? 1 : 0)
            .animation(.spring())
            .onTapGesture {
                self.bannerController.returnToNowPlayingTapped()
                self.bannerController.state.bannerState = .none
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
