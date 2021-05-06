//
//  TrackDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View {
    @StateObject var audioPreviewPlayer: AudioPreview = AudioPreview()
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @EnvironmentObject var trackDetailModalViewManager: TrackDetailModalViewManager
    
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
                            PreviewButton(audioPreviewPlaybackStatus: self.$trackDetailModalViewManager.audioPreviewPlayer.playbackStatus)
                        })
                        Spacer()
                    }
                }
            }
            Spacer()
                .frame(maxHeight: 32)
            HStack {
                Button(action: {
                    if (self.playerAdapter.state.queue.playbackStatusFor(track: self.track) == .playing) {
                        self.playAgain()
                    } else {
                        self.moveToStartOfQueue()
                    }
                },
                label: {
                    ButtonBackground(label: (self.playerAdapter.state.queue.playbackStatusFor(track: self.track) != .playing) ? "Play Next" : "Play Again",
                                     imageSystemName: (self.playerAdapter.state.queue.playbackStatusFor(track: self.track) != .playing) ? "text.insert" : "repeat",
                                     foregroundColor: Color("Emerald"))
                })
                if (self.playerAdapter.state.queue.playbackStatusFor(track: self.track) == .inQueue) {
                    Button(action: self.removeFromQueue, label: {
                        ButtonBackground(label: "Remove",
                                         imageSystemName: "xmark",
                                         foregroundColor: Color("Amaranth"))
                    })
                    
                }
            }
        }
        .foregroundColor(Color.black)
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 25))
    }
    
    private func previewTapped() {
        if (self.trackDetailModalViewManager.audioPreviewPlayer.playbackStatus == .stopped) {
            try? self.trackDetailModalViewManager.audioPreviewPlayer.play()
        } else {
            try? self.trackDetailModalViewManager.audioPreviewPlayer.stop()
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
    
    struct PreviewButton: View {
        @Binding var audioPreviewPlaybackStatus: AudioPreview.PlaybackStatus
        
        var body: some View {
            HStack {
                Image(systemName: (self.audioPreviewPlaybackStatus == .stopped) ? "play.fill" : "stop.fill")
                    .foregroundColor(.blue)
                    .opacity(0.9)
                    .padding(5)
                    .background(Color.white)
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
    }
    
    struct ButtonBackground: View {
        let label: String
        let imageSystemName: String
        let foregroundColor: Color
        
        var body: some View {
            HStack {
                Spacer()
                Image(systemName: self.imageSystemName)
                Text(self.label)
                    .lineLimit(1)
                    .fixedSize()
                Spacer()
            }
            .foregroundColor(Color.white)
            .opacity(0.9)
            .font(Font.system(.headline, design: .rounded).weight(.semibold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .foregroundColor(self.foregroundColor))
        }
    }
}
