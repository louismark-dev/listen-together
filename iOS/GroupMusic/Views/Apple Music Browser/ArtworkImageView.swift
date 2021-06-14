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
    let cornerRadius: CGFloat
    @State private var imageOpacity: Double = 0.0
    @State private var isCached: Bool = false
    private var onLoadAction: ((Image) -> Void)?
    
    init(artworkURL: URL, cornerRadius: CGFloat) {
        self.artworkURL = artworkURL
        self.cornerRadius = cornerRadius
    }
    
    public func onImageAppear(perform action: ((Image) -> Void)? = nil) -> some View {
        var new = self
        new.onLoadAction = action
        return new
    }
    
    var body: some View {
        
        URLImage(url: self.artworkURL,
                 empty: {
                    Rectangle()
                        .foregroundColor(Color("RedactedColor"))
                 },
                 inProgress: { _ in
                     Rectangle()
                        .foregroundColor(Color("RedactedColor"))
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
                                if let onLoadAction = self.onLoadAction {
                                    onLoadAction(image)
                                }
                                withAnimation {
                                    self.imageOpacity = 1.0
                                }
                            }
                    }
                 })
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
    }
}

//struct ArtworkImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtworkImageView()
//    }
//}
