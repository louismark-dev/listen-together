//
//  PlaybackControlsViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-03.
//

import UIKit
import SwiftUI

class PlaybackControlsViewController: UIViewController {
    private var socketManager: GMSockets!
    private var playerAdapter: PlayerAdapter!
    
    var playbackControlsHostingController: UIHostingController<PlaybackControlsView>!
    
    // MARK: Setup
        
    public func configure(withSocketManager socketManager: GMSockets, playerAdapter: PlayerAdapter) {
        self.socketManager = socketManager
        self.playerAdapter = playerAdapter
    }
    
    override func viewDidLoad() {
        self.initalizeViews()
        self.configureViewHirearchy()
        self.setupLayout()
    }
    
    private func initalizeViews() {
        self.playbackControlsHostingController = self.generatePlaybackControlsHostingController()
    }
    
    private func configureViewHirearchy() {
        self.addChild(self.playbackControlsHostingController)
        self.view.addSubview(self.playbackControlsHostingController.view)
    }
    
    private func setupLayout() {
        self.playbackControlsHostingController.view.backgroundColor = .clear
        
        self.playbackControlsHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.playbackControlsHostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.playbackControlsHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.playbackControlsHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playbackControlsHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func generatePlaybackControlsHostingController() -> UIHostingController<PlaybackControlsView> {
        let actions = PlaybackControlsView.Actions(backwardAction: self.backwardsAction,
                                                   togglePlaybackAction: self.togglePlaybackAction,
                                                   forwardAction: self.forwardsAction)
        let playbackControlsConfiguration = PlaybackControlsView.Configuration(playerAdapter: self.playerAdapter,
                                                                               actions: actions)
        
        return UIHostingController(rootView: PlaybackControlsView(withConfiguration: playbackControlsConfiguration))
    }
    
    // MARK: Playback Control Actions
    
    private func backwardsAction() {
        let emitPreviousEvent: () -> () = {
            do {
                try self.socketManager.emitPreviousEvent()
            } catch {
                print("Could not emit PreviousEvent event")
            }
        }
        
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.skipToPreviousItem {
                emitPreviousEvent()
            }
        } else {
            // NOT COORDINATOR
            emitPreviousEvent()
        }
    }
    
    private func forwardsAction() {
        let emitForwardsEvent: () -> () = {
            do {
                try self.socketManager.emitForwardEvent()
            } catch {
                print("Could not emit ForwardEvent event")
            }
        }
        
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            self.playerAdapter.skipToNextItem {
                emitForwardsEvent()
            }
        } else {
            // NOT COORDINATOR
            emitForwardsEvent()
        }
    }
    
    private func togglePlaybackAction() {
        let emitPlayEvent: () -> () = {
            do {
                try self.socketManager.emitPlayEvent()
            } catch {
                print("Could not emit PlayEvent event")
            }
        }
        
        let emitPauseEvent: () -> () = {
            do {
                try self.socketManager.emitPauseEvent()
            } catch {
                print("Could not emit PauseEvent event")
            }
        }
        
        if (self.socketManager.state.isCoordinator == true) {
            // IS COORDINATOR
            if (self.playerAdapter.state.playbackState !=  .playing) {
                // NOT PLAYING
                self.playerAdapter.play {
                    emitPlayEvent()
                }
            } else {
                // PLAYING
                self.playerAdapter.pause {
                    emitPauseEvent()
                }
            }
        } else {
            // NOT COORDINATOR
            if (self.playerAdapter.state.playbackState != .playing) {
                // NOT PLAYING
                emitPlayEvent()
            } else {
                emitPauseEvent()
            }
        }
    }
}
