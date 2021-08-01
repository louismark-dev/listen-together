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
    
    /// Constraint pins the bottom of the card to the bottom of the TrackDetailModalViewController's view.
    /// Set to true to open the card.
    private var cardOpenConstraint: NSLayoutConstraint!
    
    /// Constraint pins the top of the card to the bottom of the TrackDetailModalViewController's view.
    /// Set to true to close the card.
    private var cardClosedConstraint: NSLayoutConstraint!
    
    /// The height constraint of the trackDetailModalViewHostingController.
    /// This constraint is used to resize the view when the user is dragging up.
    private var trackDetailModalViewHostingControllerHeightConstraint: NSLayoutConstraint!
    /// The inital height of the trackDetailModalViewHostingController, prior to the user dragging up
    private var trackDetailModalViewHostingControllerInitialHeight: CGFloat!
        
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
        
        self.setupPanGestureRecognizer()
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
        
        self.cardOpenConstraint = self.card.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.cardClosedConstraint = self.card.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        self.cardClosedConstraint.isActive = true
        self.card.alpha = 0.0
    }
    
    private func configureTrackDetailModalViewLayout() {
        self.trackDetailModalViewHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.trackDetailModalViewHostingController.view.topAnchor.constraint(equalTo: self.card.topAnchor, constant: 16).isActive = true
        self.trackDetailModalViewHostingController.view.bottomAnchor.constraint(equalTo: self.card.bottomAnchor, constant: -16).isActive = true
        self.trackDetailModalViewHostingController.view.leftAnchor.constraint(equalTo: self.card.leftAnchor, constant: 16).isActive = true
        self.trackDetailModalViewHostingController.view.rightAnchor.constraint(equalTo: self.card.rightAnchor, constant: -16).isActive = true
        
        // This constraint is used to resize the view when the user drags the card view up.
        // It is otherwise inactive.
        self.trackDetailModalViewHostingControllerHeightConstraint = self.trackDetailModalViewHostingController.view.heightAnchor.constraint(equalToConstant: 0)
    }
    
    // MARK: Open & Close
    
    /// Opens TrackDetailModalView.
    /// Enables the close tap gesture recognizer
    private func open() {
        self.card.alpha = 1.0
        self.enableCloseTapGestureRecognizer()
        self.animateLayoutChange {
            self.cardClosedConstraint.isActive = false
            self.cardOpenConstraint.isActive = true
            
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
            self.cardOpenConstraint.isActive = false
            self.cardClosedConstraint.isActive = true
            
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = .clear
        } completion: { _ in
            self.card.alpha = 0.0
            self.trackDetailModalViewModel.track = nil
            self.trackDetailModalViewModel.isOpen = false
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
// MARK: Pan Gesture
extension TrackDetailModalViewController {
    /// Sets up the pan gesture recognizer for dragging the TrackDetailModalView vertically.
    private func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler))
        self.card.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.trackDetailModalViewHostingControllerInitialHeight = self.trackDetailModalViewHostingController.view.frame.height
        case .changed:
            self.setLayoutForDragTranslation(sender.translation(in: self.view))
        case .ended:
            self.setLayoutForEndOfGesture(withTranslation: sender.translation(in: self.view),
                                          velocity: sender.velocity(in: self.view))
        case .possible, .cancelled, .failed:
            return
        @unknown default:
            return
        }
    }
    
    /// Sets the layout when the user drags the card. Will result in a strech animation when the user drags up.
    /// Will drag the view down when the suer drags down
    /// - Parameter translation: The UIPanGestureRecognizer's translation
    private func setLayoutForDragTranslation(_ translation: CGPoint) {
        let verticalGestureTranslation = translation.y
        if (verticalGestureTranslation < 0) {
            // User is dragging up
            self.setLayoutForDragUp(withDragTranslation: verticalGestureTranslation)
        } else  {
            // User is dragging down
            self.setLayoutForDragDown(dragTranslation: verticalGestureTranslation)
        }
    }
    
    /// Adjusts the layout when the user drags the card up. This will create a stretching rubber band effect in the card.
    /// - Parameter translation: The vertical translation in the drag
    private func setLayoutForDragUp(withDragTranslation translation: CGFloat) {
        let translation = -1 * translation
        self.trackDetailModalViewHostingControllerHeightConstraint.constant = self.cardHeightForOverscroll(of: translation,
                                                                                                           initalHeight: self.trackDetailModalViewHostingControllerInitialHeight)
        self.trackDetailModalViewHostingControllerHeightConstraint.isActive = true
    }
    
    /// Determines the height for the card when the the user overscrolls (scrolls up) vertically. This creates a rubber band effect when the user drags the card up.
    /// - Parameter translation: The gesture's vertical translation.
    /// - Parameter initalHeight: Initial height of the card.
    private func cardHeightForOverscroll(of translation: CGFloat, initalHeight: CGFloat) -> CGFloat {
        let value = initalHeight * (1 + log10(abs(translation + initalHeight) / initalHeight))
        return value
    }
    
    /// Adjusts the layout when the user drags the card down. If the user drags past a certain threshold, this will close the card. Otherwise the card
    /// will spring back into the open position
    /// - Parameter translation: The vertical translation in the drag
    private func setLayoutForDragDown(dragTranslation translation: CGFloat) {
        self.cardOpenConstraint.constant = translation
    }
    
    /// Sets the layout after user has completed their gesture
    /// - Parameters:
    ///   - translation: The translation from the UIPanGestureRecognizer
    ///   - velocity: The velocity from the UIPanGestureRecognizer
    private func setLayoutForEndOfGesture(withTranslation translation: CGPoint, velocity: CGPoint) {
        let minimumDragDistanceToClose: CGFloat = 50
        if (translation.y < 0) {
            // DRAG UP
            // Open
            self.resetLayoutToOpen()
        } else if (translation.y >= 0 && translation.y < minimumDragDistanceToClose) {
            // Dragged down slightly.
            // Open
            self.resetLayoutToOpen()
        } else if (translation.y >= minimumDragDistanceToClose) {
            // DRAG DOWN
            if (velocity.y > 0) {
                // VELOCITY DOWN
                // Close
                self.resetLayoutToClosed()
            } else {
                // VELOCITY UP
                // Open
                self.resetLayoutToOpen()
            }
        }
    }
    
    /// Sets the layout of the card back to the open position. This is to be called after the user has concluded their drag gestue.
    private func resetLayoutToOpen() {
        self.trackDetailModalViewHostingControllerHeightConstraint.isActive = false
        self.cardOpenConstraint.constant = 0
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.card.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    /// Sets the layout of the card back to the closed position. This is to be called after the user has concluded their drag gestue.
    private func resetLayoutToClosed() {
        self.trackDetailModalViewHostingControllerHeightConstraint.isActive = false
        self.cardOpenConstraint.constant = 0
        
        self.close()
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
