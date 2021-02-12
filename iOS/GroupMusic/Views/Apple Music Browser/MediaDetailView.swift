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
    private let appleMusicManager: GMAppleMusic
    
    init(withAlbum album: Album,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.appleMusicManager = appleMusicManager
        self._album = State(initialValue: album)
        self._playlist = State(initialValue: nil)
    }
    
    init(withPlaylist playlist: Playlist,
         appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.appleMusicManager = appleMusicManager
        self._album = State(initialValue: nil)
        self._playlist = State(initialValue: playlist)
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
