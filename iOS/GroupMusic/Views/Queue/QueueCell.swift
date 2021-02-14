//
//  QueueCell.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI
import URLImage

struct QueueCell: View {
    var songName: String
    var artistName: String
    var artworkURL: URL?
    let indexInQueue: Int
    let height: Height
    @State var expanded: Bool = false
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                if let artworkURL = self.artworkURL {
                    URLImage(url: artworkURL, content: { (image: Image) in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                VStack(alignment: .leading, spacing: 2) {
                    if (expanded) {
                        Text("Now Playing")
                            .font(.custom("Arial Rounded MT Bold", size: 16, relativeTo: .title2))
                            .opacity(0.7)
                            .foregroundColor(Color("LavenderWeb"))
                    }
                    Text(songName)
                        .opacity(0.9)
                    Text(artistName)
                        .font(.custom("Arial Rounded MT Bold", size: 16, relativeTo: .title2))
                        .opacity(0.7)
                }
                .font(.custom("Arial Rounded MT Bold", size: (self.expanded ? 22 : 18), relativeTo: .title))
                .foregroundColor(.white)
                Spacer()
            }
        }
        .padding()
        .frame(height: expanded ? self.height.expanded : self.height.collapsed)
        .background(QueueCellBackground(artworkURL: self.artworkURL, expanded: $expanded))
        .onChange(of: self.playerAdapter.state.queue.state.indexOfNowPlayingItem) { (indexOfNowPlayingItem: Int) in
            withAnimation {
                self.expanded = (indexOfNowPlayingItem == indexInQueue)
            }
        }
        .onAppear {
            self.expanded = (self.playerAdapter.state.queue.state.indexOfNowPlayingItem == indexInQueue)
        }
    }
    
    struct Height {
        let expanded: CGFloat
        let collapsed: CGFloat
    }
}

//struct QueueCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color("RussianViolet")
//            QueueCell(artistName: "Juice WRLD & Young Thug", songName: "Bad Boy", artworkName: "YoungThug")
//                .padding()
//                .previewLayout(.sizeThatFits)
//        }
//    }
//}
