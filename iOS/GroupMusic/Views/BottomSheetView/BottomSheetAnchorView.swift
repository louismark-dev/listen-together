//
//  BottomSheetAnchorView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import SwiftUI

struct BottomSheetAnchorView: View {
    @EnvironmentObject var bottomSheetViewController: BottomSheetViewController
    
    var body: some View {
        BottomSheetView(isOpen: .constant(true), maxHeight: 500) {
            self.bottomSheetViewController.view
        }
    }
}

struct BottomSheetAnchorView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetAnchorView()
    }
}
