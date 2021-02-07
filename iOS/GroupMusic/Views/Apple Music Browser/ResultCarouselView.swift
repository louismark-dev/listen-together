//
//  ResultCarouselView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-02.
//

import SwiftUI

struct ResultCarouselView: View {
    @Binding var albumResults: [Album]?
    @Binding var playlistResults: [Playlist]?
    @Binding var trackResults: [Track]?
    @State private var cardWidth: CGFloat = 0.0
    
    init(forAlbumResults albumResults: Binding<[Album]?>) {
        self._albumResults = albumResults
        self._playlistResults = .constant(nil)
        self._trackResults = .constant(nil)
    }
    
    init(forPlaylistResults playlistResults: Binding<[Playlist]?>) {
        self._albumResults = .constant(nil)
        self._playlistResults = playlistResults
        self._trackResults = .constant(nil)
    }
    
    init(forTrackResults trackResults: Binding<[Track]?>) {
        self._albumResults = .constant(nil)
        self._playlistResults = .constant(nil)
        self._trackResults = trackResults
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0.0) {
                if (self.albumResults != nil && (self.albumResults?.count ?? 0) > 0) {
                    ForEach(self.albumResults!) { (albumData: Album) in
                        // TODO: Result type label (in ResultTypeView) will still appear even if none of the resutls have any attributes
                        if let attributes = albumData.attributes {
                            MediaCardView(withHeadline: attributes.name, subheadline: attributes.artistName, artwork: attributes.artwork, maxWidth: self.cardWidth)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                else if (self.playlistResults != nil && (self.playlistResults?.count ?? 0) > 0) {
                    ForEach(self.playlistResults!) { (playlistData: Playlist) in
                        // TODO: Result type label (in ResultTypeView) will still appear even if none of the resutls have any attributes
                        if let attributes: PlaylistAttributes = playlistData.attributes {
                            MediaCardView(withHeadline: attributes.name, subheadline: attributes.curatorName, artwork: attributes.artwork, maxWidth: self.cardWidth)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                else if (self.trackResults != nil && (self.trackResults?.count ?? 0) > 0) {
                    ForEach(self.trackResults!) { (trackData: Track) in
                        // TODO: Result type label (in ResultTypeView) will still appear even if none of the resutls have any attributes
                        if let attributes = trackData.attributes {
                            MediaCardView(withHeadline: attributes.name, subheadline: attributes.artistName, artwork: attributes.artwork, maxWidth: self.cardWidth, previewTrackData: trackData)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .overlay(GeometryReader { (geometry: GeometryProxy) in
            Color.clear
                .onAppear {
                    self.setCardViewWidth(carouselViewWidth: geometry.size.width)
                }
        })
    }
    
    private func setCardViewWidth(carouselViewWidth width: CGFloat) {
        self.cardWidth = width / 2.5
    }
        
}

//struct ResultCarouselView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultCarouselView()
//    }
//}
