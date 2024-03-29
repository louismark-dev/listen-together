//
//  AppleMusicView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import SwiftUI

struct AppleMusicSearchView: View {
    let appleMusicManager: GMAppleMusic
    @State var songResults: [Track] = []
    @State private var showPreview: Bool = false
    @State private var previewTrack: Track? // Track to be previews
    @State private var searchTerm: String = ""

    var body: some View {
        ZStack {
            TextField("Search...",
                      text: self.$searchTerm,
                      onEditingChanged: {_ in },
                      onCommit: self.search )
            VStack(alignment: .leading) {
                ForEach(songResults, id: \.self) { songResult in
                    ResultCardView(result: songResult)
                        .onTapGesture {
                            self.previewTrack = songResult
                            withAnimation {
                                self.showPreview = true
                            }
                        }
                }
            }
            if (showPreview) {
                if let previewTrack = self.previewTrack {
                    PreviewView(previewTrack: previewTrack)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .padding()
    }
    
    init(appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.appleMusicManager = appleMusicManager
    }
    
    private func search() {
        self.appleMusicManager.search(term: self.searchTerm, limit: 10) { (results: SearchResults?, error: Error?) in
            if let error = error {
                print("ERROR: Could not retrive search results: \(error)")
                return
            }
            guard let results = results else {
                print("ERROR: Could not retrive search results")
                return
            }
            if let songs = results.songs?.data {
                self.songResults = songs
            }
            print("WE DID IT")
        }
    }
}

struct AppleMusicView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicSearchView()
    }
}
