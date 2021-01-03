//
//  ContentView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingSheet: Bool = false
    let appleMusicPlayer: GMAppleMusicPlayer = GMAppleMusicPlayer()

    var body: some View {
        VStack {
            SessionView()
            MonitorView()
            Spacer()
            Button(String("Add to Queue")) {
                self.isShowingSheet = true
            }
            Button(String("Play all songss")) {
                self.appleMusicPlayer.playAllSongs()
            }
            AppleMusicQueueView()
            Spacer()
            PlayerView()
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
