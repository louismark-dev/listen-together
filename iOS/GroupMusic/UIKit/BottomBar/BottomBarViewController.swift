//
//  BottomBarViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-03.
//

import UIKit
import SwiftUI

class BottomBarViewController: UIViewController {
    var bottomBarHostingController: UIHostingController<BottomBarView2>!
    
    override func viewDidLoad() {
        self.initalizeViews()
        self.configureViewHirearchy()
        self.setupLayout()
    }
    
    private func initalizeViews() {
        self.bottomBarHostingController = self.generateBottomBar()
    }
    
    private func configureViewHirearchy() {
        self.addChild(self.bottomBarHostingController)
        self.view.addSubview(self.bottomBarHostingController.view)
    }
    
    private func setupLayout() {
        self.bottomBarHostingController.view.backgroundColor = .clear
        
        self.bottomBarHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBarHostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.bottomBarHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bottomBarHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bottomBarHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func generateBottomBar() -> UIHostingController<BottomBarView2>{
        let actions = BottomBarView2.Actions(sessionSettingsAction: self.sessionSettingsAction)
        let configuration = BottomBarView2.Configuration(actions: actions)
        return UIHostingController(rootView: BottomBarView2(withConfiguration: configuration))
    }
    
    private func sessionSettingsAction() {
        self.present(SessionSettingsViewController(), animated: true)
    }
}
