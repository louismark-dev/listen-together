//
//  ResultCardView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-02.
//

import SwiftUI
import URLImage

struct MediaCardView: View {
    @State private var showPreview: Bool = false
    @State private var previewTrackData: Track?
    @EnvironmentObject var previewTrack: TrackPreviewController
    
    private let headlineText: String?
    private let subheadlineText: String?
    private let artworkURL: URL?
    
    init(withHeadline headline: String?, subheadline: String?, artworkURL: URL?, previewTrackData: Track) {
        self.headlineText = headline
        self.subheadlineText = subheadline
        self.artworkURL = artworkURL
        self._previewTrackData = State(initialValue: previewTrackData)
    }
    
    init(withHeadline headline: String?, subheadline: String?, artworkURL: URL?) {
        self.headlineText = headline
        self.subheadlineText = subheadline
        self.artworkURL = artworkURL
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let artworkURL = self.artworkURL {
                URLImage(url: artworkURL, content: { (image: Image) in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                })
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            if let headlineText = self.headlineText {
                HStack {
                    Text(headlineText)
                        .lineLimit(1)
                        .font(.headline)
                }
            }
            if let subheadlineText = self.subheadlineText {
                HStack {
                    Text(subheadlineText)
                        .lineLimit(1)
                        .font(.subheadline)
                        .opacity(0.8)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fill)
        .onTapGesture {
            if let previewTrackData = self.previewTrackData {
                self.previewTrack.openTrackPreview(withTrack: previewTrackData)
            }
        }
    }
}

//struct MediaCardViewPreviews: PreviewProvider {
//    static var previews: some View {
//        MediaCardView()
//    }
//}
