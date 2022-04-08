//
//  QueueCellBackground.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI
import URLImage

struct QueueCellBackground: View {
    @State var artworkURL: URL?
    @Binding var expanded: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(Color(self.expanded ? "BlackChocolateLight" : "BlackChocolate"))
                .opacity(0.55)
        }
    }
}

//struct QueueCellBackground_Previews: PreviewProvider {
//    static var previews: some View {
//        QueueCellBackground(artworkName: "YoungThug", expanded: .constant(false))
//            .previewLayout(.fixed(width: 350, height: 80))
//    }
//}
