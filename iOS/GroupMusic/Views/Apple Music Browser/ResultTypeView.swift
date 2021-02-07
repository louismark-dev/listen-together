//
//  ResultTypeView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-02.
//

import SwiftUI

struct ResultTypeView: View {
    @State var mediaTypeString = ""
    @Binding var albumResults: [Album]?
    @Binding var playlistResults: [Playlist]?
    @Binding var trackResults: [Track]?
    
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
        if (self.trackResults != nil && (self.trackResults?.count ?? 0) > 0) {
            VStack {
                VStack {
                    HStack {
                        Text("Songs")
                            .font(.custom("Arial Rounded MT Bold", size: 30, relativeTo: .largeTitle))
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    ResultCarouselView(forTrackResults: self.$trackResults)
                }
            }
            
        } else if (self.albumResults != nil && (self.albumResults?.count ?? 0) > 0) {
            VStack {
                VStack {
                    HStack {
                        Text("Albums")
                            .font(.custom("Arial Rounded MT Bold", size: 30, relativeTo: .largeTitle))
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    ResultCarouselView(forAlbumResults: self.$albumResults)
                }
            }
        }
        else if (self.playlistResults != nil && (self.playlistResults?.count ?? 0) > 0) {
            VStack {
                VStack {
                    HStack {
                        Text("Playlists")
                            .font(.custom("Arial Rounded MT Bold", size: 30, relativeTo: .largeTitle))
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    ResultCarouselView(forPlaylistResults: self.$playlistResults)
                }
            }
        }
    }
}

//struct ResultTypeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultTypeView()
//    }
//}
