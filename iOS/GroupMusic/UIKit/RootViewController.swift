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
    
    var bottomBarViewController: BottomBarViewController!
    
    var playbackControlsViewController: PlaybackControlsViewController!
    let playbackControlsSpacing = PlaybackControlsSpacing(top: 40, bottom: 40, left: 24, right: 24)
    
    var trackDetailModalViewController: TrackDetailModalViewController!
    var trackDetailModalViewModel: TrackDetailModalViewModel!
    
    private var compactUIViewController: CompactUIViewController!
    private var compactUIViewModel: CompactUIViewModel!
    
    var controlsOverlayView: UIView!
    /// When true, the controlsOverlayView will be drawn over the QueueTableView. Scrolling the QueueTableView will trigger the controls
    /// overlay view to hide, which will allow the user to see more content in the queue.
    var shouldOverlayControls: Bool = false
    
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
        self.initializeCompactUIViewModel()
        
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
        
        self.setupNotificationMonitor()
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self.subscribeToQueueTableViewControllerScrollPublisher()
    }
    
    private func initalizeViews() {
        self.playbackControlsViewController = self.generatePlaybackControlsViewController()
        self.bottomBarViewController = self.generateBottomBarViewController()
        self.trackDetailModalViewController = self.generateTrackDetailModalViewController()
        self.compactUIViewController = self.generateCompactUIViewController()
        self.backgroundBlurViewController = self.generateBackgroundBlurViewController()
        self.queueTableViewController = self.generateQueueTableViewController()
        self.controlsOverlayView = self.generateControlsOverlayView()
    }
    
    /// Adds all views to the view hirearchy
    private func configureViewHirearchy() {
        self.addChild(self.backgroundBlurViewController)
        self.view.addSubview(self.backgroundBlurViewController.view)
        
        self.addChild(self.queueTableViewController)
        self.view.addSubview(self.queueTableViewController.view)
        
        self.view.addSubview(self.controlsOverlayView)

        self.addChild(self.bottomBarViewController)
        self.controlsOverlayView.addSubview(self.bottomBarViewController.view)

        self.addChild(self.playbackControlsViewController)
        self.controlsOverlayView.addSubview(self.playbackControlsViewController.view)

        self.addChild(self.trackDetailModalViewController)
        self.view.addSubview(self.trackDetailModalViewController.view)
        
        self.addChild(self.compactUIViewController)
        self.view.addSubview(self.compactUIViewController.view)
    }
    
    private func configureLayout() {
        self.setupBottomBarLayout()
        self.setupPlaybackControlsLayout()
        self.setupQueueTableViewLayout()
        self.setupBackgroundBlurViewControllerLayout()
        self.setupTrackDetailModalViewLayout()
        self.setupCompactUIViewLayout()
        self.setupControlsOverlayViewLayout()
    }
    
    // MARK: Data
    
    private func subscribeToQueueTableViewControllerScrollPublisher() {
        //TODO: Complete implementation
        self.queueTableViewController.$scrollEvents
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (event: QueueTableViewScrollEvent?) in
                self.handleQueueTableViewScrollEvent(event)
                print("DRAG \(event)")
            })
            .store(in: &cancellables)
    }
    
    private func setupNotificationMonitor() {
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
    }
}

// MARK: Controls Overlay View
extension RootViewController {
    private func generateControlsOverlayView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.ui.russianViolet
        return view
    }
    
    private func setupControlsOverlayViewLayout() {
        self.controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
        self.controlsOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.controlsOverlayView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.controlsOverlayView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func handleQueueTableViewScrollEvent(_ event: QueueTableViewScrollEvent?) {
        guard let event = event else { return }
        switch event {
        case .userDidEndDragwithVelocity(let velocity):
            self.userDidEndDrag(withVelocity: velocity)
        case .userDidDragWithCumulativeOffset(let cumulativeOffset):
            self.userDidDrag(withCumulativeOffset: cumulativeOffset)
        case .userDidDragInDirection(let direction):
            self.userDidDrag(inDirection: direction)
        case .didDisplayNowPlayingCell:
            self.didDisplayNowPlayingCell()
        case .didEndDisplayingNowPlayingCell:
            self.didEndDisplayingNowPlayingCell()
        }
    }
    
    private func userDidEndDrag(withVelocity velocity: CGPoint) {
        if (velocity.y > 1) {
            self.removeOverlay()
        }
    }
    
    private func userDidDrag(withCumulativeOffset cumulativeOffset: CGFloat) {
        if (cumulativeOffset > 100) {
            self.removeOverlay()
        }
    }
    
    private func userDidDrag(inDirection direction: QueueTableViewScrollDirection) {
        if (direction == .up) {
            self.addOverlay()
        }
    }
    
    private func addOverlay() {
        if (self.shouldOverlayControls == false) { return }
        self.controlsOverlayView.alpha = 1.0
    }
    
    private func removeOverlay() {
        if (self.shouldOverlayControls == false) { return }
        self.controlsOverlayView.alpha = 0.0
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
        
        let queueTableViewBottomAnchor = self.shouldOverlayControls ? self.view.bottomAnchor : self.controlsOverlayView.topAnchor
        self.queueTableViewController.view.bottomAnchor.constraint(equalTo: queueTableViewBottomAnchor).isActive = true
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
        
        self.playbackControlsViewController.view.bottomAnchor.constraint(equalTo: self.bottomBarViewController.view.topAnchor,
                                                                         constant: -1 * self.playbackControlsSpacing.bottom).isActive = true
        self.playbackControlsViewController.view.topAnchor.constraint(equalTo: self.controlsOverlayView.topAnchor,
                                                                      constant: self.playbackControlsSpacing.top).isActive = true
        self.playbackControlsViewController.view.leftAnchor.constraint(equalTo: self.controlsOverlayView.leftAnchor,
                                                                       constant: self.playbackControlsSpacing.left).isActive = true
        self.playbackControlsViewController.view.rightAnchor.constraint(equalTo: self.controlsOverlayView.rightAnchor,
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
    private func generateBottomBarViewController() -> BottomBarViewController {
        let viewController = BottomBarViewController()
        return viewController
    }
    
    private func setupBottomBarLayout() {
        self.bottomBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBarViewController.view.bottomAnchor.constraint(equalTo: self.controlsOverlayView.bottomAnchor).isActive = true
        self.bottomBarViewController.view.leftAnchor.constraint(equalTo: self.controlsOverlayView.leftAnchor,
                                                                   constant: self.horizontalPadding).isActive = true
        self.bottomBarViewController.view.rightAnchor.constraint(equalTo: self.controlsOverlayView.rightAnchor,
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
    private func initializeTrackDetailModalViewModel() {
        self.trackDetailModalViewModel = TrackDetailModalViewModel(withPlayerAdapter: self.playerAdapter)
    }
    
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

// MARK: CompactUI
extension RootViewController: CompactUIViewDelegate {
    
    private func initializeCompactUIViewModel() {
        self.compactUIViewModel = CompactUIViewModel()
    }
    
    private func generateCompactUIViewController() -> CompactUIViewController {
        let viewController = CompactUIViewController()
        let configuration = CompactUIViewController.Configuration(compactUIViewModel: self.compactUIViewModel,
                                                                  playerAdapter: self.playerAdapter)
        viewController.configure(with: configuration)
        viewController.delgate = self
        return viewController
    }
    
    private func setupCompactUIViewLayout() {
        self.compactUIViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.compactUIViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.compactUIViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.compactUIViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.compactUIViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func didDisplayNowPlayingCell() {
        self.compactUIViewModel.isOpen = false
    }
    
    private func didEndDisplayingNowPlayingCell() {
        self.compactUIViewModel.isOpen = true
    }
    
    // MARK: CompactUIViewDelegate
    func scrollToNowPlayingItem() {
        self.queueTableViewController.scrollToNowPlayingCell()
    }
}
