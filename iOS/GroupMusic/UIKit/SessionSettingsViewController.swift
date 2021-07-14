//
//  SessionSettingsViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-14.
//

import UIKit
import SwiftUI

class SessionSettingsViewController: UIViewController {
    var sessionSettingsHostingController: UIHostingController<SessionSettingsView>!
    override func viewDidLoad() {
        self.setupSessionSettingsView()
    }
    
    private func setupSessionSettingsView() {
        self.configureSessionSettingsView()
        self.setupSessionSettingsLayout()
    }
    
    private func configureSessionSettingsView() {
        self.sessionSettingsHostingController = UIHostingController(rootView: SessionSettingsView())
    }
    
    private func setupSessionSettingsLayout() {
        self.view.addSubview(self.sessionSettingsHostingController.view)
        self.addChild(self.sessionSettingsHostingController)
        
        self.sessionSettingsHostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.sessionSettingsHostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.sessionSettingsHostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.sessionSettingsHostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.sessionSettingsHostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}
