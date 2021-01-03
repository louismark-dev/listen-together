//
//  AppleMusicPlayerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicPlayerView: View {
    @ObservedObject var appleMusicPlayer: GMAppleMusicPlayer
    
    init(appleMusicPlayer: GMAppleMusicPlayer = GMAppleMusicPlayer.sharedInstance) {
        self.appleMusicPlayer = appleMusicPlayer
    }
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.appleMusicPlayer.skipToPreviousItem(shouldEmitEvent: false)
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
                    self.appleMusicPlayer.skipToNextItem(shouldEmitEvent: false)
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
        }
    }
    
    private func togglePlayback() {
        if self.appleMusicPlayer.state.playbackState != .playing {
            self.appleMusicPlayer.play(shouldEmitEvent: false)
        } else {
            self.appleMusicPlayer.pause(shouldEmitEvent: false)
        }
    }
}

struct AppleMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlayerView()
    }
}
