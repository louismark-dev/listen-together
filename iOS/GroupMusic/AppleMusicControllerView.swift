//
//  AppleMusicControllerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import SwiftUI

struct AppleMusicControllerView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    let socketManager: GMSockets
    

    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.socketManager = socketManager
    }
 
    var body: some View {
        VStack {
            Text(self.playerAdapter.state.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: self.skipToPreviousItem) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.playerAdapter.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: self.skipToNextItem) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.orange)
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

struct AppleMusicControllerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicControllerView()
    }
}
