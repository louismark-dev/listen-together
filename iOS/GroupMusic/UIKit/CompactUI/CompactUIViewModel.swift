//
//  CompactUIViewModel.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-07.
//

import Combine
import SwiftUI

class CompactUIViewModel: ObservableObject {
    @Published var isOpen = false
    @Published var layoutData: LayoutData?
    
    func open(with layoutData: LayoutData) {
        self.isOpen = true
        self.layoutData = layoutData
    }
    
    struct LayoutData {
        let heading: Text
        let subheading: Text?
        let leftIcon: Image?
    }
}
