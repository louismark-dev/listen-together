//
//  QueueView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI

struct QueueView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter

    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.playerAdapter.state.queue.state.queue) { (track: Track) in
                    // TODO: Handle case where attributes is null
                    if let attributes = track.attributes {
                        QueueCell(songName: attributes.name,
                                  artistName: attributes.artistName,
                                  artworkURL: attributes.artwork.url(forWidth: 400),
                                  expanded: false)
                    }
                }
            }
        }
    }
}

//struct QueueView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueueView(selectedCell: .constant(0), queueItems: [
//            SampleData(artistName: "DaBaby", songName: "Practice", artworkName: "DaBaby"),
//            SampleData(artistName: "Lil Nas X", songName: "Holiday", artworkName: "LilNasX"),
//            SampleData(artistName: "NAV", songName: "Friends & Family", artworkName: "NAV"),
//            SampleData(artistName: "Juice WRLD & Young Thug", songName: "Bad Boy", artworkName: "YoungThug")
//        ])
//    }
//}
