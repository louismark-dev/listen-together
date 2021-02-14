//
//  AppleMusicView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import SwiftUI

struct AppleMusicSearchView: View {
    @ObservedObject var trackPreviewController: TrackPreviewController = TrackPreviewController()
    @EnvironmentObject var playerAdapter: PlayerAdapter

    var body: some View {
        ZStack {
            InnerView()
                .zIndex(0)
            if (self.trackPreviewController.track != nil) {
                if let previewTrack = self.trackPreviewController.track {
                    PreviewView(previewTrack: previewTrack)
                        .environmentObject(self.playerAdapter)
                        .zIndex(1) // zIndex necessary for removal animation
                        .transition(.move(edge: .bottom))

                }
            }
        }
        .environmentObject(self.trackPreviewController)
    }
    
    struct InnerView: View {
        @State private var searchTerm: String = ""
        @State var songResults: [Track] = []
        @State private var results: SearchResults? = nil
        @State private var searchResults: AppleMusicSearchResults = AppleMusicSearchResults()
        @EnvironmentObject var previewTrack: TrackPreviewController
        let appleMusicManager: GMAppleMusic
        
        init(appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
            self.appleMusicManager = appleMusicManager
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                        TextField("Search...",
                                  text: self.$searchTerm,
                                  onEditingChanged: {_ in },
                                  onCommit: self.newSearch )
                            .disableAutocorrection(true)
                            .padding([.top, .horizontal])
                        Spacer()
                        if (self.searchResults.hasResult == true) {
                            SongResultsView(searchResults: self.$searchResults)
                                .environmentObject(previewTrack)
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
        
        private func newSearch() {
            self.appleMusicManager.search(term: self.searchTerm, limit: 10) { (results: SearchResults?, error: Error?) in
                if let error = error {
                    print("ERROR: Could not retrive search results: \(error)")
                    // TODO: Show error in UI
                    return
                }
                guard let results: SearchResults = results else {
                    print("ERROR: Could not retrive search results")
                    // TODO: Show error in UI
                    return
                }
                self.searchResults.updateWithSearchResults(results)
            }
        }
    }
}

struct AppleMusicSearchResults {
    var albumResults: [Album]?
    var playlistResults: [Playlist]?
    var trackResults: [Track]?
    var hasResult: Bool {
        return ((self.albumResults?.count ?? 0) > 0 || (self.playlistResults?.count ?? 0) > 0 || (self.trackResults?.count ?? 0) > 0)
    }
    
    public mutating func updateWithSearchResults(_ results: SearchResults) {
        self.invalidateResults()
        
        if let albumsResponse = results.albums {
            if let errors = albumsResponse.errors {
                print("ERROR: There was a problem with the search result for albums: \(errors)")
            } else {
                self.albumResults = albumsResponse.data
            }
        }
        
        if let playlistsReponse = results.playlists {
            if let errors = playlistsReponse.errors {
                print("ERROR: There was a problem with the search result for playlists: \(errors)")
            } else {
                self.playlistResults = playlistsReponse.data
            }
        }
        
        if let tracksResponse = results.songs {
            if let errors = tracksResponse.errors {
                print("ERROR: There was a problem with the search result for tracks: \(errors)")
            } else {
                self.trackResults = tracksResponse.data
            }
        }
    }
    
    private mutating func invalidateResults() {
        self.albumResults = nil
        self.playlistResults = nil
        self.trackResults = nil
    }
}

class TrackPreviewController: ObservableObject {
    @Published var track: Track? = nil
    
    public func openTrackPreview(withTrack track: Track) {
        withAnimation {
            self.track = track
        }
    }
    
    public func closeTrackPreview() {
        withAnimation {
            self.track = nil
        }
    }
}

struct AppleMusicView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicSearchView()
    }
}
