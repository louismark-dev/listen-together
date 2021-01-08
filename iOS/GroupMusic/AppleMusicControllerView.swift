//
//  AppleMusicControllerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-04.
//

import SwiftUI

struct AppleMusicControllerView: View {
    @EnvironmentObject var appleMusicController: GMAppleMusicControllerPlayer
    
    var body: some View {
        VStack {
            Text(self.appleMusicController.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: {
                    self.appleMusicController.skipToPreviousItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.appleMusicController.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: {
                    self.appleMusicController.skipToNextItem(shouldEmitEvent: true)
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.orange)
        }
    }
    
    private func togglePlayback() {
        if self.appleMusicController.state.playbackState != .playing {
            self.appleMusicController.play(shouldEmitEvent: true)
        } else {
            self.appleMusicController.pause(shouldEmitEvent: true)
        }
    }
}

struct AppleMusicControllerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicControllerView()
    }
}
