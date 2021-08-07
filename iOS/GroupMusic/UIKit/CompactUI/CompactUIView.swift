//
//  CompactUIView.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-07.
//

import SwiftUI

struct CompactUIView: View {
    @ObservedObject var compactUIViewModel: CompactUIViewModel
    
    var body: some View {
        if let layoutData = compactUIViewModel.layoutData {
            HStack {
                self.icon(layoutData.leftIcon)
                self.labels(heading: layoutData.heading,
                            subheading: layoutData.subheading)
            }
            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
            .background(self.background())
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder private func icon(_ iconImage: Image?) -> some View {
        if let iconImage = iconImage {
            iconImage
                .foregroundColor(Color.blue)
                .imageScale(.large)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder private func labels(heading: Text, subheading: Text?) -> some View {
        VStack {
            heading
                .fontWeight(.semibold)
                .opacity(0.8)
            if let subheading = subheading {
                subheading
                    .fontWeight(.semibold)
                    .opacity(0.6)
            } else {
                EmptyView()
            }
        }
        .font(.system(.footnote, design: .rounded))
        .foregroundColor(.black)
    }
    
    @ViewBuilder private func background() -> some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
    }
}
