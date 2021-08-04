//
//  RootViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-13.
//

import UIKit
import SwiftUI
import Combine

class RootViewController: UIViewController {
    var backgroundBlurViewController: BackgroundBlurViewController!
    
    var bottomBarHostingController: UIHostingController<BottomBarView2>!
    
    var playbackControlsViewController: PlaybackControlsViewController!
    let playbackControlsSpacing = PlaybackControlsSpacing(top: 40, bottom: 40, left: 24, right: 24)
    
    var trackDetailModalViewController: TrackDetailModalViewController!
    var trackDetailModalViewModel: TrackDetailModalViewModel!
    
    var queueTableViewController: QueueTableViewController!
    
    /// // Horizontal padding between the edges of the screen and the contents of this view controller
    var horizontalPadding: CGFloat = 8
    
    let playerAdapter = PlayerAdapter()
    let socketManager: GMSockets = GMSockets.sharedInstance
    private var appleMusicManager: GMAppleMusic! // TODO: Remove this dependancy. It is only for testing
    var notificationMonitor: NotificationMonitor!
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Views Setup
    
    override func viewDidLoad() {
        self.initializeTrackDetailModalViewModel()
        
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
        
        self.setupNotificationMonitor()
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
    }
    
    private func initializeTrackDetailModalViewModel() {
        self.trackDetailModalViewModel = TrackDetailModalViewModel(withPlayerAdapter: self.playerAdapter)
    }
    
    private func initalizeViews() {
        self.playbackControlsViewController = self.generatePlaybackControlsViewController()
        self.bottomBarHostingController = self.generateBottomBar()
        self.trackDetailModalViewController = self.generateTrackDetailModalViewController()
        self.backgroundBlurViewController = self.generateBackgroundBlurViewController()
        self.queueTableViewController = self.generateQueueTableViewController()
    }
    
    /// Adds all views to the view hirearchy
    private func configureViewHirearchy() {
        self.addChild(self.backgroundBlurViewController)
        self.view.addSubview(self.backgroundBlurViewController.view)
        
        self.addChild(self.queueTableViewController)
        self.view.addSubview(self.queueTableViewController.view)

        self.addChild(self.bottomBarHostingController)
        self.view.addSubview(self.bottomBarHostingController.view)

        self.addChild(self.playbackControlsViewController)
        self.view.addSubview(self.playbackControlsViewController.view)

        self.addChild(self.trackDetailModalViewController)
        self.view.addSubview(self.trackDetailModalViewController.view)
    }
    
    private func configureLayout() {
        self.setupBottomBarLayout()
        self.setupPlaybackControlsLayout()
        self.setupQueueTableViewLayout()
        self.setupBackgroundBlurViewControllerLayout()
        self.setupTrackDetailModalViewLayout()
    }
    
    // MARK: Data
    
    private func setupNotificationMonitor() {
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
    }
}

// MARK: QueueTableView
extension RootViewController {
    private func generateQueueTableViewController() -> QueueTableViewController {
        let viewController = QueueTableViewController()
        let configuration = QueueTableViewController.Configuration(playerAdapter: self.playerAdapter,
                                                                   trackDetailModalViewModel: self.trackDetailModalViewModel)
        viewController.configure(with: configuration)
        return viewController
    }
    
    private func setupQueueTableViewLayout() {
        self.queueTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.queueTableViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.queueTableViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.queueTableViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.queueTableViewController.view.bottomAnchor.constraint(equalTo: self.playbackControlsViewController.view.topAnchor,
                                                                   constant: -1 * self.playbackControlsSpacing.top).isActive = true
    }
}

// MARK: Playback Controls
extension RootViewController {
    private func generatePlaybackControlsViewController() -> PlaybackControlsViewController {
        let viewController = PlaybackControlsViewController()
        viewController.configure(withSocketManager: self.socketManager,
                                 playerAdapter: self.playerAdapter)
        return viewController
    }
    
    private func setupPlaybackControlsLayout() {
        self.playbackControlsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.playbackControlsViewController.view.bottomAnchor.constraint(equalTo: self.bottomBarHostingController.view.topAnchor,
                                                                         constant: -1 * self.playbackControlsSpacing.bottom).isActive = true
        self.playbackControlsViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor,
                                                                       constant: self.playbackControlsSpacing.left).isActive = true
        self.playbackControlsViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor,
                                                                        constant: -1 * self.playbackControlsSpacing.right).isActive = true
    }
    
    struct PlaybackControlsSpacing {
        let top: CGFloat
        let bottom: CGFloat
        let left: CGFloat
        let right: CGFloat
    }
}

// MARK: Bottom Bar
extension RootViewController {
    private func generateBottomBar() -> UIHostingController<BottomBarView2>{
        let sessionSettingsAction = {
            self.present(SessionSettingsViewController(), animated: true)
        }
        
        return UIHostingController(rootView: BottomBarView2(sessionSettingsAction: sessionSettingsAction))
    }
    
    private func setupBottomBarLayout() {
        self.bottomBarHostingController.view.backgroundColor = .clear
        
        self.bottomBarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBarHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bottomBarHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor,
                                                                   constant: self.horizontalPadding).isActive = true
        self.bottomBarHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor,
                                                                    constant: -1 * self.horizontalPadding).isActive = true
    }
}

// MARK: Background Blur
extension RootViewController {
    private func generateBackgroundBlurViewController() -> BackgroundBlurViewController {
        return BackgroundBlurViewController()
    }
    
    private func setupBackgroundBlurViewControllerLayout() {
        self.backgroundBlurViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundBlurViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundBlurViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.backgroundBlurViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.backgroundBlurViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}

// MARK: Track Details Modal
extension RootViewController {
    private func generateTrackDetailModalViewController() -> TrackDetailModalViewController {
        let viewController = TrackDetailModalViewController()
        viewController.configure(with: TrackDetailModalViewController.Configuration(socketManager: self.socketManager,
                                                                                    playerAdapter: self.playerAdapter,
                                                                                    model: self.trackDetailModalViewModel))
                
        return viewController
    }
    
    private func setupTrackDetailModalViewLayout() {
        self.trackDetailModalViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.trackDetailModalViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.trackDetailModalViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.trackDetailModalViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.trackDetailModalViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}
