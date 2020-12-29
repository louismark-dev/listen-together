//
//  GMAppleMusic.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import Foundation

class GMAppleMusic {
    static func generateSampleURL() {
        let urlBuilder = CiderUrlBuilder(storefront: .canada)
        let url = urlBuilder.searchRequest(term: "Offset", limit: nil, offset: nil, types: [.songs])
        print(url)
    }
}
