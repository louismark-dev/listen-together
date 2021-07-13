//
//  PlaybackProgressMonitor.swift
//  GroupMusic
//
//  Created by Louis on 2021-05-20.
//

import UIKit
import Combine

class PlaybackProgressMonitor: ObservableObject {
    private var playerAdapter: PlayerAdapter?
    private let socketManager: GMSockets
    
    private let notificationCenter: NotificationCenter
    private let enteringBackgroundPublisher: NotificationCenter.Publisher
    private let enteringForegroundPublisher: NotificationCenter.Publisher
    private var acceptPlayerStateUpdates: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var playbackFraction: Double = 0.01
    @Published var playbackProgressTimestamp: String = "0:00"
    @Published var playbackDurationTimestamp: String = "0:00"
    
    init(notificationCenter: NotificationCenter = NotificationCenter.default,
         socketManager: GMSockets = GMSockets.sharedInstance) {
        self.notificationCenter = notificationCenter
        self.enteringBackgroundPublisher = self.notificationCenter.publisher(for: UIApplication.willResignActiveNotification)
        self.enteringForegroundPublisher = self.notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
        
        self.socketManager = socketManager
    }
    
    public func startMonitoring(withPlayerAdapter playerAdapter: PlayerAdapter) {
        self.playerAdapter = playerAdapter
        
        self.susbcribeToApplicationStateMonitor()
        self.subscibeToPlayerAdapterPublisher()
    }
    
    public func userScrubbingStarted() {
        self.acceptPlayerStateUpdates = false
    }
    
    public func userScrubbingEnded(withPlaybackFraction playbackFraction: Double) {
        self.seekToPosition(withPlaybackFraction: playbackFraction)
        
        self.acceptPlayerStateUpdates = true
    }
    
    public func setTimestamp(forPlaybackFraction playbackFraction: Double) {
        guard let playbackDuration = self.playerAdapter?.state.playbackPosition.playbackDuration else {
            return
        }
        let scrubberPositionInSeconds = playbackDuration * (playbackFraction / 100)
        let timestamp = self.convertToTimestamp(time: scrubberPositionInSeconds)
        self.playbackProgressTimestamp = timestamp
    }
    
    private func seekToPosition(withPlaybackFraction playbackFraction: Double) {
        guard let playbackDuration = self.playerAdapter?.state.playbackPosition.playbackDuration else {
            print("Could not determine playbackDuration in PlaybackProgressMonitor")
            return
        }
        let seekTime = playbackDuration * (playbackFraction / 100)
        
        guard let playerAdapter = self.playerAdapter else {
            print("PlayerAdapter is null")
            return
        }
        
        if (self.socketManager.state.isCoordinator == true) {
            // IF COORDINATOR
            playerAdapter.seek(toPlaybackTime: seekTime) {
                do {
                    try self.socketManager.emitSeekEvent(withTimeInterval: seekTime)
                } catch {
                    print("Could not emit SeekEvent event.")
                }
            }
        } else {
            // NOT COORDINATOR
            do {
                try self.socketManager.emitSeekEvent(withTimeInterval: seekTime)
            } catch {
                print("Could not emit SeekEvent event.")
            }
        }
    }
    
    private func susbcribeToApplicationStateMonitor() {
        self.enteringBackgroundPublisher
            .receive(on: RunLoop.main)
            .sink { _ in
                self.acceptPlayerStateUpdates = false
            }
            .store(in: &cancellables)
        
        self.enteringForegroundPublisher
            .receive(on: RunLoop.main)
            .sink { _ in
                self.acceptPlayerStateUpdates = true
            }
            .store(in: &cancellables)
    }
    
    private func subscibeToPlayerAdapterPublisher() {
        self.playerAdapter?.$state
            .receive(on: RunLoop.main)
            .sink { (newState: GMAppleMusicHostController.State) in
                if (self.acceptPlayerStateUpdates == false) { return }
                self.playbackFraction = newState.playbackPosition.playbackFraction * 100
                self.playbackProgressTimestamp = self.convertToTimestamp(time: newState.playbackPosition.currentPlaybackTime)
                self.playbackDurationTimestamp = self.convertToTimestamp(time: newState.playbackPosition.playbackDuration)
        }.store(in: &cancellables)
    }
    
    private func convertToTimestamp(time: TimeInterval) -> String {
        let minutes = Int(floor(time / 60))
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        var secondsString: String {
            if (seconds < 10 ) {
                return "0\(seconds)"
            }
            return "\(seconds)"
        }
        return "\(minutes):\(secondsString)"
    }
}
