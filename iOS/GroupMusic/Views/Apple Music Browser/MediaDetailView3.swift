//
//  MediaDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-07.
//

import SwiftUI

struct MediaDetailView3: View {
    @State private var loadingError: Bool = false
    @State private var album: Album?
    @State private var playlist: Playlist?
    @State private var albumImage: Image?
    @State private var artworkDetailColor: Color?
    
    @EnvironmentObject var trackDetailModalViewManager: TrackDetailModalViewManager
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
        
        self.setNavigationBarAppearance()
    }
    
    init(withPlaylist playlist: Playlist) {
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self._album = State(initialValue: nil)
        self._playlist = State(initialValue: playlist)
        self.socketManager = GMSockets.sharedInstance
        
        self.setNavigationBarAppearance()
    }
    
    private func setNavigationBarAppearance() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    var header: some View {
        HStack(spacing: 12) {
            if let artworkURL = self.artworkURL {
                ArtworkImageView(artworkURL: artworkURL, cornerRadius: 16)
                    .onImageAppear(perform: { (image: Image) in
                        self.albumImage = image
                    })
                    .aspectRatio(contentMode: .fit)
            }
            VStack(spacing: 8) {
                HStack {
                    Text("Playlist")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .opacity(0.5)
                    Spacer()
                }
                HStack {
                    Text(self.name ?? "")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .opacity(0.9)
                    Spacer()
                }
                HStack {
                    Text("94 Tracks")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .opacity(0.5)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder func generateTracksList(for tracks: [Track]) -> some View {
        ForEach(tracks) { (track: Track) in
            TrackCellView(track: track)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.trackDetailModalViewManager.open(withConfiguration: TrackDetailModalViewConfiguration(track: track,
                                                                                                               trackIsInQueue: false,
                                                                                                               buttonConfiguration: ButtonConfigurationNotInQueue()))
                }
            Divider()
        }
    }
    
    @ViewBuilder func generateTracksList(for tracks: [Track], withSpacing spacing: CGFloat) -> some View {
        ForEach(tracks) { (track: Track) in
            ZStack {
                Color(hex: "#121212")
                    .edgesIgnoringSafeArea(.all)
                TrackCellView(track: track)
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.trackDetailModalViewManager.open(withConfiguration: TrackDetailModalViewConfiguration(track: track,
                                                                                                                   trackIsInQueue: false,
                                                                                                                   buttonConfiguration: ButtonConfigurationNotInQueue()))
                    }
                    .padding(.vertical, spacing/2)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder func captions() -> some View {
        VStack(spacing: 0) {
            Text(self.name ?? "")
                .foregroundColor(Color.white)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .opacity(0.9)
            Text("Playlist - 94 Tracks")
                .foregroundColor(Color.white)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .opacity(0.5)
        }
    }

    
    
    @ViewBuilder func scrollView() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if let artworkURL = self.artworkURL {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 25)
                        .onImageAppear {(image: Image) in
                            print("The view has loaded")
                            withAnimation(.linear(duration: 5.0)) {
                                self.getImageColors(image: image)
                            }
                            self.albumImage = image
                        }
                        .frame(width: 200, height: 200)
                        .shadow(color: (self.artworkDetailColor ?? .white), radius: 10, x: 0, y: 0)
                }
                self.captions()
                    .padding(.vertical, 32)
                if let tracks = self.tracks {
                    self.generateTracksList(for: tracks, withSpacing: 16.0)
                }
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            MediaDetailViewGradient(image: self.$albumImage, tintColor: self.$artworkDetailColor)
            self.scrollView()
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
    
    private func getImageColors(image: Image) {
        let image = image.asUIImage()
        image.getColors { colors in
            guard let colors = colors else { return }
            self.artworkDetailColor = Color(colors.background)
            
            if let backgroundIsLight = colors.background.isLight() {
                if (backgroundIsLight) {
                    self.artworkDetailColor = Color(colors.background)
                    return
                }
            }
            
            if let detailIsLight = colors.detail.isLight() {
                if (detailIsLight) {
                    self.artworkDetailColor = Color(colors.detail)
                    return
                }
            }
            
            if let primaryIsLight = colors.primary.isLight() {
                if (primaryIsLight) {
                    self.artworkDetailColor = Color(colors.primary)
                    return
                }
            }
            
            if let secondaryIsLight = colors.secondary.isLight() {
                if (secondaryIsLight) {
                    self.artworkDetailColor = Color(colors.secondary)
                    return
                }
            }
            
            self.artworkDetailColor = Color(colors.background)
        }
    }
}

//struct MediaDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaDetailView()
//    }
//}
