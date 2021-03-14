//
//  TrackDetailModalView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-13.
//

import SwiftUI

struct TrackDetailModalView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ArtworkView()
            VStack(alignment: .leading, spacing: 20) {
                Cell(label: "Play Next", systemImage: "text.insert")
                Cell(label: "Delete from Queue", systemImage: "xmark")
                Cell(label: "Add to Apple Music Library", systemImage: "plus")
                Cell(label: "View Details", systemImage: "info.circle")
            }
            .font(.system(.body, design: .rounded))
        }
        .padding()
        .background(
            Color.green
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
        )
    }
    
    struct ArtworkView: View {
        var body: some View {
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

struct TrackDetailModalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Spacer()
                TrackDetailModalView()
            }
        }
    }
}
