//
//  SwiftUIView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-06-13.
//

import SwiftUI

struct MediaDetailViewGradient: View {
    @Binding var image: Image?
    @Binding var tintColor: Color?
    
    /// Returns an Image view with content mode .fill, that fills the screen with the image with proper clipping
    @ViewBuilder private func fullScreenImage(image: Image) -> some View {
        GeometryReader { geo in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped(antialiased: true)
        }
    }
    
    @ViewBuilder private func blurredImageView(image: Image) -> some View {
        GeometryReader { geo in
            ZStack {
                self.fullScreenImage(image: image)
                    .scaleEffect(1.5)
                    .blur(radius: 60)
                    .saturation(2)
                Group {
                    self.fullScreenImage(image: image)
                        .offset(x: geo.size.width / 2, y: 0)
                    
                    self.fullScreenImage(image: image)
                        .offset(x: -1 * (geo.size.width / 2), y: 0)
                }
                .scaleEffect(1.5)
                .blur(radius: 60)
                .saturation(4)
                .opacity(0.5)
                .blendMode(.screen)
                .colorMultiply((self.tintColor != nil) ? self.tintColor! : .white)
                .animation(.default)
                Group {
                    self.fullScreenImage(image: image)
                        .offset(x: geo.size.width / 2, y: 0)
                    
                    self.fullScreenImage(image: image)
                        .offset(x: -1 * (geo.size.width / 2), y: 0)
                }
                .scaleEffect(1.5)
                .blur(radius: 60)
                .saturation(4)
                .opacity(0.5)
                .blendMode(.screen)
                .rotationEffect(.degrees(180))
                .colorMultiply((self.tintColor != nil) ? self.tintColor! : .white)
                .animation(.default)
            }
        }
    }
    
    var body: some View {
        ZStack {
            if let image = self.image {
                self.blurredImageView(image: image)
                    .colorMultiply((self.tintColor != nil) ? self.tintColor! : .white)
                    .animation(.default)
                VisualEffectView(effect: UIBlurEffect(style:.systemThinMaterialDark))
            }
        }
        .onChange(of: self.image) { _ in
            print("IMAGE LOADED")
        }
        .clipped()
        .ignoresSafeArea(.all)
        
    }
}
//
//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaDetailViewGradient(image: .constant()
//    }
//}
