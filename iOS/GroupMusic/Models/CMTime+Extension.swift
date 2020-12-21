//
//  CMTime+Extension.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import AVFoundation

extension CMTime {
    func toSeconds() -> TimeInterval {
        return Double(self.value) / Double(self.timescale)
    }
}
