//
//  AppleMusicControllerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import SwiftUI

struct AppleMusicControllerView: View {
    @ObservedObject var appleMusicControllerPlayer: GMAppleMusicControllerPlayer
    
    init(appleMusicPlayer: GMAppleMusicControllerPlayer = GMAppleMusicControllerPlayer.sharedInstance) {
        self.appleMusicControllerPlayer = appleMusicPlayer
    }
    var body: some View {
        VStack {
            Text(self.appleMusicControllerPlayer.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: {
                    self.appleMusicControllerPlayer.skipToPreviousItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.appleMusicControllerPlayer.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: {
                    self.appleMusicControllerPlayer.skipToNextItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.orange)
        }
    }
    
    private func togglePlayback() {
        if self.appleMusicControllerPlayer.state.playbackState != .playing {
            self.appleMusicControllerPlayer.play(shouldEmitEvent: true)
        } else {
            self.appleMusicControllerPlayer.pause(shouldEmitEvent: true)
        }
    }
}

struct AppleMusicControllerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicControllerView()
    }
}
