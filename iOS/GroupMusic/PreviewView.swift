//
//  PreviewView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-01.
//

import SwiftUI

struct PreviewView: View {
    let audioPreviewPlayer: AudioPreview
    var previewTrack: Track
    @ObservedObject var appleMusicQueue: GMAppleMusicQueue // TODO: This should not be a dependency of this struct
    
    init(previewTrack: Track,
         audioPreviewPlayer: AudioPreview = AudioPreview(),
         appleMusicQueue: GMAppleMusicQueue = GMAppleMusicQueue.sharedInstance) {
        self.previewTrack = previewTrack
        self.audioPreviewPlayer = audioPreviewPlayer
        if let previewURL = self.previewTrack.attributes?.previews.first?.url {
            self.audioPreviewPlayer.setAudioStreamURL(audioStreamURL: previewURL)
        }
        self.appleMusicQueue = appleMusicQueue
    }
    
    private let radius: CGFloat = CGFloat(6.0)
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image("so_much_fun")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 100)
                    .cornerRadius(self.radius)
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
        self.appleMusicQueue.prepend(track: self.previewTrack)
    }
    
    /// Inserts the media items defined into the current queue immediately after the currently playing media item.
    private func appendToQueue() {
        self.appleMusicQueue.append(track: self.previewTrack)
    }
}

//struct PreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewView()
//            .previewLayout(.sizeThatFits)
//    }
//}
