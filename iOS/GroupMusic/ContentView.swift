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
    var appleMusicPlayer: GMAppleMusicPlayer
    var appleMusicController: PlayerAdapter
    
    init(socketManager: GMSockets = GMSockets.sharedInstance,
         appleMusicPlayer: GMAppleMusicPlayer = GMAppleMusicPlayer(),
         appleMusicController: PlayerAdapter = PlayerAdapter()) {
        self.socketManager = socketManager
        self.appleMusicPlayer = appleMusicPlayer
        self.appleMusicController = appleMusicController
    }

    var body: some View {
        VStack {
            SessionView()
            MonitorView()
            Spacer()
            Button(String("Add to Queue")) {
                self.isShowingSheet = true
            }
            AppleMusicQueueView()
            Spacer()
            if (socketManager.state.isCoordinator) {
                AppleMusicPlayerView()
                    .onAppear {
                        if(self.socketManager.state.isCoordinator) {
                            self.appleMusicPlayer.setAsPrimaryPlayer()
                        }
                    }
            } else {
                AppleMusicControllerView()
                    .onAppear {
                        if(self.socketManager.state.isCoordinator == false) {
//                            self.appleMusicController.setAsPrimaryPlayer()
                        }
                    }
            }
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
        .environmentObject(self.appleMusicPlayer)
        .environmentObject(self.appleMusicController)
        .onChange(of: self.socketManager.state.isCoordinator) { (_) in
            if(self.socketManager.state.isCoordinator) {
                self.appleMusicPlayer.setAsPrimaryPlayer()
            } else {
//                self.appleMusicController.setAsPrimaryPlayer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
