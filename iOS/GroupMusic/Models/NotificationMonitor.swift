//
//  NotificationMonitor.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-18.
//

import Foundation

class NotificationMonitor {
    private let playerAdapter: PlayerAdapter
    private let notificationCenter: NotificationCenter
    private let socketManager: GMSockets
    
    init(playerAdapter: PlayerAdapter,
         notificationCenter: NotificationCenter = .default,
         socketManager: GMSockets = GMSockets.sharedInstance) {
        self.playerAdapter = playerAdapter
        self.notificationCenter = notificationCenter
        self.socketManager = socketManager
    }
    
    public func startListeningForNotifications() {
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecieveStateUpdateEvent),
                                            name: .stateUpdateEvent,
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
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecievePrependToQueueEvent),
                                            name: .prependToQueueEvent,
                                            object: nil)
        self.notificationCenter.addObserver(self,
                                            selector: #selector(didRecieveAppendToQueueEvent),
                                            name: .appendToQueueEvent,
                                            object: nil)
    }
    
    @objc private func didRecieveStateUpdateEvent(_ notification: NSNotification) {
        guard let state = notification.object as? GMAppleMusicPlayer.State? else { fatalError("ERROR: Could not unwrap expected GMAppleMusicPlayer.State") }
        if let state = state {
            self.playerAdapter.updateState(with: state)
        }
    }
    
    @objc private func didRecievePlayEvent() {
        self.playerAdapter.play(completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitPlayEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }

    @objc private func didRecievePauseEvent() {
        self.playerAdapter.pause(completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitPauseEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }

    @objc private func didRecieveForwardEvent() {
        self.playerAdapter.skipToNextItem(completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitForwardEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }

    @objc private func didRecievePreviousEvent() {
        self.playerAdapter.skipToPreviousItem(completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitPreviousEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    @objc private func didRecievePrependToQueueEvent(_ notification: NSNotification) {
        guard let tracks = notification.object as? [Track] else { return }
        self.playerAdapter.prependToQueue(withTracks: tracks, completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitPrependToQueueEvent(withTracks: tracks)
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    @objc private func didRecieveAppendToQueueEvent(_ notification: NSNotification) {
        guard let tracks = notification.object as? [Track] else { return }
        self.playerAdapter.appendToQueue(withTracks: tracks, completion: {
            // Emit event only if coordinator
            guard (self.socketManager.state.isCoordinator) else { return }
            do {
                try self.socketManager.emitAppendToQueueEvent(withTracks: tracks)
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
}
