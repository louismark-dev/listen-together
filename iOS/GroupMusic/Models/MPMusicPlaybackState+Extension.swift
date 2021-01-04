//
//  MPMusicPlaybackState+Extension.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import MediaPlayer

extension MPMusicPlaybackState: Decodable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let rawValue = try value.decode(Int.self)
        guard let musicPlaybackState = MPMusicPlaybackState(rawValue: rawValue) else {
            throw DecodableError.initFromRawValueFailed
        }
        self = musicPlaybackState
    }
    
    enum DecodableError: Error {
        case initFromRawValueFailed
    }
}

extension MPMusicPlaybackState: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
