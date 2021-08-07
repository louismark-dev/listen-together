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
    }
    
    func configure(with configuration: Configuration) {
        self.compactUIViewModel = configuration.compactUIViewModel
    }
    
    private func initalizeViews() {
        self.setInteractionlessBackground()
        self.configureCompactUIView()
    }
    
    private func setInteractionlessBackground() {
        self.view = InteractionlessView()
    }
    
    private func configureCompactUIView() {
        self.compactUIHostingController = UIHostingController(rootView: CompactUIView(compactUIViewModel: self.compactUIViewModel))
        self.compactUIHostingController.view.backgroundColor = .clear
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
        
        self.cardClosedConstraint = self.compactUIHostingController.view.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        self.cardOpenConstraint = self.compactUIHostingController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        self.cardOpenConstraint.isActive = false
    }
    
    // MARK: Data
    
    private func subscribeToPublishers() {
        self.subscribeToIsOpenPublisher()
    }
    
    /// Subscribes to TrackDetailViewModel's isOpen publisher.
    /// Will open the TrackDetailVIewModal when isOpen is true.
    private func subscribeToIsOpenPublisher() {
        self.compactUIViewModel.$isOpen
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { (isOpen: Bool) in
                if (isOpen == true) {
                    print("COMPACT OPEN")
                    self.open()
                } else {
                    print("COMPACT CLOSE")
                    self.close()
                }
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
    
    private func animateLayoutChange(_ layoutChange: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut, animations: layoutChange)
    }
}
