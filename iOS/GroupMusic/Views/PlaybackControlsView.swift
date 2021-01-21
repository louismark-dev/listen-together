//
//  PlaybackControlsView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI

struct PlaybackControlsView: View {
    var body: some View {
        HStack {
            Image(systemName: "backward.fill")
                .opacity(0.9)
            ZStack {
                Circle()
                    .foregroundColor(Color("TiffanyBlue"))
                Image(systemName: "play.fill")
            }
            .frame(maxHeight: 60)
            Image(systemName: "forward.fill")
                .opacity(0.9)
        }
        .font(.largeTitle)
        .foregroundColor(.white)
        .opacity(0.9)
    }
}

struct PlaybackControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("RussianViolet")
            .ignoresSafeArea(.all, edges: .all)
            PlaybackControlsView()
                .padding()
        }
    }
}
