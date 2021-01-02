//
//  AppleMusicView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import SwiftUI

struct AppleMusicView: View {
    let appleMusicManager: GMAppleMusic
    @State var songResults: [Track] = []
    @State private var showPreview: Bool = false
    @State private var previewTrack: Track? // Track to be previews

    var body: some View {
        ZStack {
            Button(String("Search for Young Thug")) {
                self.searchForYoungThug()
            }
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
    }
    
    init(appleMusicManager: GMAppleMusic = GMAppleMusic(storefront: .canada)) {
        self.appleMusicManager = appleMusicManager
    }
    
    private func searchForYoungThug() {
        self.appleMusicManager.search(term: "Young Thug", limit: 10) { (results: SearchResults?, error: Error?) in
            if let error = error {
                print("ERROR: Could not retrive search results: \(error)")
                return
            }
            guard let results = results else {
                print("ERROR: Could not retrive search results")
                return
            }
            if let songs = results.songs?.data {
                print("WE HAVE SONG DATA:")
                print(songs)
                self.songResults = songs
            }
            print("WE DID IT")
        }
    }
}

struct AppleMusicView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicView()
    }
}
