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
    @State var expanded: Bool = false
    
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
        .frame(height: expanded ? 140 : 80)
        .background(QueueCellBackground(artworkURL: self.artworkURL, expanded: $expanded))
        .onTapGesture {
            withAnimation {
                self.expanded.toggle()
            }
        }
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
