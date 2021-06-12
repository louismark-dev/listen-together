//
//  TrackCellView.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-07.
//

import SwiftUI

struct TrackCellView: View {
    let track: Track
    
    var body: some View {
        HStack {
            if let artworkURL = self.track.attributes?.artwork.url(forWidth: Int(44 * UIScreen.main.scale)) {
                ArtworkImageView(artworkURL: artworkURL, cornerRadius: 8)
                    .frame(width: 60, height: 60)
            }
            VStack(spacing: 4) {
                HStack {
                    Text(self.track.attributes?.name ?? "")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .opacity(0.9)
                    Spacer()
                }
                HStack {
                    Text(self.track.attributes?.artistName ?? " ")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .opacity(0.7)
                    Spacer()
                }
            }
            .lineLimit(1)
        }
    }
}

//struct TrackCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackCellView()
//            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
//            .frame(height: 66)
//    }
//}
