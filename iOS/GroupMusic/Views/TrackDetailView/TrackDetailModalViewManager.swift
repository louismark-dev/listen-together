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
    var audioPreviewPlayer: AudioPreviewManager = AudioPreviewManager()
    
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
        super.init(leading: .playNext(label: "Play Next", imageSystemName: "text.insert", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .playLast(label: "Play Last", imageSystemName: "text.append", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")))
    }
}

class ButtonConfigurationPlayingTrack: ButtonConfiguration {
    init() {
        super.init(leading: .playAgain(label: "Play Again", imageSystemName: "repeat", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .none)
    }
}

class ButtonConfigurationInQueueTrack: ButtonConfiguration {
    init() {
        super.init(leading: .playNext(label: "Play Next", imageSystemName: "text.insert", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .remove(label: "Remove", imageSystemName: "xmark", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Amaranth")))
    }
}

class ButtonConfigurationNotInQueue: ButtonConfiguration {
    init() {
        super.init(leading: .playNext(label: "Play Next", imageSystemName: "text.insert", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")),
                   trailing: .playLast(label: "Play Last", imageSystemName: "text.append", foregroundColor: .white.opacity(0.9), backgroundColor: Color("Emerald")))
    }
}

enum TrackDetailModalViewButtonConfiguration {
    case playNext(label: String, imageSystemName: String, foregroundColor: Color, backgroundColor: Color)
    case playAgain(label: String, imageSystemName: String, foregroundColor: Color, backgroundColor: Color)
    case playLast(label: String, imageSystemName: String, foregroundColor: Color, backgroundColor: Color)
    case remove(label: String, imageSystemName: String, foregroundColor: Color, backgroundColor: Color)
    case none
}
