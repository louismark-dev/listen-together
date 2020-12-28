//
//  AVPlayer+Queue.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import AVFoundation

class GMQueuePlayer: NSObject, ObservableObject {
    private let socketManager: GMSockets
    private let notificationCenter: NotificationCenter
    private let player: AVPlayer
    private var urls: [URL]
    private var avPlayerItems: [AVPlayerItem]
    private var playbackObservation: NSKeyValueObservation?
    @Published var state: State = State()
    
    init(socketManager: GMSockets = GMSockets.sharedInstance, notificationCenter: NotificationCenter = .default) {
        self.socketManager = socketManager
        self.notificationCenter = notificationCenter
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
        self.updateDuration()
        self.setupAVPlayerObservers()
        self.setupNotificationCenterObservers()
    }
    
    // MARK: Observers
    /// Setup observations emitted from AVPlayer
    private func setupAVPlayerObservers() {
        // Observer for playback status
        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)

        // Observer for current time
        self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: 1), queue: nil) { (newTime) in
            self.state.playbackPosition = newTime.toSeconds()
            guard let duration = self.player.currentItem?.asset.duration.toSeconds() else { return }
            self.state.fractionPlayed = self.state.playbackPosition / duration
            self.state.currentTimeString = self.secondsToMinutesAndSecondsString(self.state.playbackPosition)
        }
        
        // currentItem Observer
        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if let statusNumber = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: statusNumber) {
                self.state.timeControlStatus = status
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
    
    /// Starts playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    func play(shouldEmitEvent: Bool = true) {
        self.player.play()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPlayEvent() }
        } catch {
            fatalError(error.localizedDescription)
            // TODO: Should revert to previous state in case of error (do this for all the events)
        }
    }
    
    /// Pauses playback
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    func pause(shouldEmitEvent: Bool = true) {
        self.player.pause()
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPauseEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    /// Sets curent song to next song in queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    func forward(shouldEmitEvent: Bool = true) {
        guard let currentItem: AVPlayerItem = player.currentItem else { return }
        guard let currentIndex: Int = avPlayerItems.firstIndex(of: currentItem) else { return }
        let nextIndex = currentIndex + 1
        if (!avPlayerItems.indices.contains(nextIndex)) { return }
        self.player.replaceCurrentItem(with: avPlayerItems[nextIndex])
        self.player.seek(to: .zero)
        do {
            if (shouldEmitEvent) { try self.socketManager.emitForwardEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Sets curent song to previous song in queue
    /// - Parameters:
    ///     - shouldEmitEvent: (defualt: true) If true, will emit event though the SocketManager
    func previous(shouldEmitEvent: Bool = true) {
        guard let currentItem: AVPlayerItem = player.currentItem else { return }
        guard let currentIndex: Int = avPlayerItems.firstIndex(of: currentItem) else { return }
        let previousIndex = currentIndex - 1
        if (!avPlayerItems.indices.contains(previousIndex)) { return }
        player.replaceCurrentItem(with: avPlayerItems[previousIndex])
        player.seek(to: .zero)
        do {
            if (shouldEmitEvent) { try self.socketManager.emitPreviousEvent() }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Seeks to the given time
    /// - Parameters:
    ///     - seconds: The time to seek to in seconds
    func seek(to fraction: TimeInterval) {
        guard let duration = self.player.currentItem?.asset.duration.toSeconds() else { return }
        let cmTime = CMTime(seconds: fraction * duration, preferredTimescale: 1)
        self.player.seek(to: cmTime)
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
            self.state.duration = duration
        } else {
            self.state.duration = 0.0
        }
        self.state.durationString = secondsToMinutesAndSecondsString(self.state.duration)
    }
    
    // MARK: Notification Center
    /// Setup observers for Notification Center events emitted by GMSockets
    private func setupNotificationCenterObservers() {
        self.notificationCenter.addObserver(self,
                                            selector: #selector(stateUpdateRequested),
                                            name: .stateUpdateRequested,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePlayEvent),
                                            name: .playEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePauseEvent),
                                            name: .pauseEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecieveForwardEvent),
                                            name: .forwardEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePreviousEvent),
                                            name: .previousEvent,
                                            object: nil)
    }
    
    @objc private func stateUpdateRequested() {
        self.socketManager.updateQueuePlayerState(with: self.state)
    }
    
    @objc private func didRecievePlayEvent() {
        self.play(shouldEmitEvent: false)
    }
    
    @objc private func didRecievePauseEvent() {
        self.pause(shouldEmitEvent: false)
    }
    
    @objc private func didRecieveForwardEvent() {
        self.forward(shouldEmitEvent: false)
    }
    
    @objc private func didRecievePreviousEvent() {
        self.previous(shouldEmitEvent: false)
    }

}

extension GMQueuePlayer {
    struct State: Codable {
        var timeControlStatus: AVPlayer.TimeControlStatus = .paused
        var duration: TimeInterval = 0.0
        var playbackPosition: TimeInterval = 0.0
        var currentTimeString: String = "0:00"
        var durationString: String = "0:00"
        var fractionPlayed: Double = 0.0
    }
}
