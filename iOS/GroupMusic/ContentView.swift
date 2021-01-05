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
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.socketManager = socketManager
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
            } else {
                AppleMusicControllerView()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
