//
//  PlaybackControlsView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI

struct PlaybackGuestControllerView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    let socketManager: GMSockets
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.socketManager = socketManager
    }
    
    var body: some View {
        HStack {
            BackwardsButton(skipToPreviousItem: self.skipToPreviousItem)
            PlayPauseButton(togglePlayback: self.togglePlayback, playerAdapter: self.playerAdapter)
            ForwardsButton(skipToNextItem: self.skipToNextItem)
        }
        .font(.largeTitle)
        .foregroundColor(.white)
        .opacity(0.9)
    }
    
    struct BackwardsButton: View {
        let skipToPreviousItem: () -> Void
       
        var body: some View {
            Button(action: { self.skipToPreviousItem() }) {
                ZStack {
                    Image(systemName: "backward.fill")
                        .opacity(0.9)
                }
                .aspectRatio(1.0, contentMode: .fit)
            }
        }
    }
    
    struct PlayPauseButton: View {
        let togglePlayback: () -> Void
        let playerAdapter: PlayerAdapter
        
        var body: some View {
            Button(action: { self.togglePlayback() }) {
                ZStack {
                    Circle()
                        .foregroundColor(Color("TiffanyBlue"))
                    Image(systemName: (self.playerAdapter.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                .frame(maxHeight: 60)
            }
        }
    }
    
    struct ForwardsButton: View {
        let skipToNextItem: () -> Void
        
        var body: some View {
            Button(action: { self.skipToNextItem() }) {
                ZStack {
                    Image(systemName: "forward.fill")
                        .opacity(0.9)
                }
                .frame(maxHeight: 60)
            }
        }
    }
    
    private func togglePlayback() {
        if self.playerAdapter.state.playbackState != .playing {
            do {
                try self.socketManager.emitPlayEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            do {
                try self.socketManager.emitPauseEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func skipToNextItem() {
        do {
            try self.socketManager.emitForwardEvent()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func skipToPreviousItem() {
        do {
            try self.socketManager.emitPreviousEvent()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct PlaybackGuestControllerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("RussianViolet")
            .ignoresSafeArea(.all, edges: .all)
            PlaybackGuestControllerView()
                .padding()
        }
    }
}
