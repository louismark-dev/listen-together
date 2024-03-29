//
//  SongResultsView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-01.
//

import SwiftUI

struct SongResultsView: View {
    @Binding var searchResults: AppleMusicSearchResults
    @State var viewOpacity = 0.0
    
    var body: some View {
        ScrollView {
            VStack {
                ResultTypeView(forTrackResults: self.$searchResults.trackResults)
                ResultTypeView(forPlaylistResults: self.$searchResults.playlistResults)
                ResultTypeView(forAlbumResults: self.$searchResults.albumResults)
            }
            .opacity(self.viewOpacity)
            .onAppear {
                withAnimation(.linear(duration: 0.3)) {
                    self.viewOpacity = 1.0
                }
            }
        }
    }
}

enum SearchResultData {
    case album([Album])
    case track([Track])
    case playlist([Playlist])
}

//struct SongResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongResultsView()
//    }
//}
