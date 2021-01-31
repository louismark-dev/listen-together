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
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(self.playerAdapter.state.queue.state.queue, id: \.id) { (track: Track) in
                        // TODO: Handle case where attributes is null
                        if let attributes = track.attributes {
                            QueueCell(songName: attributes.name,
                                      artistName: attributes.artistName,
                                      artworkURL: attributes.artwork.url(forWidth: 400),
                                      indexInQueue: self.playerAdapter.state.queue.state.queue.firstIndex(of: track)!,
                                      expanded: false)
                                .id(track)
//                                .animation(Animation.default.speed(1))
                        }
                    }
                }
            }
            .onChange(of: self.playerAdapter.state.queue.state.indexOfNowPlayingItem) { (indexOfNowPlayingItem: Int) in
                withAnimation {
                    scrollView.scrollTo(self.playerAdapter.state.queue.state.queue[indexOfNowPlayingItem], anchor: .top)
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
