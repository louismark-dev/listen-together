//
//  MediaDetailView2.swift
//  GroupMusic
//
//  Created by Louis on 2021-06-12.
//

import SwiftUI

struct MediaDetailView2: View {
    @State private var loadingError: Bool = false
    @State private var album: Album?
    @State private var playlist: Playlist?
    @State private var artworkDetailColor: UIColor?
    @State private var artworkImage: Image?
    
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
    
    private var artworkTextColor1: Color? {
        if let album = self.album,
           let textColor1 = album.attributes?.artwork?.textColor1{
            return Color(hex: textColor1)
        }
        
        if let playlist = self.playlist,
           let textColor1 = playlist.attributes?.artwork?.textColor1{
            return Color(hex: textColor1)
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
    
    @ViewBuilder func backgroundColor() -> some View {
        ZStack {
            VStack {
                if let artworkImage = self.artworkImage {
                    artworkImage
                        .resizable()
                        .frame(maxWidth: 500, maxHeight: 500)
                        .rotationEffect(.degrees(90))
                        .blur(radius: 60)
                        .clipped()
                        .saturation(1.2)
                        .offset(x:0, y: -40)
                        .scaleEffect(1.6)
                }
                Spacer()
            }
            VStack {
                if let artworkImage = self.artworkImage {
                    artworkImage
                        .resizable()
                        .frame(maxWidth: 500, maxHeight: 500)
                        .opacity(0.50)
                        .blur(radius: 60)
                        .clipped()
                        .saturation(4)
                        .offset(x:0, y: -40)
                        .scaleEffect(1.6)
                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.screen)
//                        .blendMode(.screen)
//                        .blendMode(.saturation)
//                        .blendMode(.saturation)
//                        .blendMode(.lighten)
//                        .blendMode(.luminosity)


                }
                Spacer()
            }
            VStack {
                if let artworkImage = self.artworkImage {
                    artworkImage
                        .resizable()
                        .frame(maxWidth: 500, maxHeight: 500)
                        .rotationEffect(.degrees(189))
                        .opacity(0.50)
                        .blur(radius: 60)
                        .clipped()
                        .saturation(4)
                        .offset(x:0, y: 40)
                        .scaleEffect(1.6)
                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.screen)
//                        .blendMode(.screen)
//                        .blendMode(.saturation)
//                        .blendMode(.saturation)
//                        .blendMode(.lighten)
//                        .blendMode(.luminosity)


                }
                Spacer()
            }
            VStack {
                if let artworkImage = self.artworkImage {
                    artworkImage
                        .resizable()
                        .frame(maxWidth: 500, maxHeight: 500)
                        .rotationEffect(.degrees(45))
                        .opacity(0.50)
                        .blur(radius: 60)
                        .clipped()
                        .saturation(4)
                        .scaleEffect(1.6)
                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.multiply)
//                        .blendMode(.screen)
//                        .blendMode(.screen)
//                        .blendMode(.saturation)
//                        .blendMode(.saturation)
//                        .blendMode(.lighten)
//                        .blendMode(.luminosity)


                }
                Spacer()
            }
            if let artworkDetailColor = self.artworkDetailColor {
                Color(artworkDetailColor).opacity(0.2)
            }
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        }
    }
    
    @ViewBuilder func generateButton(action: @escaping ()-> Void ,imageSystemName: String, label: String) -> some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(systemName: imageSystemName)
                Text(label)
                    .lineLimit(1)
                    .fixedSize()
                Spacer()
            }
            .foregroundColor(Color.white)
            .opacity(0.9)
            .font(Font.system(.headline, design: .rounded).weight(.semibold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .foregroundColor(Color("Emerald")))
        }
    }
    
    
    @ViewBuilder func header() -> some View {
        ZStack {
            VStack {
                Spacer()
            }
            VStack {
                if let artworkURL = self.artworkURL {
                    ArtworkImageView(artworkURL: artworkURL, cornerRadius: 25)
                        .onImageAppear {(image: Image) in
                            print("The view has loaded")
                            self.getImageColors(image: image)
                            self.artworkImage = image
                        }
                        .frame(width: 200, height: 200)
                        .shadow(color: Color(self.artworkDetailColor ?? .gray), radius: 10, x: 0, y: 0)
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
                HStack(spacing: 16) {
                    self.generateButton(action: self.prependToQueue, imageSystemName: "text.insert", label: "Play Next")
                    self.generateButton(action: self.appendToQueue, imageSystemName: "text.append", label: "Play Last")
                }
                .padding(22)
            }
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

    
    var body: some View {
        ZStack {
            self.backgroundColor()
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 0) {
                    self.header()
                    if let tracks = self.tracks {
                        self.generateTracksList(for: tracks, withSpacing: 16.0)
                    }
                }
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
    
    private func getImageColors(image: Image) {
        let image = image.asUIImage()
        image.getColors { colors in
            guard let colors = colors else { return }
            self.artworkDetailColor = colors.background
            
            if let backgroundIsLight = colors.background.isLight() {
                if (backgroundIsLight) {
                    self.artworkDetailColor = colors.background
                    return
                }
            }
            
            if let detailIsLight = colors.detail.isLight() {
                if (detailIsLight) {
                    self.artworkDetailColor = colors.detail
                    return
                }
            }
            
            if let primaryIsLight = colors.primary.isLight() {
                if (primaryIsLight) {
                    self.artworkDetailColor = colors.primary
                    return
                }
            }
            
            if let secondaryIsLight = colors.secondary.isLight() {
                if (secondaryIsLight) {
                    self.artworkDetailColor = colors.secondary
                    return
                }
            }
            
            self.artworkDetailColor = colors.background
        }
    }
}
