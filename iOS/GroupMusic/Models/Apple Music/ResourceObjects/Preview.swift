//
//  Preview.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import Foundation

public struct Preview: Codable {
    /// The ID of the content to use for playback
    public let artwork: Artwork?

    /// The kind of the content to use for playback
    public let url: String
}
