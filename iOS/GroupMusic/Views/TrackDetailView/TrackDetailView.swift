//
//  TrackDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View {
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
                Spacer()
            }
            HStack {
                Text(self.track.attributes?.artistName ?? "")
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let artworkURL = self.track.attributes?.artwork.urlForMaxWidth() {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 20)
                        .frame(maxWidth: 120, maxHeight: 120)
                }
                self.labels
            }
            Spacer()
                .frame(maxHeight: 32)
            HStack {
                Button(action: self.moveToStartOfQueue, label: {
                    ButtonBackground(label: "Play Next",
                           imageSystemName: "text.insert",
                           foregroundColor: Color("Emerald"))
                })
                Button(action: self.removeFromQueue, label: {
                    ButtonBackground(label: "Remove",
                           imageSystemName: "xmark",
                           foregroundColor: Color("Amaranth"))
                })
            }
        }
        .foregroundColor(Color.black)
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 25))
    }
    
    private func moveToStartOfQueue() {
        self.trackDetailModalViewManager.close()
        let index = self.playerAdapter.state.queue.state.queue.firstIndex(of: self.track)
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
        let index = self.playerAdapter.state.queue.state.queue.firstIndex(of: self.track)
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
