//
//  ResultCardView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-02.
//

import SwiftUI
import UIKit
import URLImage

struct MediaCardView: View {
    @State private var showPreview: Bool = false
    @State private var previewTrackData: Track?
    @EnvironmentObject var previewTrack: TrackPreviewController
    
    private let headlineText: String?
    private let subheadlineText: String?
    private let artwork: Artwork?
    private let maxWidth: CGFloat
    
    init(withHeadline headline: String?, subheadline: String?, artwork: Artwork?, maxWidth: CGFloat, previewTrackData: Track) {
        self.headlineText = headline
        self.subheadlineText = subheadline
        self.artwork = artwork
        self._previewTrackData = State(initialValue: previewTrackData)
        self.maxWidth = maxWidth
    }
    
    init(withHeadline headline: String?, subheadline: String?, artwork: Artwork?, maxWidth: CGFloat) {
        self.headlineText = headline
        self.subheadlineText = subheadline
        self.artwork = artwork
        self.maxWidth = maxWidth
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let artworkURL = self.artwork?.url(forWidth: Int(self.maxWidth * UIScreen.main.scale)) {
                ArtworkImageView(artworkURL: artworkURL, cornerRadius: 11)
                    .frame(width: self.maxWidth, height: self.maxWidth)
            }
            if let headlineText = self.headlineText {
                HStack {
                    Text(headlineText)
                        .lineLimit(1)
                        .font(.headline)
                    Spacer()
                }
            }
            if let subheadlineText = self.subheadlineText {
                HStack {
                    Text(subheadlineText)
                        .lineLimit(1)
                        .font(.subheadline)
                        .opacity(0.8)
                    Spacer()

                }
            }
        }
        .frame(width: self.maxWidth)
//        .onTapGesture {
//            if let previewTrackData = self.previewTrackData {
//                self.previewTrack.openTrackPreview(withTrack: previewTrackData)
//            }
//        }
    }
}

//struct MediaCardViewPreviews: PreviewProvider {
//    static var previews: some View {
//        MediaCardView()
//    }
//}
