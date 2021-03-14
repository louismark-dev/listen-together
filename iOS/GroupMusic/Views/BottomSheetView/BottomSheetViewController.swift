//
//  BottomSheetViewController.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import SwiftUI

class BottomSheetViewController: ObservableObject {
    @State var isOpen: Bool = true
    @Published var view = BottomSheetView(isOpen: .constant(false), maxHeight: 500) {
        Color.red
    }
    
    init() {
        self.newModal()
    }
    
    func newModal() {
        view = BottomSheetView(isOpen: .constant(true), maxHeight: 500) {
            Color.green
        }
    }
}
