//
//  TrackDetailView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View {
    
    let track: Track
    
    init(withTrack track: Track) {
        self.track = track
    }
    
    var artwork: some View {
        HStack {
            Spacer()
            if let artworkURL = self.track.attributes?.artwork.urlForMaxWidth() {
                ArtworkImageView(artworkURL: artworkURL, cornerRadius: 20)
                    .frame(maxWidth: 150, maxHeight: 150)
            }
            Spacer()
        }
    }
    
    var labels: some View {
        VStack(alignment: .center) {
            Text(self.track.attributes?.name ?? "")
                .fontWeight(.semibold)
            Text(self.track.attributes?.artistName ?? "")
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            self.artwork
            self.labels
            Spacer()
                .frame(height: 16)
            VStack(alignment: .leading, spacing: 30) {
                Cell(label: "Play Next", systemImage: "text.insert")
                Cell(label: "Remove from Queue", systemImage: "xmark")
                Cell(label: "Add to Apple Music Library", systemImage: "plus")
                Cell(label: "View Details", systemImage: "info.circle")
            }
            .font(.system(.body, design: .rounded))
        }
        .foregroundColor(Color.black)
        .opacity(0.9)
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 16, trailing: 16))
    }
    
    struct Cell: View {
        let label: String
        let systemImage: String
        
        var body: some View {
            HStack {
                Image(systemName: self.systemImage)
                Text(self.label)
                    .fontWeight(.semibold)
            }
        }
    }
}

//struct TrackDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color.purple
//                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            VStack {
//                Spacer()
//                TrackDetailView()
//            }
//        }
//    }
//}
