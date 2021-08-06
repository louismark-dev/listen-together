//
//  QueueTableViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-03.
//

import UIKit
import Combine

class QueueTableViewController: UIViewController {
    fileprivate var queueTableView: UITableView!
    private var queueTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Track>!
    
    private var playerAdapter: PlayerAdapter!
    private var trackDetailModalViewModel: TrackDetailModalViewModel!
    
    private var scrollMonitor: QueueTableViewScrollMonitor!
    @Published var scrollEvents: QueueTableViewScrollEvent?
    
    private var cancellables: Set<AnyCancellable> = []
    
    struct Configuration {
        let playerAdapter: PlayerAdapter
        let trackDetailModalViewModel: TrackDetailModalViewModel
    }
    
    public func configure(with configuration: Configuration) {
        self.playerAdapter = configuration.playerAdapter
        self.trackDetailModalViewModel = configuration.trackDetailModalViewModel
    }
    
    override func viewDidLoad() {
        self.initalizeViews()
        self.configureViewHirearchy()
        self.setupLayout()
        
        self.subscribeToPublishers()
        self.setupScrollMonitor()
    }
    
    private func initalizeViews() {
        self.queueTableView = self.generateQueueTableView()
        self.queueTableViewDiffableDataSource = self.generateDataSource(forTableView: self.queueTableView)
    }
    
    private func configureViewHirearchy() {
        self.view.addSubview(self.queueTableView)
    }
    
    private func setupLayout() {
        self.queueTableView.translatesAutoresizingMaskIntoConstraints = false
        self.queueTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.queueTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.queueTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.queueTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }
    
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
            let cellConfiguration = QueueTableViewCell.Configuration(trackDetailModalViewModel: self.trackDetailModalViewModel,
                                                                     track: track)
            cell.configure(withConfiguration: cellConfiguration)
            
            if (self.playerAdapter.state.queue.state.indexOfNowPlayingItem == indexPath.row) {
                cell.updateLayout(forPlaybackStatus: .playing)
            } else {
                cell.updateLayout(forPlaybackStatus: .notPlaying)
            }
            
            return cell
        }
    }
    
    // MARK: Data
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

extension QueueTableViewController: UITableViewDelegate {
    private func setupScrollMonitor() {
        self.scrollMonitor = QueueTableViewScrollMonitor(withViewController: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollMonitor.userWillBeginDragging(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollMonitor.userWillEndDragging(withVelocity: velocity)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollMonitor.didScroll(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollMonitor.scrollViewDidEndScrollingAnimation()
    }
}

class QueueTableViewScrollMonitor {
    /// The ViewController that contains the scrollEvents Publisher.
    private let queueTableViewController: QueueTableViewController
    /// Is true when the user's finger is dragging the content
    private var userIsDragging = false
    /// The offset of the scrollview when the user started dragging
    private var initialContentOffset: CGPoint?
    /// The cumulative offset since the user started dragging
    private var cumulativeContentOffset: CGFloat?
    /// The last offset reported by the scrollView
    private var lastContentOffset: CGFloat?
    /// The direction the content is scrolling
    private var scrollDirection: QueueTableViewScrollDirection = .none
    
    /// Initializes
    /// - Parameter queueTableViewController: The ViewController that contains the scrollEvents Publisher.
    init(withViewController queueTableViewController: QueueTableViewController) {
        self.queueTableViewController = queueTableViewController
    }
    
    func userWillBeginDragging(_ scrollView: UIScrollView) {
        self.userIsDragging = true
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func userWillEndDragging(withVelocity velocity: CGPoint) {
        self.userIsDragging = false
        
        self.emit(.userDidEndDrag(withVelocity: velocity))
    }
    
    func didScroll(_ scrollView: UIScrollView) {
        let previousScrollDirection = self.scrollDirection
        
        self.setCumulativeScrollOffset(of: scrollView)
        
        if (self.userIsDragging) {
            if let cumulativeContentOffset = self.cumulativeContentOffset {
                self.emit(.userDidDrag(withCumulativeOffset: cumulativeContentOffset))
            }
        }
        
        if (self.userIsDragging) {
            self.setScrollDirection(of: scrollView)
            
            if (previousScrollDirection != self.scrollDirection) {
                self.emit(.userDidDrag(inDirection: self.scrollDirection))
            }
        }
    }
    
    private func setScrollDirection(of scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        guard let lastOffset = self.lastContentOffset else {
            self.lastContentOffset = currentOffset
            self.scrollDirection = .none
            return
        }
        
        if (lastOffset < currentOffset) {
            self.scrollDirection = .down
        } else {
            self.scrollDirection = .up
        }
        self.lastContentOffset = currentOffset
    }
    
    private func setCumulativeScrollOffset(of scrollView: UIScrollView) {
        guard let offsetAtStartOfScroll = self.initialContentOffset else { return }
        self.cumulativeContentOffset = scrollView.contentOffset.y - offsetAtStartOfScroll.y
    }
    
    func scrollViewDidEndScrollingAnimation() {
        // Reset everything to inital values
        self.userIsDragging = false
        self.initialContentOffset = nil
        self.cumulativeContentOffset = nil
        self.lastContentOffset = nil
        self.scrollDirection = .none
    }
    
    private func emit(_ event : QueueTableViewScrollEvent) {
        self.queueTableViewController.scrollEvents = event
    }
}

enum QueueTableViewScrollEvent {
    case userDidEndDrag(withVelocity: CGPoint)
    case userDidDrag(withCumulativeOffset: CGFloat)
    case userDidDrag(inDirection: QueueTableViewScrollDirection)
}

enum QueueTableViewScrollDirection {
    case up
    case down
    case none
}
