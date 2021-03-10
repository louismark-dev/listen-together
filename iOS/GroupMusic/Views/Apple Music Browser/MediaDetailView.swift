//
//  MediaDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-07.
//

import SwiftUI

struct MediaDetailView: View {
    @State private var album: Album?
    @State private var playlist: Playlist?
    @EnvironmentObject var trackPreviewController: TrackPreviewController
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @ObservedObject private var socketManager: GMSockets
    private let appleMusicManager: GMAppleMusic
    
    init(withAlbum album: Album,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada),
         socketManager: GMSockets = GMSockets.sharedInstance) {
        self.appleMusicManager = appleMusicManager
        self._album = State(initialValue: album)
        self._playlist = State(initialValue: nil)
        self.socketManager = socketManager
    }
    
    init(withPlaylist playlist: Playlist,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada),
         socketManager: GMSockets = GMSockets.sharedInstance) {
        self.appleMusicManager = appleMusicManager
        self._album = State(initialValue: nil)
        self._playlist = State(initialValue: playlist)
        self.socketManager = socketManager
    }
    
    var body: some View {
        VStack {
            HStack {
                if let artworkURL = self.album?.attributes?.artwork?.url(forWidth: Int(200 * UIScreen.main.scale)) {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 11)
                        .aspectRatio(contentMode: .fit)
                }
                VStack {
                    HStack {
                        Text(self.album?.attributes?.name ?? "")
                        Spacer()
                    }
                    HStack {
                        Text(self.album?.attributes?.artistName ?? "")
                        Spacer()
                    }
                }
            }
            .frame(height: 200)
            .padding()
            HStack {
                Button("Prepend", action: self.prependToQueue)
                Button("Append", action: self.appendToQueue)
            }
            ScrollView {
                VStack {
                    if let playlistTracks = self.playlist?.relationships?.tracks.data {
                        ForEach(playlistTracks) { (track: Track) in
                            TrackCellView(track: track)
                        }
                    }
                    if let albumTracks = self.album?.relationships?.tracks.data {
                        ForEach(albumTracks) { (track: Track) in
                            TrackCellView(track: track)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.trackPreviewController.openTrackPreview(withTrack: track)
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            self.fetchTracks()
        }
    }
    
    private func prependToQueue() {
        let tracks: [Track]? = {
            if let albumTracks = self.album?.relationships?.tracks.data {
                return albumTracks
            }
            if let playlistTracks = self.playlist?.relationships?.tracks.data {
                return playlistTracks
            }
            return nil
        }()
        
        if let tracks = tracks {
            if (self.socketManager.state.isCoordinator == false) {
                self.emitPrependToQueueEvent(withTracks: tracks)
            }
            
            if (self.socketManager.state.isCoordinator == true) {
                self.playerAdapter.prependToQueue(withTracks: tracks, completion: {
                    self.emitPrependToQueueEvent(withTracks: tracks)
                })
            }
        }
    }
    
    private func appendToQueue() {
        let tracks: [Track]? = {
            if let albumTracks = self.album?.relationships?.tracks.data {
                return albumTracks
            }
            if let playlistTracks = self.playlist?.relationships?.tracks.data {
                return playlistTracks
            }
            return nil
        }()
        
        if let tracks = tracks {
            if (self.socketManager.state.isCoordinator == false) {
                self.emitAppendToQueueEvent(withTracks: tracks)
            }
            
            if (self.socketManager.state.isCoordinator == true) {
                self.playerAdapter.appendToQueue(withTracks: tracks, completion: {
                    self.emitAppendToQueueEvent(withTracks: tracks)
                })
            }
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
    
    private func fetchTracks() {
        if let album = self.album {
            self.appleMusicManager.fetch(album: album) { (albums: [Album]?, error: Error?) in
                if let album: Album = albums?[0] {
                    self.album = album
                }
            }
        }
    }
}

//struct MediaDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaDetailView()
//    }
//}
