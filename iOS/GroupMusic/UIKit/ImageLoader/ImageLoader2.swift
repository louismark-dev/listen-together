//
//  ImageLoader.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-17.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader2: ObservableObject {
    @Published var image: UIImage?
    private let url: URL?
    
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard let url = self.url else { return }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .map { UIImage(data: $0.data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

