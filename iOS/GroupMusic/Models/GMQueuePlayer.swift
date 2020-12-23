//
//  AVPlayer+Queue.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import AVFoundation

class GMQueuePlayer: NSObject, ObservableObject {
    private let socketManager: GMSockets
    private let player: AVPlayer
    private var urls: [URL]
    private var avPlayerItems: [AVPlayerItem]
    private var playbackObservation: NSKeyValueObservation?
    private var duration: TimeInterval = 0.0
    @Published var status: AVPlayer.TimeControlStatus = .paused
    @Published var currentTime: TimeInterval = 0.0
    @Published var fractionPlayed: Double = 0.0
    @Published var currentTimeString: String = "0:00"
    @Published var durationString: String = "0:00"
    
    init(socketManager: GMSockets) {
        self.socketManager = socketManager
        self.urls = [
            Bundle.main.url(forResource: "sample1", withExtension: "mp3")!,
            Bundle.main.url(forResource: "sample2", withExtension: "mp3")!,
            Bundle.main.url(forResource: "sample3", withExtension: "mp3")!,
            Bundle.main.url(forResource: "sample4", withExtension: "mp3")!,
            Bundle.main.url(forResource: "sample5", withExtension: "mp3")!
        ]
        self.avPlayerItems = urls.map { (url) -> AVPlayerItem in AVPlayerItem.init(url: url) }
        self.player = AVPlayer(playerItem: avPlayerItems[0])
        
        super.init()
        updateDuration()
        setupObservation()
    }
    
    // MARK: Observers
    /// Setup required observations
    private func setupObservation() {
        // Observer for playback status
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)

        // Observer for current time
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: 1), queue: nil) { (newTime) in
            self.currentTime = newTime.toSeconds()
            guard let duration = self.player.currentItem?.asset.duration.toSeconds() else { return }
            self.fractionPlayed = self.currentTime / duration
            self.currentTimeString = self.secondsToMinutesAndSecondsString(self.currentTime)
        }
        
        // currentItem Observer
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if let statusNumber = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: statusNumber) {
                self.status = status
            }
            return
        }
        
        if keyPath == #keyPath(AVPlayer.currentItem) {
            // player.currentItem changed. Update duration
            updateDuration()
            return
        }
    }
    
    // MARK: Playback controls
    
    func play() {
        player.play()
        socketManager.emitPlayEvent()
    }
    
    func pause() {
        player.pause()
        socketManager.emitPauseEvent()
    }
    
    func next() {
        guard let currentItem: AVPlayerItem = player.currentItem else { return }
        guard let currentIndex: Int = avPlayerItems.firstIndex(of: currentItem) else { return }
        let nextIndex = currentIndex + 1
        if (!avPlayerItems.indices.contains(nextIndex)) { return }
        player.replaceCurrentItem(with: avPlayerItems[nextIndex])
        player.seek(to: .zero)
    }
    
    func previous() {
        guard let currentItem: AVPlayerItem = player.currentItem else { return }
        guard let currentIndex: Int = avPlayerItems.firstIndex(of: currentItem) else { return }
        let previousIndex = currentIndex - 1
        if (!avPlayerItems.indices.contains(previousIndex)) { return }
        player.replaceCurrentItem(with: avPlayerItems[previousIndex])
        player.seek(to: .zero)
    }
    
    /// Seeks to the given time
    /// - Parameters:
    ///     - seconds: The time to seek to in seconds
    func seek(to fraction: TimeInterval) {
        guard let duration = self.player.currentItem?.asset.duration.toSeconds() else { return }
        let cmTime = CMTime(seconds: fraction * duration, preferredTimescale: 1)
        player.seek(to: cmTime)
    }
    
    // MARK: Helpers

    /// Converts time in seconds to minutes and seconds in the format mm:ss
    /// - Parameters:
    ///     - seconds: Time in seconds
    private func secondsToMinutesAndSecondsString(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds/60)
        let remainderSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        let formattedString: String
        if remainderSeconds < 10 {
            formattedString = "\(minutes):0\(remainderSeconds)"
        } else {
            formattedString = "\(minutes):\(remainderSeconds)"
        }
        return formattedString
    }
    
    private func updateDuration() {
        if let duration = self.player.currentItem?.asset.duration.toSeconds() {
            self.duration = duration
        } else {
            self.duration = 0.0
        }
        self.durationString = secondsToMinutesAndSecondsString(self.duration)
    }

}
