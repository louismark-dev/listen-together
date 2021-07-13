//
//  BackgroundBlurView.swift
//  GroupMusic
//
//  Created by Louis on 2021-02-12.
//

import SwiftUI
import URLImage
import Combine
import CoreImage.CIFilterBuiltins

struct BackgroundBlurView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @State var images: [UIImage?] = []
    @State private var removalTimeout: Timer?
    
    var body: some View {
        ZStack {
            Color("RussianViolet")
                .ignoresSafeArea(.all, edges: .all)
                .animation(.easeInOut(duration: 10.0))
            ForEach(self.images, id: \.self) { (image: UIImage?) in
                if let image = image {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                            .clipped()
                        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                    }
                }
            }
        }
        .onChange(of: self.playerAdapter.state.queue.state.nowPlayingItem) { (_) in
            if let imageURL = self.playerAdapter.state.queue.state.nowPlayingItem?.attributes?.artwork.url(forWidth: 500) {
                self.downloadImage(fromURL: imageURL)
            } else {
                self.images = [] // This will not animate
            }
        }
    }
    
    private func downloadImage(fromURL url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print("BackgroundBlurView: Error loading image: \(String(describing: error))")
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 2.0)) {
                        self.images = []
                        self.removeOldImagesFromStack()
                    }
                }
                return
            }
            DispatchQueue.main.async {
                if let data = data {
                    if let image = UIImage(data: data) {
                        withAnimation(.linear(duration: 2.0)) {
                            if let blurredImage = self.blurredImage(image: image, radius: 85),
                               let exposureAdjustedImage = self.vibrancyAdjust(image: blurredImage, amount: 100) {
                                self.images.append(exposureAdjustedImage)
                            } else {
                                self.images = []
                            }
                            self.removeOldImagesFromStack()
                        }
                    }
                }
            }
        }).resume()
    }
    
    private func removeOldImagesFromStack() {
        self.removalTimeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer: Timer) in
            if (self.images.count > 1) {
                self.images.remove(at: 0)
            }
        }
    }
    
    func blurredImage(image: UIImage, radius: CGFloat) -> UIImage? {
        guard let image = CIImage(image: image) else { return nil }
        let coreImageContext = CIContext()
        
        let blurredImage = image
            .clampedToExtent()
            .applyingFilter(
                "CIGaussianBlur", parameters: [ kCIInputRadiusKey: radius ]
            )
            .cropped(to: image.extent)
        
        guard let cgImage = coreImageContext.createCGImage(blurredImage, from: blurredImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func exposureAdjust(image: UIImage, exposure: Float) -> UIImage? {
        guard let image = CIImage(image: image) else { return nil }
        let coreImageContext = CIContext()
        
        let adjustedImage = image
            .applyingFilter("CIExposureAdjust", parameters: [ kCIInputEVKey: exposure])
        
        guard let cgImage = coreImageContext.createCGImage(adjustedImage, from: adjustedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func vibrancyAdjust(image: UIImage, amount: Float) -> UIImage? {
        guard let image = CIImage(image: image) else { return nil }
        let coreImageContext = CIContext()
        
        let adjustedImage = image
            .applyingFilter("CIVibrance", parameters: [ kCIInputAmountKey: amount])
        
        guard let cgImage = coreImageContext.createCGImage(adjustedImage, from: adjustedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

//struct BackgroundBlurView_Previews: PreviewProvider {
//    static var previews: some View {
//        BackgroundBlurView()
//    }
//}
