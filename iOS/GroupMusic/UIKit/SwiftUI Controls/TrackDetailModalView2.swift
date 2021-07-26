//
//  TrackDetailModalView.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-25.
//

import SwiftUI

struct TrackDetailModalView2: View {
    @ObservedObject var trackDetailModalViewModel: TrackDetailModalViewModel
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.green)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            self.labels(withTrackName: self.trackDetailModalViewModel.track?.attributes?.name,
                        artistName: self.trackDetailModalViewModel.track?.attributes?.artistName)
        }
        
    }
    
    @ViewBuilder func labels(withTrackName trackName: String?, artistName: String?) -> some View {
        VStack {
            HStack {
                Text(trackName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Spacer()
            }
            HStack {
                Text(artistName ?? "")
                    .fontWeight(.semibold)
                    .opacity(0.6)
                Spacer()
            }
        }
        .font(.system(.headline, design: .rounded))
    }
}

struct TrackDetailModalView2_Previews: PreviewProvider {
    static var previews: some View {
        TrackDetailModalView2(trackDetailModalViewModel: TrackDetailModalViewModel())
            .background(Color.red)
    }
}
