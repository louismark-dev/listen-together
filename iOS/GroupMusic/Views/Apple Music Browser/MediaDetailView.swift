//
//  MediaDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-07.
//

import SwiftUI

struct MediaDetailView: View {
    @State private var loadingError: Bool = false
    @State private var album: Album?
    @State private var playlist: Playlist?
    @EnvironmentObject var trackPreviewController: TrackPreviewController
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @ObservedObject private var socketManager: GMSockets
    private let appleMusicManager: GMAppleMusic
    
    private var artworkURL: URL? {
        if let album = self.album {
            return album.attributes?.artwork?.url(forWidth: Int(200 * UIScreen.main.scale))
        }
        
        if let playlist = self.playlist {
            return playlist.attributes?.artwork?.url(forWidth: Int(200 * UIScreen.main.scale))
        }
        return nil
    }
    
    private var name: String? {
        if let album = self.album {
            return album.attributes?.name
        }
        
        if let playlist = self.playlist {
            return playlist.attributes?.name
        }
        return nil
    }
    
    private var creatorName: String? {
        if let album = self.album {
            return album.attributes?.artistName
        }
        
        if let playlist = self.playlist {
            return playlist.attributes?.curatorName
        }
        return nil
    }
    
    private var tracks: [Track]? {
        if let album = self.album {
            return album.relationships?.tracks.data
        }
        
        if let playlist = self.playlist {
            if let tracks = playlist.relationships?.tracks.data {
                return tracks
            } else {
                if (loadingError == false) {
                    self.appleMusicManager.fetch(playlist: playlist) { (playlist: [Playlist]?, error: Error?) in
                        if ((playlist?[0] == nil) || (error != nil)) {
                            self.loadingError = true
                        }
                        self.playlist = playlist?[0]
                    }
                }
            }
        }
        return nil
    }
    
    init(withAlbum album: Album) {
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self._album = State(initialValue: album)
        self._playlist = State(initialValue: nil)
        self.socketManager = GMSockets.sharedInstance
    }
    
    init(withPlaylist playlist: Playlist) {
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self._album = State(initialValue: nil)
        self._playlist = State(initialValue: playlist)
        self.socketManager = GMSockets.sharedInstance
    }
    
    var body: some View {
        VStack {
            HStack {
                if let artworkURL = self.artworkURL {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 11)
                        .aspectRatio(contentMode: .fit)
                }
                VStack {
                    HStack {
                        Text(self.name ?? "")
                        Spacer()
                    }
                    HStack {
                        Text(self.creatorName ?? "")
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
                    if let tracks = self.tracks {
                        ForEach(tracks) { (track: Track) in
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
