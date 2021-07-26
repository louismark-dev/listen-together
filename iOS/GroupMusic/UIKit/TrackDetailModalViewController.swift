//
//  TrackDetailModalViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-25.
//

import UIKit
import SwiftUI
import Combine

class TrackDetailModalViewController: UIViewController {
    
    private var card: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
        view.addSubview(visualEffectView)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        return view
    }()
        
    private var trackDetailModalViewHostingController: UIHostingController<TrackDetailModalView2>!
    
    private var trackDetailModalViewModel: TrackDetailModalViewModel!
    
    private var cardOpenConstraints: [NSLayoutConstraint]!
    private var cardClosedConstraints: [NSLayoutConstraint]!
        
    private var closeTapGestureRecognizer: UITapGestureRecognizer!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        self.initalizeViews()
        self.configureViewHirearchy()
        self.configureLayout()
        
        self.initalizeCloseTapGestureRecognizer()
    }
    
    // MARK: Data
    public func setTrackDetailModalViewModel(to model: TrackDetailModalViewModel) {
        self.trackDetailModalViewModel = model
        self.subscribeToTrackDetailModalViewModelPublishers()
    }
    
    /// Subscribes to relevant TrackDetailViewModel publishers
    private func subscribeToTrackDetailModalViewModelPublishers() {
        self.subscribeToIsOpenPublisher()
    }
    
    /// Subscribes to TrackDetailViewModel's isOpen publisher.
    /// Will open the TrackDetailVIewModal when isOpen is true.
    private func subscribeToIsOpenPublisher() {
        self.trackDetailModalViewModel!.$isOpen
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
    
    // MARK: Layout
    private func initalizeViews() {
        self.setInteractionlessBackground()
        self.configureTrackDetailModalView()
    }
    
    /// Disables interaction for this VC's underlying view. Gestures will be sent to superviews.
    private func setInteractionlessBackground() {
        self.view = InteractionlessView()
    }
    
    private func configureTrackDetailModalView() {
        self.trackDetailModalViewHostingController = UIHostingController(rootView: TrackDetailModalView2(trackDetailModalViewModel: self.trackDetailModalViewModel))
        self.trackDetailModalViewHostingController.view.backgroundColor = .clear
    }
    
    private func configureViewHirearchy() {
        self.view.addSubview(self.card)
        
        self.addChild(self.trackDetailModalViewHostingController)
        self.card.addSubview(self.trackDetailModalViewHostingController.view)
    }
    
    private func configureLayout() {
        self.configureCardLayout()
        self.configureTrackDetailModalViewLayout()
    }
    
    private func configureCardLayout() {
        self.card.translatesAutoresizingMaskIntoConstraints = false
        
        self.card.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.card.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.cardOpenConstraints = [self.card.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)]
        self.cardClosedConstraints = [self.card.topAnchor.constraint(equalTo: self.view.bottomAnchor)]
        
        NSLayoutConstraint.activate(self.cardClosedConstraints)
        self.card.alpha = 0.0
    }
    
    private func configureTrackDetailModalViewLayout() {
        self.trackDetailModalViewHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.trackDetailModalViewHostingController.view.topAnchor.constraint(equalTo: self.card.topAnchor, constant: 16).isActive = true
        self.trackDetailModalViewHostingController.view.bottomAnchor.constraint(equalTo: self.card.bottomAnchor, constant: -16).isActive = true
        self.trackDetailModalViewHostingController.view.leftAnchor.constraint(equalTo: self.card.leftAnchor, constant: 16).isActive = true
        self.trackDetailModalViewHostingController.view.rightAnchor.constraint(equalTo: self.card.rightAnchor, constant: -16).isActive = true
    }
    
    /// Opens TrackDetailModalView.
    /// Enables the close tap gesture recognizer
    private func open() {
        self.card.alpha = 1.0
        self.enableCloseTapGestureRecognizer()
        self.animateLayoutChange {
            NSLayoutConstraint.deactivate(self.cardClosedConstraints)
            NSLayoutConstraint.activate(self.cardOpenConstraints)
            
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = .black.withAlphaComponent(0.25)
        }
    }
    
    /// Closes the TrackDetailModalView.
    /// Sets TrackDetailModalViewModel's track to nil.
    /// Disables close tap gesture recognizer.
    private func close() {
        self.disableCloseTapGestureRecognizer()
        self.animateLayoutChange {
            NSLayoutConstraint.deactivate(self.cardOpenConstraints)
            NSLayoutConstraint.activate(self.cardClosedConstraints)
            
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = .clear
        } completion: { _ in
            self.card.alpha = 0.0
            self.trackDetailModalViewModel.track = nil
        }
    }
    
    private func animateLayoutChange(_ layoutChange: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: layoutChange, completion: completion)
    }
    
    private func initalizeCloseTapGestureRecognizer() {
        self.closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeTapHandler))
    }
    
    private func enableCloseTapGestureRecognizer() {
        self.view.addGestureRecognizer(self.closeTapGestureRecognizer)
        (self.view as! InteractionlessView).disableInteraction = false
    }
    
    private func disableCloseTapGestureRecognizer() {
        self.view.removeGestureRecognizer(self.closeTapGestureRecognizer)
        (self.view as! InteractionlessView).disableInteraction = true
    }
    
    @objc func closeTapHandler() {
        self.trackDetailModalViewModel.isOpen = false
    }
    
    public enum ViewStatus {
        case open
        case closed
    }
}

/// A UIView with all user interaction disabled. Interaction will still propagate to the subviews.
class InteractionlessView: UIView {
    /// When set to true, user interaction will be disabled for the view
    var disableInteraction: Bool = true
    
    /// When disableInteraction is true, this function will send touches to the superview.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (self.disableInteraction == false) {
            return super.hitTest(point, with: event) // Return superclass implementation of hitTest()
        }
        
        let view = super.hitTest(point, with: event)
        if (view == self) {
            return nil // avoid delivering touch events to the container view (self)
        } else {
            return view //the subviews will still receive touch events
        }
    }
}
