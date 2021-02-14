//
//  PreviewView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-01.
//

import SwiftUI
import URLImage

struct PreviewView: View {
    let audioPreviewPlayer: AudioPreview
    var previewTrack: Track
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @ObservedObject private var socketManager: GMSockets
    @EnvironmentObject var trackPreviewController: TrackPreviewController
    
    init(previewTrack: Track,
         audioPreviewPlayer: AudioPreview = AudioPreview(),
         socketManager: GMSockets = GMSockets.sharedInstance) {
        self.previewTrack = previewTrack
        self.audioPreviewPlayer = audioPreviewPlayer
        if let previewURL = self.previewTrack.attributes?.previews.first?.url {
            self.audioPreviewPlayer.setAudioStreamURL(audioStreamURL: previewURL)
        }
        self.socketManager = socketManager
    }
    
    private let radius: CGFloat = CGFloat(6.0)
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.001) // Appears transparent, but also accepts touch events
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    self.trackPreviewController.closeTrackPreview()
                }
            VStack {
                Spacer()
                HStack {
                    if let artworkURL = self.previewTrack.attributes?.artwork.urlForMaxWidth() {
                        URLImage(url: artworkURL, content: { (image: Image) in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        })
                            .frame(maxWidth: 100)
                            .cornerRadius(self.radius)
                    }
                    VStack(alignment: .leading) {
                        Text(self.previewTrack.attributes?.name ?? "---")
                            .font(.headline)
                        Text(self.previewTrack.attributes?.artistName ?? "---")
                            .font(.subheadline)
                            .opacity(0.8)
                    }
                    Spacer()
                    Button(action: { self.playPreview() }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40, weight: .thin))
                    }
                }
                .padding()
                .background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                                .cornerRadius(self.radius))
                VStack {
                    Button(action: self.prependToQueue) {
                        HStack {
                            Text("Play Next")
                            Spacer()
                            Image(systemName: "text.insert")
                        }
                        .font(.headline)
                        .padding()
                    }

                    Divider()
                    Button(action: self.appendToQueue) {
                        HStack {
                            Text("Play Later")
                            Spacer()
                            Image(systemName: "text.append")
                        }
                        .font(.headline)
                        .padding()
                    }
                }
                .background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                                .cornerRadius(self.radius))
            }
            .padding()
        }
    }

    private func playPreview() {
        if self.audioPreviewPlayer.ready {
            do {
                try self.audioPreviewPlayer.play()
            } catch {
                print("Could not play audio preview: \(error)")
            }
        }
    }
    
    /// Inserts the media item defined into the current queue immediately after the currently playing media item.
    private func prependToQueue() {
        self.trackPreviewController.closeTrackPreview()
        // IF OBSERVER
        if (self.socketManager.state.isCoordinator == false) {
            self.emitPrependToQueueEvent(withTracks: [self.previewTrack])
        }
        
        // IF COORDINATOR
        if (self.socketManager.state.isCoordinator == true) {
            self.playerAdapter.prependToQueue(withTracks: [self.previewTrack], completion: { // TODO: No Instances of player adapter?
                self.emitPrependToQueueEvent(withTracks: [self.previewTrack])
            })
        }
    }
    
    /// Inserts the media items defined into the current queue immediately after the currently playing media item.
    private func appendToQueue() {
        self.trackPreviewController.closeTrackPreview()
        // IF OBSERVER
        if (self.socketManager.state.isCoordinator == false) {
            self.emitAppendToQueueEvent(withTracks: [self.previewTrack])
        }
        
        // IF COORDINATOR
        if (self.socketManager.state.isCoordinator == true) {
            self.playerAdapter.appendToQueue(withTracks: [self.previewTrack], completion: {
                self.emitAppendToQueueEvent(withTracks: [self.previewTrack])
            })
        }
    }
    
    private func emitPrependToQueueEvent(withTracks tracks: [Track]) {
        do {
            try self.socketManager.emitPrependToQueueEvent(withTracks: tracks)
        } catch {
            print("Emit failed \(error.localizedDescription)")
        }
    }
    
    private func emitAppendToQueueEvent(withTracks tracks: [Track]) {
        do {
            try self.socketManager.emitAppendToQueueEvent(withTracks: tracks)
        } catch {
            print("Emit failed \(error.localizedDescription)")
        }
    }
}

//struct PreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewView()
//            .previewLayout(.sizeThatFits)
//    }
//}
