//
//  CompactUIViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-07.
//

import UIKit
import SwiftUI
import Combine

class CompactUIViewController: UIViewController {
    private var compactUIViewModel: CompactUIViewModel!
    
    private var compactUIHostingController: UIHostingController<CompactUIView>!
    
    /// Constraint pins the CompactUI card to the top of the screen. Activate this constraint to make the card visible.
    private var cardOpenConstraint: NSLayoutConstraint!
    
    /// Constraint pins the CompactUI card ABOVE the top of screen. Activate this constraint to slide the card out of view.
    private var cardClosedConstraint: NSLayoutConstraint!
    
    var playerAdapter: PlayerAdapter!
    
    var delgate: CompactUIViewDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
        
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
        
        self.subscribeToPublishers()
    }
    
    struct Configuration {
        let compactUIViewModel: CompactUIViewModel
        let playerAdapter: PlayerAdapter
    }
    
    func configure(with configuration: Configuration) {
        self.compactUIViewModel = configuration.compactUIViewModel
        self.playerAdapter = configuration.playerAdapter
    }
    
    private func initalizeViews() {
        self.setInteractionlessBackground()
        self.configureCompactUIView()
    }
    
    private func setInteractionlessBackground() {
        self.view = InteractionlessView()
    }
    
    private func configureCompactUIView() {
        self.compactUIHostingController = UIHostingController(rootView: CompactUIView(compactUIViewModel: self.compactUIViewModel,
                                                                                      onTap: self.onTapHander))
        self.compactUIHostingController.view.backgroundColor = .clear
    }
    
    private func onTapHander() {
        self.delgate?.scrollToNowPlayingItem()
        self.close()
    }
    
    private func configureViewHirearchy() {
        self.addChild(self.compactUIHostingController)
        self.view.addSubview(self.compactUIHostingController.view)
    }
    
    private func configureLayout() {
        self.configureCompactUIViewLayout()
    }
    
    /// Sets the layout of CompactUIView
    private func configureCompactUIViewLayout() {
        self.compactUIHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.compactUIHostingController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.compactUIHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.compactUIHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        
        self.cardClosedConstraint = self.compactUIHostingController.view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        self.cardOpenConstraint = self.compactUIHostingController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        self.cardOpenConstraint.isActive = false
    }
    
    // MARK: Data
    
    private func subscribeToPublishers() {
        self.subscribeToIsOpenPublisher()
        self.subscribeToNowPlayingPublisher()
    }
    
    /// Subscribes to TrackDetailViewModel's isOpen publisher.
    /// Will open the TrackDetailVIewModal when isOpen is true.
    private func subscribeToIsOpenPublisher() {
        self.compactUIViewModel.$isOpen
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { (isOpen: Bool) in
                if (isOpen == true) {
                    self.open()
                } else {
                    self.close()
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToNowPlayingPublisher() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .sink { (state: GMAppleMusicHostController.State) in
                self.setlayoutData(for: state.queue.state.nowPlayingItem)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Open & Close
    
    private func open() {
        self.cardClosedConstraint.isActive = false
        self.cardOpenConstraint.isActive = true
        self.animateLayoutChange {
            self.compactUIHostingController.view.alpha = 1.0
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func close() {
        self.cardOpenConstraint.isActive = false
        self.cardClosedConstraint.isActive = true
        self.animateLayoutChange {
            self.compactUIHostingController.view.alpha = 0.0
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func setlayoutData(for track: Track?) {
        let heading = Text("Return to Now Playing")
        let subheading = Text("\(track?.attributes?.name ?? "") - \(track?.attributes?.artistName ?? "")")
        let leftIcon = Image.ui.arrow_uturn_backward_circle_fill
        
        withAnimation {
            self.compactUIViewModel.layoutData = CompactUIViewModel.LayoutData(heading: heading,
                                                                               subheading: subheading,
                                                                               leftIcon: leftIcon)
        }
    }
    
    private func animateLayoutChange(_ layoutChange: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut, animations: layoutChange)
    }
}

// MARK: Delegate
protocol CompactUIViewDelegate {
    func scrollToNowPlayingItem()
}
