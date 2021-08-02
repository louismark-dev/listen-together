//
//  TrackDetailModalView.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-25.
//

import SwiftUI

struct TrackDetailModalView2: View {
    @ObservedObject var trackDetailModalViewModel: TrackDetailModalViewModel
    @ObservedObject var previewManager: AudioPreviewManager
    
    let onPreviewTap: () -> ()
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.green)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            VStack(alignment: .leading) {
                self.labels(withTrackName: self.trackDetailModalViewModel.track?.attributes?.name,
                            artistName: self.trackDetailModalViewModel.track?.attributes?.artistName)
                self.audioPreviewButton(withAudioPreviewManager: self.previewManager)
                    .frame(maxHeight: 44)
            }
        }
        
    }
    
    @ViewBuilder func labels(withTrackName trackName: String?, artistName: String?) -> some View {
        VStack {
            HStack {
                Text(trackName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Spacer()
            }
            HStack {
                Text(artistName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.6)
                Spacer()
            }
        }
        .font(.system(.headline, design: .rounded))
    }
    
    @ViewBuilder func audioPreviewButton(withAudioPreviewManager previewManager: AudioPreviewManager) -> some View {
        Button(action: self.onPreviewTap) {
            self.audioPreviewButtonBackground(withAudioPreviewManager: previewManager)
        }
    }
    
    @ViewBuilder func audioPreviewButtonBackground(withAudioPreviewManager previewManager: AudioPreviewManager) -> some View {
        HStack {
            (previewManager.playbackStatus == .stopped ? Image.ui.play_fill : Image.ui.stop_fill)
                .foregroundColor(.blue.opacity(0.9))
                .padding(6)
                .overlay(self.progressBar(withAudioPreviewManager: previewManager))
                .background(Color.white
                                .clipShape(Circle()))
            Text("Preview")
                .foregroundColor(.white.opacity(0.9))
        }
        .font(Font.system(.footnote, design: .rounded).weight(.semibold))
        .padding(6)
        .background(Color.blue
                        .clipShape(RoundedRectangle(cornerRadius: .infinity, style: .continuous)))
    }
    
    @ViewBuilder func progressBar(withAudioPreviewManager previewManager: AudioPreviewManager) -> some View {
        let lineWidth: CGFloat = 4.0
        
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color.clear)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(previewManager.playbackPosition.playbackFraction, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .square, lineJoin: .round))
                .foregroundColor(.blue.opacity(0.9))
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}

//struct TrackDetailModalView2_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailModalView2(trackDetailModalViewModel: TrackDetailModalViewModel())
//            .background(Color.red)
//    }
//}
