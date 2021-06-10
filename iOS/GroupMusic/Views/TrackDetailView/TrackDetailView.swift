//
//  TrackDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View, AudioPreviewDelegate {
    @StateObject var audioPreviewPlayer: AudioPreview = AudioPreview()
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @EnvironmentObject var trackDetailModalViewManager: TrackDetailModalViewManager
    @State var showPreviewConfirmationAlert: Bool = false
    
    @State var previewPlaybackStatus: AudioPreview.PlaybackStatus = .stopped
    @State var previewPlaybackPosition: PlaybackPosition = PlaybackPosition()
    @State var shouldResumePlaybackAfterPreviewCompletion: Bool = false
    let track: Track
    let socketManager: GMSockets
    
    init(withTrack track: Track, socketManager: GMSockets = GMSockets.sharedInstance) {
        self.track = track
        self.socketManager = socketManager
    }
    
    var labels: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(self.track.attributes?.name ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Spacer()
            }
            HStack {
                Text(self.track.attributes?.artistName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.6)
                Spacer()
            }
        }
        .font(.system(.headline, design: .rounded))
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func button(forConfiguration configuration: TrackDetailModalViewButtonConfiguration) -> some View {
        Group {
            switch configuration {
            case .playNext(label: let label, imageSystemName: let imageSystemName, foregroundColor: let foregroundColor, backgroundColor: let backgroundColor):
                Button(action: self.prependToQueue) {
                    ButtonBackground(label: label, imageSystemName: imageSystemName, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
                }
            case .playAgain(label: let label, imageSystemName: let imageSystemName, foregroundColor: let foregroundColor, backgroundColor: let backgroundColor):
                Button(action: self.playAgain) {
                    ButtonBackground(label: label, imageSystemName: imageSystemName, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
                }
            case .playLast(label: let label, imageSystemName: let imageSystemName, foregroundColor: let foregroundColor, backgroundColor: let backgroundColor):
                Button(action: self.appendToQueue) {
                    ButtonBackground(label: label, imageSystemName: imageSystemName, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
                }
            case .remove(label: let label, imageSystemName: let imageSystemName, foregroundColor: let foregroundColor, backgroundColor: let backgroundColor):
                Button(action: self.removeFromQueue) {
                    ButtonBackground(label: label, imageSystemName: imageSystemName, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
                }
            case .none:
                EmptyView()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let artworkURL = self.track.attributes?.artwork.urlForMaxWidth() {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 20)
                        .aspectRatio(1.0, contentMode: .fit)
                }
                VStack {
                    self.labels
                    HStack {
                        Button(action: self.previewTapped, label: {
                            PreviewButton(audioPreviewPlaybackStatus: self.$previewPlaybackStatus,
                                          audioPreviewPlaybackPosition: self.$previewPlaybackPosition)
                        })
                        .alert(isPresented: self.$showPreviewConfirmationAlert, content: {
                            Alert(title: Text("Previewing this song will pause music playback."),
                                  message: nil,
                                  primaryButton: .cancel(),
                                  secondaryButton: .default(Text("Continue")) {
                                    self.playPreview(andPausePlayback: true)
                                  })
                        })
                        Spacer()
                    }
                }
            }
            Spacer()
                .frame(maxHeight: 32)
            HStack {
                if let configuration = self.trackDetailModalViewManager.configuration {
                    self.button(forConfiguration: configuration.buttonConfiguration.leading)
                    self.button(forConfiguration: configuration.buttonConfiguration.trailing)
                }
            }
        }
        .foregroundColor(Color.black)
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 25))
        .onAppear {
            self.trackDetailModalViewManager.audioPreviewPlayer.delegate = self
        }
    }
    
    // MARK: Button Actions
    
    private func previewTapped() {
        if (self.trackDetailModalViewManager.audioPreviewPlayer.playbackStatus == .stopped) {
            // Play preview
            self.showPreviewConfirmationAlert = (self.socketManager.state.isCoordinator == true && self.playerAdapter.state.playbackState == .playing)
            if (self.showPreviewConfirmationAlert == false) {
                self.playPreview()
            }
        } else {
            // Stop preview
            try? self.trackDetailModalViewManager.audioPreviewPlayer.stop()
        }
    }
    
    private func playPreview(andPausePlayback shouldPausePlayback: Bool = false) {
        if(shouldPausePlayback) {
            self.playerAdapter.pause {
                try? self.trackDetailModalViewManager.audioPreviewPlayer.play()
            }
            self.shouldResumePlaybackAfterPreviewCompletion = true
        } else {
            try? self.trackDetailModalViewManager.audioPreviewPlayer.play()
            self.shouldResumePlaybackAfterPreviewCompletion = false
        }
    }
    
    private func playAgain() {
        self.trackDetailModalViewManager.close()
        let track = [self.track]
        // IF OBSERVER
        if (self.socketManager.state.isCoordinator == false) {
            do {
                try self.socketManager.emitPrependToQueueEvent(withTracks: track)
            } catch {
                print("Emit failed \(error.localizedDescription)")
            }
        }
        
        // IF COORDINATOR
        if (self.socketManager.state.isCoordinator == true) {
            self.playerAdapter.prependToQueue(withTracks: track) {
                do {
                    try self.socketManager.emitPrependToQueueEvent(withTracks: track)
                } catch {
                    print("Emit failed \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func prependToQueue() {
        self.trackDetailModalViewManager.close()
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.prependToQueue(withTracks: [self.track]) {
                do {
                    try self.socketManager.emitPrependToQueueEvent(withTracks: [self.track])
                } catch {
                    print("Could not emit PrependToQueueEvent event.")
                }
            }
        } else {
            // NOT COORDINATOR
            do {
                try self.socketManager.emitPrependToQueueEvent(withTracks: [self.track])
            } catch {
                print("Could not emit PrependToQueueEvent event.")
            }
        }
    }
    
    private func appendToQueue() {
        self.trackDetailModalViewManager.close()
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.appendToQueue(withTracks: [self.track]) {
                do {
                    try self.socketManager.emitAppendToQueueEvent(withTracks: [self.track])
                } catch {
                    print("Could not emit apendToQueue event.")
                }
            }
        } else {
            // NOT COORDINATOR
            do {
                try self.socketManager.emitAppendToQueueEvent(withTracks: [self.track])
            } catch {
                print("Could not emit appendToQueue event.")
            }
        }
    }
    
    private func moveToStartOfQueue() {
        self.trackDetailModalViewManager.close()
        let index = self.playerAdapter.state.queue.indexFor(track: self.track)
        guard let index = index else { return }
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.moveToStartOfQueue(fromIndex: index) {
                do {
                    try self.socketManager.emitMoveToStartOfQueue(fromIndex: index)
                } catch {
                    print("Could not emit moveToStartOfQueue event.")
                }
            }
        } else {
            do {
                try self.socketManager.emitMoveToStartOfQueue(fromIndex: index)
            } catch {
                print("Could not emit moveToStartOfQueue event")
            }
        }
    }
    
    private func removeFromQueue() {
        self.trackDetailModalViewManager.close()
        let index =  self.playerAdapter.state.queue.indexFor(track: self.track)
        guard let index = index else { return }
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.remove(atIndex: index) {
                do {
                    try self.socketManager.emitRemoveEvent(atIndex: index)
                } catch {
                    print("Could not emit remove event.")
                }
            }
        } else {
            // IS NOT COORDINATOR
            do {
                try self.socketManager.emitRemoveEvent(atIndex: index)
            } catch {
                print("Could not emit removeEvent")
            }
        }
    }
    
    // MARK: AudioPreviewDelegate
    
    func playbackStatusDidChange(to playbackStatus: AudioPreview.PlaybackStatus) {
        self.previewPlaybackStatus = playbackStatus
        
        if (self.previewPlaybackStatus == .stopped && self.shouldResumePlaybackAfterPreviewCompletion) {
            self.playerAdapter.play(completion: nil)
        }
    }
    
    func playbackPositionDidChange(to playbackPosition: PlaybackPosition) {
        self.previewPlaybackPosition = playbackPosition
    }
    
    // MARK: Subviews
    
    struct PreviewButton: View {
        @Binding var audioPreviewPlaybackStatus: AudioPreview.PlaybackStatus
        @Binding var audioPreviewPlaybackPosition: PlaybackPosition
        
        var body: some View {
            HStack {
                Image(systemName: (self.audioPreviewPlaybackStatus == .stopped) ? "play.fill" : "stop.fill")
                    .foregroundColor(.blue)
                    .opacity(0.9)
                    .padding(5)
                    .background(ProgressBar(audioPreviewPlaybackPosition: self.$audioPreviewPlaybackPosition)
                                    .background(Color.white))
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .font(Font.system(.footnote, design: .rounded).weight(.regular))
                Spacer()
                    .frame(maxWidth: 10)
                Text("Preview")
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .font(Font.system(.footnote, design: .rounded).weight(.semibold))
                Spacer()
                    .frame(maxWidth: 10)
            }
            .padding(4)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
        }
        
        struct ProgressBar: View {
            @Binding var audioPreviewPlaybackPosition: PlaybackPosition
            @State var playbackFraction: Double = 0.0
            let lineWidth: CGFloat = CGFloat(4.0)
            
            var body: some View {
                ZStack {
                    Circle()
                        .stroke(lineWidth: self.lineWidth)
                        .foregroundColor(Color.clear)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.playbackFraction, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .square, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                }
                .onChange(of: self.audioPreviewPlaybackPosition.playbackFraction, perform: { value in
                    self.playbackFraction = value
                })
            }
        }
    }
    
    struct ButtonBackground: View {
        let label: String
        let imageSystemName: String
        let backgroundColor: Color
        let foregroundColor: Color
        
        var body: some View {
            HStack {
                Spacer()
                Image(systemName: self.imageSystemName)
                Text(self.label)
                    .lineLimit(1)
                    .fixedSize()
                    .foregroundColor(self.foregroundColor)
                Spacer()
            }
            .foregroundColor(Color.white)
            .opacity(0.9)
            .font(Font.system(.headline, design: .rounded).weight(.semibold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .foregroundColor(self.backgroundColor))
        }
    }
}
