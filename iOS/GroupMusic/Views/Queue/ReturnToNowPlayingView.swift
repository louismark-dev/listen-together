//
//  ReturnToNowPlayingView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-02-13.
//

import SwiftUI

struct ReturnToNowPlayingView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .foregroundColor(Color.blue)
                        .imageScale(.large)
                }
                VStack(alignment: .center) {
                    Text("Return to Now Playing")
                        .fontWeight(.semibold)
                        .opacity(0.8)
                    if let artistName = self.playerAdapter.state.queue.state.nowPlayingItem?.attributes?.artistName,
                       let name = self.playerAdapter.state.queue.state.nowPlayingItem?.attributes?.name {
                        Text("\(name) - \(artistName)")
                            .fontWeight(.semibold)
                            .opacity(0.6)
                    }
                }
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.black)
            }
            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
            .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .foregroundColor(.white))
        }
    }
}

struct ReturnToNowPlayingView_Previews: PreviewProvider {
    @State static var showBanner: Bool = true
    
    static var previews: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()
            VStack {
                if (showBanner) {
                    ReturnToNowPlayingView()
                        .frame(width: 300, height: 44)
                        .animation(.spring())
                }
                Spacer()
            }
        }
        .onTapGesture {
            self.showBanner = false
        }
        
    }
}
