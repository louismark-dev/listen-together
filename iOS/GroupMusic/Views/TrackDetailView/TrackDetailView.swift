//
//  TrackDetailModalView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailView: View {
    
    var artwork: some View {
        HStack {
            Spacer()
            Image("DaBaby")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 150)
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Spacer()
        }
    }
    
    var labels: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("Song Title")
                Text("Artist")
            }
            Spacer()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            self.artwork
            self.labels
            VStack(alignment: .leading, spacing: 20) {
                Cell(label: "Play Next", systemImage: "text.insert")
                Cell(label: "Delete from Queue", systemImage: "xmark")
                Cell(label: "Add to Apple Music Library", systemImage: "plus")
                Cell(label: "View Details", systemImage: "info.circle")
            }
            .font(.system(.body, design: .rounded))
        }
        .padding()
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

struct TrackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Spacer()
                TrackDetailView()
            }
        }
    }
}
