//
//  QueueTableViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-03.
//

import UIKit
import Combine

class QueueTableViewController: UIViewController {
    var queueTableView: UITableView!
    var queueTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Track>!
    
    var playerAdapter: PlayerAdapter!
    var trackDetailModalViewModel: TrackDetailModalViewModel!
    
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
