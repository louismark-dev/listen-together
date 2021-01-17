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
    var playerAdapter: PlayerAdapter
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         playerAdapter: PlayerAdapter = PlayerAdapter()) {
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
    }

    var body: some View {
        VStack {
            SessionView()
            MonitorView()
            Spacer()
            Button(String("Add to Queue")) {
                self.isShowingSheet = true
            }
            Group {
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
                AppleMusicView()
                    .navigationBarItems(leading: Button("Dismiss") {
                        isShowingSheet = false
                    })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
