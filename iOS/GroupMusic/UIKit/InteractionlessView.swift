//
//  InteractionlessView.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-07.
//

import UIKit

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

