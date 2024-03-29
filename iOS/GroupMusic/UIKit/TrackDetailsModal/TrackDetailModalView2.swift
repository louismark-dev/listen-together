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
    @State var queueActionButtonLayout: ButtonLayout?
    let actions: Actions
    
    // MARK: Body
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                self.artwork(withArtworkAttributes: self.trackDetailModalViewModel.track?.attributes?.artwork)
                VStack(alignment: .leading) {
                    self.labels(withTrackName: self.trackDetailModalViewModel.track?.attributes?.name,
                                artistName: self.trackDetailModalViewModel.track?.attributes?.artistName,
                                nowPlaying: self.trackDetailModalViewModel.trackPlaybackStatus == .nowPlaying)
                    self.audioPreviewButton(withAudioPreviewManager: self.previewManager, onTapAction: self.actions.previewTap)
                        .frame(maxHeight: 44)
                }
            }
            self.queueActionButtons(withLayout: self.queueActionButtonLayout)
        }
        .onReceive(self.trackDetailModalViewModel.$trackPlaybackStatus) { (status: TrackDetailModalViewModel.PlaybackStatus) in
            self.setQueueActionButtonLayout(forPlaybackStatus: status)
        }
        
    }
    
    // MARK: Artwork
    @ViewBuilder private func artwork(withArtworkAttributes artwork: Artwork?) -> some View {
        if let artwork = artwork {
            AsyncImageView(url: artwork.urlForMaxWidth(),
                           placeholder: {
                            Color.clear
                           })
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        }
    }
        
    // MARK: Labels
    
    @ViewBuilder private func labels(withTrackName trackName: String?, artistName: String?, nowPlaying: Bool) -> some View {
        VStack {
            if (nowPlaying == true) {
                HStack {
                    Text("Now Playing")
                        .fontWeight(.semibold)
                        .opacity(0.6)
                    Spacer()
                }
                .font(.system(.subheadline, design: .rounded))
            }
            HStack {
                Text(trackName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Spacer()
            }
            .font(.system(.headline, design: .rounded))
            HStack {
                Text(artistName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.6)
                Spacer()
            }
            .font(.system(.subheadline, design: .rounded))
        }
    }
    
    // MARK: Audio Preview
    
    @ViewBuilder private func audioPreviewButton(withAudioPreviewManager previewManager: AudioPreviewManager, onTapAction: @escaping () -> Void) -> some View {
        Button(action: onTapAction) {
            self.audioPreviewButtonBackground(withAudioPreviewManager: previewManager)
        }
    }
    
    @ViewBuilder private func audioPreviewButtonBackground(withAudioPreviewManager previewManager: AudioPreviewManager) -> some View {
        HStack {
            (previewManager.playbackStatus == .stopped ? Image.ui.play_fill : Image.ui.stop_fill)
                .foregroundColor(.blue)
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
    
    @ViewBuilder private func progressBar(withAudioPreviewManager previewManager: AudioPreviewManager) -> some View {
        let lineWidth: CGFloat = 4.0
        
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color.clear)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(previewManager.playbackPosition.playbackFraction, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .square, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
    
    // MARK: Queue Button Appearance

    @ViewBuilder private func queueActionButtons(withLayout layout: ButtonLayout?) -> some View {
        if let layout = layout {
            HStack {
                Button(action: layout.leading.action) {
                    self.queueActionButtonBackground(withConfiguration: layout.leading.appearance.configuration())
                }
                .frame(maxWidth: .infinity)
                if let trailing = layout.trailing {
                    Button(action: trailing.action) {
                        self.queueActionButtonBackground(withConfiguration: trailing.appearance.configuration())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder private func queueActionButtonBackground(withConfiguration configuration: ButtonAppearance) -> some View {
        HStack {
            configuration.icon
            configuration.label
        }
        .font(.system(.headline, design: .rounded))
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(configuration.forgroundColor)
        .background(configuration.backgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: .infinity, style: .circular)))
    }
    
    private func setQueueActionButtonLayout(forPlaybackStatus playbackStatus: TrackDetailModalViewModel.PlaybackStatus) {
        switch playbackStatus {
        case .played:
            self.queueActionButtonLayout = generateButtonLayoutForPlayedTrack()
        case .nowPlaying:
            self.queueActionButtonLayout = generateButtonLayoutForNowPlayingTrack()
        case .inQueue:
            self.queueActionButtonLayout = generateButtonLayoutForInQueueTrack()
        case .notInQueue:
            self.queueActionButtonLayout = generateButtonLayoutForNotInQueueTrack()
        }
    }
    
    private func generateButtonLayoutForPlayedTrack() -> TrackDetailModalView2.ButtonLayout {
        let leadingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .playAgain, action: self.actions.playAgain)
        let buttonLayout = TrackDetailModalView2.ButtonLayout(leading: leadingConfiguration, trailing: nil)
        return buttonLayout
    }
    
    private func generateButtonLayoutForNowPlayingTrack() -> TrackDetailModalView2.ButtonLayout {
        let leadingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .playAgain, action: self.actions.playAgain)
        let buttonLayout = TrackDetailModalView2.ButtonLayout(leading: leadingConfiguration, trailing: nil)
        return buttonLayout
    }
    
    private func generateButtonLayoutForInQueueTrack() -> TrackDetailModalView2.ButtonLayout {
        let leadingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .playNext, action: self.actions.playNext)
        let trailingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .remove, action: self.actions.removeAction)
        let buttonLayout = TrackDetailModalView2.ButtonLayout(leading: leadingConfiguration, trailing: trailingConfiguration)
        return buttonLayout
    }
    
    private func generateButtonLayoutForNotInQueueTrack() -> TrackDetailModalView2.ButtonLayout {
        let leadingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .playNext, action: self.actions.playNext)
        let trailingConfiguration = TrackDetailModalView2.ButtonConfiguration(appearance: .playLast, action: self.actions.playLast)
        let buttonLayout = TrackDetailModalView2.ButtonLayout(leading: leadingConfiguration, trailing: trailingConfiguration)
        return buttonLayout
    }
    
    struct ButtonLayout {
        let leading: ButtonConfiguration
        let trailing: ButtonConfiguration?
    }
    
    struct ButtonConfiguration {
        let appearance: ButtonAppearances
        let action: () -> Void
    }

    struct ButtonAppearance {
        let label: Text
        let icon: Image
        let forgroundColor: Color
        let backgroundColor: Color
    }
    
    enum ButtonAppearances {
        case playNext
        case playAgain
        case playLast
        case remove
        
        func configuration() -> ButtonAppearance {
            switch self {
            case .playNext:
                return ButtonAppearance(label: Text("Play Next"), icon: Image.ui.text_insert, forgroundColor: .white.opacity(0.9), backgroundColor: Color(UIColor.ui.emerald))
            case .playAgain:
                return ButtonAppearance(label: Text("Play Again"), icon: Image.ui._repeat, forgroundColor: .white.opacity(0.9), backgroundColor: Color(UIColor.ui.emerald))
            case .playLast:
                return ButtonAppearance(label: Text("Play Last"), icon: Image.ui.text_append, forgroundColor: .white.opacity(0.9), backgroundColor: Color(UIColor.ui.emerald))
            case .remove:
                return ButtonAppearance(label: Text("Remove"), icon: Image.ui.xmark, forgroundColor: .white.opacity(0.9), backgroundColor: Color(UIColor.ui.amaranth))
            }
        }
    }
    
    // MARK: Queue Button Actions
    struct Actions {
        let playAgain: () -> Void
        let playNext: () -> Void
        let playLast: () -> Void
        let removeAction: () -> Void
        let previewTap: () -> Void
    }
}

//struct TrackDetailModalView2_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailModalView2(trackDetailModalViewModel: TrackDetailModalViewModel())
//            .background(Color.red)
//    }
//}
