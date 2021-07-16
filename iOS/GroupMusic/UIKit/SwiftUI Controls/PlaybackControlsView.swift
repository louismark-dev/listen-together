//
//  PlaybackControlView.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-16.
//

import SwiftUI

struct PlaybackControlsView: View {
    
    let backwardAction: () -> Void
    let playAction: () -> Void
    let forwardAction: () -> Void
    let opacity: Double
    
    init(withConfiguration configuration: Configuration) {
        self.backwardAction = configuration.backwardAction
        self.playAction = configuration.playAction
        self.forwardAction = configuration.forwardAction
        self.opacity = configuration.opacity
    }
    
    var playButton: some View {
        Button(action: self.playAction, label: {
            Image.ui.play_fill
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
            self.playButton
            Spacer()
            self.forwardButton
        }
        .foregroundColor(.white.opacity(self.opacity))
        .font(.largeTitle)
    }
    
    struct Configuration {
        let backwardAction: () -> Void
        let playAction: () -> Void
        let forwardAction: () -> Void
        let opacity: Double
    }
}

struct PlaybackControlView_Previews: PreviewProvider {
    static var previews: some View {
        let configuration = PlaybackControlsView.Configuration(backwardAction: {},
                                                               playAction: {},
                                                               forwardAction: {},
                                                               opacity: 0.8)
        
        ZStack {
            Color.orange
            PlaybackControlsView(withConfiguration: configuration)
                .frame(maxHeight: 40)
                .padding()
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}
