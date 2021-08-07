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
    
    init() {
        self.layoutData = LayoutData(heading: Text("Return to Now Playing"),
                                     subheading: Text("Blueberry Faygo - Lil Mosey"),
                                     leftIcon: Image.ui.arrow_uturn_backward_circle_fill)
    }
    
    struct LayoutData {
        let heading: Text
        let subheading: Text?
        let leftIcon: Image?
    }
}
