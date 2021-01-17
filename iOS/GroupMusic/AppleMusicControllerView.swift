//
//  AppleMusicControllerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import SwiftUI

struct AppleMusicControllerView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    var body: some View {
        VStack {
            Text(self.playerAdapter.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: {
                    self.playerAdapter.skipToPreviousItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.playerAdapter.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: {
                    self.playerAdapter.skipToNextItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.orange)
        }
    }
    
    private func togglePlayback() {
        if self.playerAdapter.state.playbackState != .playing {
            self.playerAdapter.play(shouldEmitEvent: true)
        } else {
            self.playerAdapter.pause(shouldEmitEvent: true)
        }
    }
}

struct AppleMusicControllerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicControllerView()
    }
}
