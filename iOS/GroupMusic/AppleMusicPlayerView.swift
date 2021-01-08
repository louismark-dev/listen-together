//
//  AppleMusicPlayerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicPlayerView: View {
    @EnvironmentObject var appleMusicPlayer: GMAppleMusicPlayer
    
    var body: some View {
        VStack {
            Text(self.appleMusicPlayer.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: {
                    self.appleMusicPlayer.skipToPreviousItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.appleMusicPlayer.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: {
                    self.appleMusicPlayer.skipToNextItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.green)
        }
    }
    
    private func togglePlayback() {
        if self.appleMusicPlayer.state.playbackState != .playing {
            self.appleMusicPlayer.play(shouldEmitEvent: true)
        } else {
            self.appleMusicPlayer.pause(shouldEmitEvent: true)
        }
    }
}

struct AppleMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlayerView()
    }
}
