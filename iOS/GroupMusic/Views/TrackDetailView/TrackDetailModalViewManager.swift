//
//  TrackDetailModalViewManager.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import SwiftUI

class TrackDetailModalViewManager: ObservableObject {
    @Published var isOpen: Bool = false
    @Published var configuration: TrackDetailModalViewConfiguration?
    var audioPreviewPlayer: AudioPreview = AudioPreview()
    
    public func open(withConfiguration configuration: TrackDetailModalViewConfiguration) {
        self.configuration = configuration
        self.isOpen = true
        
        if let previewURL = self.configuration?.track?.attributes?.previews.first?.url {
            self.audioPreviewPlayer.setAudioStreamURL(audioStreamURL: previewURL)
        }
    }
    
    public func close() {
        self.isOpen = false
        self.configuration = nil
        
        try? self.audioPreviewPlayer.stop()
    }
}

struct TrackDetailModalViewConfiguration {
    var track: Track?
    var trackIsInQueue: Bool
    var buttonConfiguration: ButtonConfiguration
}

class ButtonConfiguration {
    let leading: TrackDetailModalViewButtonConfiguration
    let trailing: TrackDetailModalViewButtonConfiguration
    
    init(leading: TrackDetailModalViewButtonConfiguration, trailing: TrackDetailModalViewButtonConfiguration) {
        self.leading = leading
        self.trailing = trailing
    }
}

class ButtonConfigurationPlayedTrack: ButtonConfiguration {
    init() {
        super.init(leading: .playNext(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .playLast(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")))
    }
}

class ButtonConfigurationPlayingTrack: ButtonConfiguration {
    init() {
        super.init(leading: .playAgain(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .none)
    }
}

class ButtonConfigurationInQueueTrack: ButtonConfiguration {
    init() {
        super.init(leading: .playNext(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .remove(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Amaranth")))
    }
}

class ButtonConfigurationNotInQueue: ButtonConfiguration {
    init() {
        super.init(leading: .playNext(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .playLast(foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")))
    }
}

enum TrackDetailModalViewButtonConfiguration {
    case playNext(foregroundColor: Color, backgroundColor: Color)
    case playAgain(foregroundColor: Color, backgroundColor: Color)
    case playLast(foregroundColor: Color, backgroundColor: Color)
    case remove(foregroundColor: Color, backgroundColor: Color)
    case none
}
