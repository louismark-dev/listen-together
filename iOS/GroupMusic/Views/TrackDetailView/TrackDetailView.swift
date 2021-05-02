//
//  TrackDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    let track: Track
    let socketManager: GMSockets
    
    init(withTrack track: Track, socketManager: GMSockets = GMSockets.sharedInstance) {
        self.track = track
        self.socketManager = socketManager
    }
    
    var artwork: some View {
        HStack {
            Spacer()
            if let artworkURL = self.track.attributes?.artwork.urlForMaxWidth() {
                ArtworkImageView(artworkURL: artworkURL, cornerRadius: 20)
                    .frame(maxWidth: 150, maxHeight: 150)
            }
            Spacer()
        }
    }
    
    var labels: some View {
        VStack(alignment: .center) {
            Text(self.track.attributes?.name ?? "")
                .fontWeight(.semibold)
            Text(self.track.attributes?.artistName ?? "")
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            self.artwork
            self.labels
            Spacer()
                .frame(height: 16)
            VStack(alignment: .leading, spacing: 30) {
                Cell(label: "Play Next", systemImage: "text.insert")
                    .onTapGesture {
                        self.moveToStartOfQueue()
                    }
                Cell(label: "Remove from Queue", systemImage: "xmark")
                    .onTapGesture {
                        self.removeFromQueue()
                    }
                Cell(label: "Add to Apple Music Library", systemImage: "plus")
                Cell(label: "View Details", systemImage: "info.circle")
            }
            .font(.system(.body, design: .rounded))
        }
        .foregroundColor(Color.black)
        .opacity(0.9)
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 16, trailing: 16))
    }
    
    private func moveToStartOfQueue() {
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
    
    struct Cell: View {
        let label: String
        let systemImage: String
        
        var body: some View {
            HStack {
                Image(systemName: self.systemImage)
                Text(self.label)
                    .fontWeight(.semibold)
            }
        }
    }
}

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color.purple
//                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            VStack {
//                Spacer()
//                TrackDetailView()
//            }
//        }
//    }
//}
