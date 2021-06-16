//
//  GeometryGetter.swift
//  GroupMusic
//
//  Created by Louis on 2021-06-15.
//

import SwiftUI

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }
    
    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .local)
        }

        return Rectangle().fill(Color.clear)
    }
}
