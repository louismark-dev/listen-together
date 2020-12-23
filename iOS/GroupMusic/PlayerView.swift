//
//  PlayerView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    @ObservedObject var queuePlayer: GMQueuePlayer = GMQueuePlayer()
    var gmSockets: GMSockets?
    
    var body: some View {
        VStack {
            Slider(value: $queuePlayer.fractionPlayed) {_ in
                queuePlayer.seek(to: queuePlayer.fractionPlayed)
            }
            HStack {
                Text(queuePlayer.currentTimeString)
                Spacer()
                Text(queuePlayer.durationString)
            }
            .font(.caption)
            .padding(EdgeInsets(top: 0, leading: 0, bottom:4, trailing: 0))
            HStack {
                Button(action: {
                    queuePlayer.previous()
                }) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (queuePlayer.status != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: {
                    queuePlayer.forward()
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
        }
    }

    private func togglePlayback() {
        if queuePlayer.status != .playing {
            queuePlayer.play()
        } else {
            queuePlayer.pause()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
            .previewLayout(.sizeThatFits)
    }
}
