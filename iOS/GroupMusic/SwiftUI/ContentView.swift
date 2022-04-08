//
//  ContentView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingSheet: Bool = false
    @ObservedObject private var socketManager: GMSockets
    let playerAdapter: PlayerAdapter
    let notificationMonitor: NotificationMonitor
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         playerAdapter: PlayerAdapter = PlayerAdapter()) {
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
    }

    var body: some View {
        VStack {
            SessionView()
            MonitorView()
            Spacer()
            Group {
                Button(String("Add to Queue")) {
                    self.isShowingSheet = true
                }
                AppleMusicQueueView()
                Spacer()
                if (socketManager.state.isCoordinator) {
                    AppleMusicPlayerView()
                } else {
                    AppleMusicControllerView()
                }
            }
            .environmentObject(self.playerAdapter)
        }
        .padding()
        .sheet(isPresented: self.$isShowingSheet) {
            NavigationView {
                AppleMusicSearchView()
                    .navigationBarItems(leading: Button("Dismiss") {
                        isShowingSheet = false
                    })
                    .environmentObject(self.playerAdapter)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
