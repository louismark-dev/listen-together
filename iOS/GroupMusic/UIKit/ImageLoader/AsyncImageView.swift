//
//  AsyncImageView.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-17.
//

import SwiftUI

struct AsyncImageView<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader2
    private let placeholder: Placeholder
    
    /// This value is used to fade the image into view when it loads
    @State private var imageOpacity: Double = 0.0
    
    init(url: URL?, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        self._loader = StateObject(wrappedValue: ImageLoader2(url: url))
    }
    
    var body: some View {
        content
            .onAppear(perform: self.loader.load)
    }
    
    private var content: some View {
        Group {
            if (loader.image != nil) {
                Image(uiImage: loader.image!)
                    .resizable()
                    .opacity(self.imageOpacity)
                    .onAppear {
                        withAnimation  {
                            self.imageOpacity = 1.0
                        }
                    }
            } else {
                self.placeholder
            }
        }
    }
}
