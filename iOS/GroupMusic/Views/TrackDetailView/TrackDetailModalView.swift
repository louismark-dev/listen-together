//
//  TrackDetailModalView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import SwiftUI

struct TrackDetailModalView: View {
    @State var contentHeight: CGFloat = 500
    @EnvironmentObject var trackDetailModalViewManager: TrackDetailModalViewManager
    
    var geometryReader: some View {
        GeometryReader { geomoetry in
            Color.clear
                .onAppear {
                    self.contentHeight = geomoetry.size.height + 32
                }
        }
    }
    
    var closeTapDetector: some View {
        Color.gray
            .opacity(0.001) // Appears transparent, but also accepts touch events
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                self.trackDetailModalViewManager.close()
            }
    }
    
    var body: some View {
        ZStack {
            if (self.trackDetailModalViewManager.isOpen == true) {
                self.closeTapDetector
            }
            BottomSheetView(
                isOpen: self.$trackDetailModalViewManager.isOpen,
                maxHeight: self.$contentHeight
            ) {
                if let track = self.trackDetailModalViewManager.track {
                    TrackDetailView(withTrack: self.trackDetailModalViewManager.track!)
                        .background(
                            self.geometryReader
                        )
                }
            }
        }
    }
}

struct TrackDetailModalView_Previews: PreviewProvider {
    static var previews: some View {
        TrackDetailModalView()
    }
}
