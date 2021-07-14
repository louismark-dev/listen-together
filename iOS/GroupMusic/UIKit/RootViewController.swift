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
    
    let playerAdapter = PlayerAdapter()
    var playerAdapterState: GMAppleMusicHostController.State = GMAppleMusicHostController.State()
    private var appleMusicManager: GMAppleMusic! // TODO: Remove this dependancy. It is only for testing
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: View Setup
    
    override func viewDidLoad() {
        self.setupBackgroundBlurViewController()
        self.setupBottomBar()
        
        self.appleMusicManager = GMAppleMusic(storefront: .canada)
        self.subscribeToPlayerAdapterPublishers()
    }
    
    private func subscribeToPlayerAdapterPublishers() {
        self.playerAdapter.$state
            .receive(on: RunLoop.main)
            .sink { state in
                self.playerAdapterState = state
                print("COUNT \(self.playerAdapterState.queue.state.queue.count)")
            }
            .store(in: &cancellables)
    }
    
    // MARK: Bottom Bar Setup
    
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
        self.bottomBarHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bottomBarHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomBarHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    // MARK: Background Blur Setup
    
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

