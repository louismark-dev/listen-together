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
    var bottomBarHostingController: UIHostingController<BottomButtonView>!
    var playbackControlsHostingController: UIHostingController<PlaybackControlsView>!
    let playbackControlsSpacing = PlaybackControlsSpacing(top: 40, bottom: 40, left: 24, right: 24)
    var queueTableView: UITableView!
    var queueTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Track>!
    private var lastUpdatedQueue: [Track] = []
    
    let playerAdapter = PlayerAdapter()
    let socketManager: GMSockets = GMSockets.sharedInstance
    private var appleMusicManager: GMAppleMusic! // TODO: Remove this dependancy. It is only for testing
    var notificationMonitor: NotificationMonitor!
    
    private var cancellables: Set<AnyCancellable> = []
    
    var horizontalPadding: CGFloat {
        // Horizontal padding between the edges of the screen and the contents of this view controller
        // Note that the PlaybackControlsView will set padding independently
        return 8
    }
    
    // MARK: View Setup
    
    override func viewDidLoad() {
        self.setupBackgroundBlurViewController()
        self.setupBottomBar()
        self.setupPlaybackControls()
        self.setupQueueTableView()
        
        self.setupNotificationMonitor()
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self.subscribeToQueueStatePublishers()
    }
    
    private func setupNotificationMonitor() {
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
    }
    
    private func subscribeToQueueStatePublishers() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .filter({ (newState: GMAppleMusicHostController.State) -> Bool in
            // Filter out state updates where the queue has not changed
                newState.queue.state.queue != self.lastUpdatedQueue
            })
            .sink { state in
                self.lastUpdatedQueue = state.queue.state.queue
                self.applyNewQueueTableViewSnapshot(withTracks: state.queue.state.queue)
            }
            .store(in: &cancellables)
    }
}

// MARK: Playback Controls
extension RootViewController {
    private func setupPlaybackControls() {
        self.playbackControlsHostingController = self.generatePlaybackControlsHostingController()
        self.setupPlaybackControlsLayout()
    }
    
    private func generatePlaybackControlsHostingController() -> UIHostingController<PlaybackControlsView> {
        let backwardAction = {
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
        
        let forwardsAction = {
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
        
        let togglePlaybackAction = {
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
        
        let playbackControlsConfiguration = PlaybackControlsView.Configuration(backwardAction: backwardAction,
                                                                               playAction: togglePlaybackAction,
                                                                               forwardAction: forwardsAction,
                                                                               opacity: 0.8,
                                                                               playerAdapter: self.playerAdapter)
        let hostingController = UIHostingController(rootView: PlaybackControlsView(withConfiguration: playbackControlsConfiguration))
        return hostingController
    }
    
    private func setupPlaybackControlsLayout() {
        self.addChild(self.playbackControlsHostingController)
        self.view.addSubview(self.playbackControlsHostingController.view)
        
        self.playbackControlsHostingController.view.backgroundColor = .clear
        
        self.playbackControlsHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.playbackControlsHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.playbackControlsSpacing.left).isActive = true
        self.playbackControlsHostingController.view.bottomAnchor.constraint(equalTo: self.bottomBarHostingController.view.topAnchor, constant: -1 * self.playbackControlsSpacing.bottom).isActive = true
        self.playbackControlsHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * self.playbackControlsSpacing.right).isActive = true
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
    private func setupBottomBar() {
        self.configureBottomBar()
        self.setupBottomBarLayout()
    }
    
    private func configureBottomBar() {
        let sessionSettingsAction = {
            self.present(SessionSettingsViewController(), animated: true)
        }
        
        let hostingController = UIHostingController(rootView: BottomButtonView(sessionSettingsAction: sessionSettingsAction))
        
        self.bottomBarHostingController = hostingController
    }
    
    private func setupBottomBarLayout() {
        self.addChild(self.bottomBarHostingController)
        self.view.addSubview(self.bottomBarHostingController.view)
        
        self.bottomBarHostingController.view.backgroundColor = .clear
        
        self.bottomBarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBarHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.horizontalPadding).isActive = true
        self.bottomBarHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * self.horizontalPadding).isActive = true
        self.bottomBarHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
}

// MARK: Background Blur
extension RootViewController {
    private func setupBackgroundBlurViewController() {
        self.backgroundBlurViewController = BackgroundBlurViewController()
        
        self.addChild(self.backgroundBlurViewController)
        self.view.addSubview(self.backgroundBlurViewController.view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundBlurViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundBlurViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundBlurViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.backgroundBlurViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.backgroundBlurViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}

// MARK: QueueTableView
extension RootViewController: UITableViewDelegate {
    private func setupQueueTableView() {
        self.queueTableView = UITableView()
        
        self.configureQueueTableView()
        self.setupQueueTableViewLayout()
    }
    
    private func configureQueueTableView() {
        self.queueTableViewDiffableDataSource = UITableViewDiffableDataSource<Section, Track>(tableView: self.queueTableView) {
            (tableView: UITableView, indexPath: IndexPath, track: Track) in
            let cell =  tableView.dequeueReusableCell(withIdentifier: "QueueCell") as! QueueTableViewCell
            let cellConfiguration = QueueTableViewCell.Configuration(name: track.attributes?.name ?? "",
                                                                     artistName: track.attributes?.artistName ?? "")
            cell.configure(withConfiguration: cellConfiguration)
            
            return cell
        }
        self.queueTableView.dataSource = self.queueTableViewDiffableDataSource
        self.queueTableView.delegate = self
        
        self.queueTableView.backgroundColor = .clear
        self.queueTableView.allowsSelection = false
        self.queueTableView.register(QueueTableViewCell.self, forCellReuseIdentifier: "QueueCell")
    }
    
    private func setupQueueTableViewLayout() {
        self.view.addSubview(self.queueTableView)
        self.queueTableView.translatesAutoresizingMaskIntoConstraints = false
        self.queueTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.queueTableView.bottomAnchor.constraint(equalTo: self.playbackControlsHostingController.view.topAnchor, constant: -1 * self.playbackControlsSpacing.top).isActive = true
        self.queueTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.queueTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func applyNewQueueTableViewSnapshot(withTracks tracks: [Track]) {
        var queueTableViewSnapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        queueTableViewSnapshot.appendSections(Section.allCases)
        queueTableViewSnapshot.appendItems(tracks)
        
        self.queueTableViewDiffableDataSource.apply(queueTableViewSnapshot)
    }
    
    enum Section: CaseIterable {
        case main
    }
}

// MARK: QueueTableViewCell
class QueueTableViewCell: UITableViewCell {
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 18) // This should be 22 when expanded
        label.alpha = 0.9
        label.textColor = UIColor.white
        label.textAlignment = .left
        return label
    }()
    
    private var artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 16)
        label.alpha = 0.7
        label.textColor = UIColor.white
        label.textAlignment = .left
        return label
    }()
    
    private var artworkImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 11
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    
    private var background: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.alpha = 0.55
        view.backgroundColor = UIColor.ui.blackChocolate
        return view
    }()
    
    private var labelsStackView: UIStackView!
    private var artworkAndLabelStackView: UIStackView!
    
    private func createLabelStackView(withSubviews subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }
    
    private func createArtworkAndLabelStackView(withSubviews subviews: [UIView]) -> UIStackView {
        let stackview = UIStackView(arrangedSubviews: subviews)
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = 10
        return stackview
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        let spacing: CGFloat = 20.0
        self.setupBackgroundLayout(withSpacing: spacing)
        self.setupArtworkImageViewLayout()
        self.setupLabelsStackViewLayout()
        self.setupArtworkAndLabelStackViewLayout(withPadding: 16, spacing: spacing)
    }
    
    /// Adds the background to the UITableViewCell, with autolayout constraints
    /// - Parameter spacing: The space between each background in the UITableView
    private func setupBackgroundLayout(withSpacing spacing: CGFloat) {
        let halfSpacing = spacing / 2
        
        self.addSubview(self.background)
        self.background.translatesAutoresizingMaskIntoConstraints = false
        
        self.background.topAnchor.constraint(equalTo: self.topAnchor, constant: halfSpacing).isActive = true
        self.background.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * halfSpacing).isActive = true
        self.background.leftAnchor.constraint(equalTo: self.leftAnchor, constant: halfSpacing).isActive = true
        self.background.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1 * halfSpacing).isActive = true
        self.background.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func setupArtworkImageViewLayout() {
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        self.artworkImageView.widthAnchor.constraint(equalTo: self.artworkImageView.heightAnchor).isActive = true

    }
    
    private func setupLabelsStackViewLayout() {
        self.labelsStackView = createLabelStackView(withSubviews: [nameLabel, artistNameLabel])
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Configures and lays out the arworkAndLabel UIStackView
    /// - Parameters:
    ///   - padding: The space between the edge of the background, and the contents of the cell (artworkAndLabelStackView)
    ///   - spacing: The space between each background in the UITableView.
    private func setupArtworkAndLabelStackViewLayout(withPadding padding: CGFloat, spacing: CGFloat) {
        self.artworkAndLabelStackView = createArtworkAndLabelStackView(withSubviews: [self.artworkImageView, self.labelsStackView])
        self.addSubview(self.artworkAndLabelStackView)
        self.artworkAndLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        let backgroundPadding = padding  + spacing / 2
        self.artworkAndLabelStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: backgroundPadding).isActive = true
        self.artworkAndLabelStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * backgroundPadding).isActive = true
        self.artworkAndLabelStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: backgroundPadding).isActive = true
        self.artworkAndLabelStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1 * backgroundPadding).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(withConfiguration configuration: Configuration) {
        self.nameLabel.text = configuration.name
        self.artistNameLabel.text = configuration.artistName
    }
    
    struct Configuration {
        let name: String
        let artistName: String
    }
}
