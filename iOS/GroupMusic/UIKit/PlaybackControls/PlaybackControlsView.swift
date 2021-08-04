//
//  PlaybackControlView.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-16.
//

import SwiftUI

struct PlaybackControlsView: View {
    
    private let backwardAction: () -> Void
    private let togglePlaybackAction: () -> Void
    private let forwardAction: () -> Void
    private let playerAdapter: PlayerAdapter
    
    @State private var isPlaying: Bool = false
    
    init(withConfiguration configuration: Configuration) {
        self.backwardAction = configuration.actions.backwardAction
        self.togglePlaybackAction = configuration.actions.togglePlaybackAction
        self.forwardAction = configuration.actions.forwardAction
        self.playerAdapter = configuration.playerAdapter
    }
    
    var playPauseButton: some View {
        Button(action: self.togglePlaybackAction, label: {
            Group {
                (self.isPlaying == true) ? Image.ui.pause_fill : Image.ui.play_fill
            }
            .aspectRatio(1.0, contentMode: .fill)
        })
    }
    
    var backwardButton: some View {
        Button(action: self.backwardAction) {
            Image(systemName: "backward.fill")
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
    
    var forwardButton: some View {
        Button(action: self.forwardAction, label: {
            Image.ui.forward_fill
                .aspectRatio(1.0, contentMode: .fill)
        })
    }
    
    var body: some View {
        HStack {
            self.backwardButton
            Spacer()
            self.playPauseButton
            Spacer()
            self.forwardButton
        }
        .foregroundColor(.white.opacity(0.8))
        .font(.largeTitle)
        .onReceive(self.playerAdapter.$state) { (state: GMAppleMusicHostController.State) in
            self.isPlaying = state.playbackState == .playing
        }
    }
    
    struct Actions {
        let backwardAction: () -> Void
        let togglePlaybackAction: () -> Void
        let forwardAction: () -> Void
    }
    
    struct Configuration {
        let playerAdapter: PlayerAdapter
        let actions: Actions
    }
}
//
//struct PlaybackControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        let configuration = PlaybackControlsView.Configuration(backwardAction: {},
//                                                               playAction: {},
//                                                               forwardAction: {},
//                                                               opacity: 0.8,
//                                                               playerAdapter: <#PlayerAdapter#>)
//
//        ZStack {
//            Color.orange
//            PlaybackControlsView(withConfiguration: configuration)
//                .frame(maxHeight: 40)
//                .padding()
//        }
//        .edgesIgnoringSafeArea(.vertical)
//    }
//}
