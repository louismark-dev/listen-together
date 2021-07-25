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
    
    var playbackControlsHostingController: UIHostingController<PlaybackControlsView>!
    let playbackControlsSpacing = PlaybackControlsSpacing(top: 40, bottom: 40, left: 24, right: 24)
    
    var queueTableView: UITableView!
    var queueTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Track>!
    
    var horizontalPadding: CGFloat {
        // Horizontal padding between the edges of the screen and the contents of this view controller
        // Note that the PlaybackControlsView will set padding independently
        return 8
    }
    
    let playerAdapter = PlayerAdapter()
    let socketManager: GMSockets = GMSockets.sharedInstance
    private var appleMusicManager: GMAppleMusic! // TODO: Remove this dependancy. It is only for testing
    var notificationMonitor: NotificationMonitor!
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Views Setup
    
    override func viewDidLoad() {
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
        
        self.setupNotificationMonitor()
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self.subscribeToPublishers()
    }
    
    private func initalizeViews() {
        self.playbackControlsHostingController = self.generatePlaybackControlsHostingController()
        self.bottomBarHostingController = self.generateBottomBar()
        self.backgroundBlurViewController = self.generateBackgroundBlurViewController()
        self.queueTableView = self.generateQueueTableView()
        self.queueTableViewDiffableDataSource = self.generateDataSource(forTableView: self.queueTableView)
    }
    
    /// Adds all views to the virw hirearchy
    private func configureViewHirearchy() {
        self.addChild(self.backgroundBlurViewController)
        self.view.addSubview(self.backgroundBlurViewController.view)
        
        self.addChild(self.playbackControlsHostingController)
        self.view.addSubview(self.playbackControlsHostingController.view)
        
        self.addChild(self.bottomBarHostingController)
        self.view.addSubview(self.bottomBarHostingController.view)
        
        self.view.addSubview(self.queueTableView)
    }
    
    private func configureLayout() {
        self.setupPlaybackControlsLayout()
        self.setupBottomBarLayout()
        self.setupBackgroundBlurViewControllerLayout()
        self.setupQueueTableViewLayout()
    }
    
    // MARK: Data
    
    private func setupNotificationMonitor() {
        self.notificationMonitor = NotificationMonitor(playerAdapter: self.playerAdapter)
        self.notificationMonitor.startListeningForNotifications()
    }
    
    private func subscribeToPublishers() {
        self.subscribeToQueuePublisher()
        self.subscibeToIndexOfNowPlayingItemPublisher()
    }
    
    private func subscribeToQueuePublisher() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .removeDuplicates(by: { previousState, currentState in
                (previousState.queue.state.queue == currentState.queue.state.queue)
            })
            .sink { state in
                self.applyNewQueueTableViewSnapshot(withTracks: state.queue.state.queue)
            }
            .store(in: &cancellables)
    }
    
    private func subscibeToIndexOfNowPlayingItemPublisher() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .removeDuplicates(by: { previousState, currentState in
                (previousState.queue.state.indexOfNowPlayingItem == currentState.queue.state.indexOfNowPlayingItem)
            })
            .sink { state in
                for i in 0..<self.playerAdapter.state.queue.state.queue.count {
                    // Only visible cells will be provided by cellForRow(at: ).
                    // Layout updates for non-visible cells must be done when dequeing reusable cells.
                    guard let cell = self.queueTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? QueueTableViewCell else {
                        continue // There was no visible cell at this row... continue to next loop
                    }
                    self.queueTableView.beginUpdates()
                    if (state.queue.state.indexOfNowPlayingItem == i) {
                        cell.updateLayout(forPlaybackStatus: .playing)
                    } else {
                        cell.updateLayout(forPlaybackStatus: .notPlaying)
                    }
                    self.queueTableView.endUpdates()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Playback Controls
extension RootViewController {
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
        
        return UIHostingController(rootView: PlaybackControlsView(withConfiguration: playbackControlsConfiguration))
    }
    
    private func setupPlaybackControlsLayout() {
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
    private func generateBottomBar() -> UIHostingController<BottomBarView2>{
        let sessionSettingsAction = {
            self.present(SessionSettingsViewController(), animated: true)
        }
        
        return UIHostingController(rootView: BottomBarView2(sessionSettingsAction: sessionSettingsAction))
    }
    
    private func setupBottomBarLayout() {
        self.bottomBarHostingController.view.backgroundColor = .clear
        
        self.bottomBarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.bottomBarHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.horizontalPadding).isActive = true
        self.bottomBarHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * self.horizontalPadding).isActive = true
        self.bottomBarHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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

// MARK: QueueTableView
extension RootViewController: UITableViewDelegate {
    /// Generates the queue UITableView.
    /// Note: The configured UITableView does not have a dataSource.
    /// The dataSource must be generated using generateDataSource(forTableView: )
    private func generateQueueTableView() -> UITableView {
        let tableView = UITableView()
        
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(QueueTableViewCell.self, forCellReuseIdentifier: "QueueCell")
        tableView.estimatedRowHeight = 100
        
        return tableView
    }
    
    private func generateDataSource(forTableView tableView: UITableView) -> UITableViewDiffableDataSource<Section, Track> {
        return UITableViewDiffableDataSource<Section, Track>(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, track: Track) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell") as! QueueTableViewCell
            let cellConfiguration = QueueTableViewCell.Configuration(name: track.attributes?.name ?? "",
                                                                     artistName: track.attributes?.artistName ?? "")
            cell.configure(withConfiguration: cellConfiguration)
            
            if (self.playerAdapter.state.queue.state.indexOfNowPlayingItem == indexPath.row) {
                cell.updateLayout(forPlaybackStatus: .playing)
            } else {
                cell.updateLayout(forPlaybackStatus: .notPlaying)
            }
            
            return cell
        }
    }
    
    private func setupQueueTableViewLayout() {
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
    
    private var nowPlayingLabel: UILabel = {
        let label = UILabel()
        label.text = "Now Playing"
        label.numberOfLines = 1
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 16)
        label.alpha = 0.7
        label.textColor = UIColor.ui.lavenderWeb
        label.textAlignment = .left
        return label
    }()
    
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
        view.backgroundColor = UIColor.ui.blackChocolate.withAlphaComponent(0.55)
        
        return view
    }()
    
    private var animationState: AnimationState = AnimationState()
    
    private var labelsStackView: UIStackView!
    private var artworkAndLabelStackView: UIStackView!
    
    private var backgroundCompactHeightConstraint: NSLayoutConstraint!
    private var backgroundExpandedHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
    }
    
    // MARK: View Setup
    
    private func initalizeViews() {
        self.labelsStackView = self.createLabelStackView(withSubviews: [self.nameLabel, self.artistNameLabel])
        self.artworkAndLabelStackView = self.createArtworkAndLabelStackView(withSubviews: [self.artworkImageView, self.labelsStackView])
    }
    
    private func configureViewHirearchy() {
        self.contentView.addSubview(self.background)
        self.background.addSubview(self.artworkAndLabelStackView)
    }
    
    private func configureLayout() {
        self.setupBackgroundLayout(withSpacing: 20.0)
        self.setupArtworkImageViewLayout()
        self.setupArtworkAndLabelStackViewLayout(withPadding: 16.0)
    }
    
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
    
    /// Adds the background to the UITableViewCell, with autolayout constraints
    /// - Parameter spacing: The space between each background in the UITableView
    private func setupBackgroundLayout(withSpacing spacing: CGFloat) {
        let halfSpacing = spacing / 2
        
        self.background.translatesAutoresizingMaskIntoConstraints = false
        
        self.background.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: halfSpacing).isActive = true
        self.background.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1 * halfSpacing).isActive = true
        self.background.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: halfSpacing).isActive = true
        self.background.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -1 * halfSpacing).isActive = true
        
        self.backgroundExpandedHeightConstraint = self.background.heightAnchor.constraint(equalToConstant: 120)
        self.backgroundCompactHeightConstraint = self.background.heightAnchor.constraint(equalToConstant: 80)
        self.backgroundCompactHeightConstraint.isActive = true
    }
    
    private func setupArtworkImageViewLayout() {
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        self.artworkImageView.widthAnchor.constraint(equalTo: self.artworkImageView.heightAnchor).isActive = true
    }
    
    /// Configures and lays out the arworkAndLabel UIStackView
    /// - Parameters:
    ///   - padding: The space between the edge of the background, and the contents of the cell (artworkAndLabelStackView)
    ///   - spacing: The space between each background in the UITableView.
    private func setupArtworkAndLabelStackViewLayout(withPadding padding: CGFloat) {
        self.artworkAndLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.artworkAndLabelStackView.topAnchor.constraint(equalTo: self.background.topAnchor, constant: padding).isActive = true
        self.artworkAndLabelStackView.bottomAnchor.constraint(equalTo: self.background.bottomAnchor, constant: -1 * padding).isActive = true
        self.artworkAndLabelStackView.leftAnchor.constraint(equalTo: self.background.leftAnchor, constant: padding).isActive = true
        self.artworkAndLabelStackView.rightAnchor.constraint(equalTo: self.background.rightAnchor, constant: -1 * padding).isActive = true
    }
    
    public func updateLayout(forPlaybackStatus playbackStatus: PlaybackStatus) {
        if (playbackStatus == .playing) {
            self.labelsStackView.insertArrangedSubview(self.nowPlayingLabel, at: 0)
            
            self.backgroundCompactHeightConstraint.isActive = false
            self.backgroundExpandedHeightConstraint.isActive = true
        } else if (playbackStatus == .notPlaying) {
            self.labelsStackView.removeArrangedSubview(self.nowPlayingLabel)
            self.nowPlayingLabel.removeFromSuperview()
            
            self.backgroundExpandedHeightConstraint.isActive = false
            self.backgroundCompactHeightConstraint.isActive = true
        }
    }
    
    // MARK: Gesture Recognizers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scaleDownAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.animationState.scaleDownAnimationInProgress) {
            self.animationState.shouldScaleUpUponScaleDownAnimationCompletion = true
        } else {
            self.scaleUpAnimation()
        }
    }
    
    private func scaleDownAnimation() {
        self.animationState.scaleDownAnimationInProgress = true
        UIView.animate(withDuration: 0.1) {
            self.background.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        } completion: { _ in
            self.animationState.scaleDownAnimationInProgress = false
            
            if (self.animationState.shouldScaleUpUponScaleDownAnimationCompletion == true) {
                self.scaleUpAnimation()
                self.animationState.shouldScaleUpUponScaleDownAnimationCompletion = false
            }
        }
    }
    
    private func scaleUpAnimation() {
        UIView.animate(withDuration: 0.1) {
            self.background.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: Config
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(withConfiguration configuration: Configuration) {
        self.nameLabel.text = configuration.name
        self.artistNameLabel.text = configuration.artistName
    }
    
    struct AnimationState {
        var scaleDownAnimationInProgress: Bool = false
        var shouldScaleUpUponScaleDownAnimationCompletion: Bool = false
    }
    
    struct Configuration {
        let name: String
        let artistName: String
    }
    
    enum PlaybackStatus {
        case playing
        case notPlaying
    }
}
