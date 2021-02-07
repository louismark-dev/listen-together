//
//  ArtworkImageView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-06.
//

import SwiftUI
import URLImage

struct ArtworkImageView: View {
    let artworkURL: URL
    let height: CGFloat
    @State private var imageOpacity: Double = 0.0
    @State private var isCached: Bool = false
    @State private var isFirstLoad: Bool = false // Set to true if image is being loaded from network or cache
    
    var body: some View {
        URLImage(url: self.artworkURL,
                 empty: {
                    Rectangle()
                        .foregroundColor(Color("RedactedColor"))
                        .onAppear {
                            self.isFirstLoad = true
                        }
                 },
                 inProgress: { _ in
                     Rectangle()
                        .foregroundColor(Color("RedactedColor"))
                        .onAppear {
                            self.isFirstLoad = true
                        }
                 },
                 failure: {_,_ in
                    Rectangle()
                        .foregroundColor(Color("RedactedColor"))
                        .onAppear {
                            print("Image load fail")
                        }
                 },
                 content: { image in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("RedactedColor"))
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(self.imageOpacity)
                            .onAppear {
                                if (self.isFirstLoad) {
                                    withAnimation {
                                        self.imageOpacity = 1.0
                                    }
                                } else {
                                    self.imageOpacity = 1.0
                                }
                            }
                    }
                 })
            .frame(height: self.height)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

//struct ArtworkImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtworkImageView()
//    }
//}
