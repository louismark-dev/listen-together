//
//  AVPlayer+Extension.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-24.
//

import AVFoundation

extension AVPlayer.TimeControlStatus: Decodable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let rawValue = try value.decode(Int.self)
        guard let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: rawValue) else {
            throw DecodableError.initFromRawValueFailed
        }
        self = timeControlStatus
    }
    
    enum DecodableError: Error {
        case initFromRawValueFailed
    }
}

extension AVPlayer.TimeControlStatus: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
