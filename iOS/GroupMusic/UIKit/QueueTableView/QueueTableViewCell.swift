//
//  QueueTableViewCell.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-03.
//

import UIKit

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
    
    private weak var trackDetailModalViewModel: TrackDetailModalViewModel!
    
    private var track: Track!
    
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
    
    struct Configuration {
        let trackDetailModalViewModel: TrackDetailModalViewModel
        let track: Track
    }
    
    public func configure(withConfiguration configuration: Configuration) {
        self.trackDetailModalViewModel = configuration.trackDetailModalViewModel
        self.track = configuration.track
        
        self.nameLabel.text = self.track.attributes?.name
        self.artistNameLabel.text = self.track.attributes?.artistName
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
        } completion: { _ in
            self.openTrackDetailModalViewController(withTrack: self.track)
        }
    }
    
    private func openTrackDetailModalViewController(withTrack track: Track) {
        self.trackDetailModalViewModel.open(with: track)
    }
    
    // MARK: Config
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct AnimationState {
        var scaleDownAnimationInProgress: Bool = false
        var shouldScaleUpUponScaleDownAnimationCompletion: Bool = false
    }
    
    enum PlaybackStatus {
        case playing
        case notPlaying
    }
}

