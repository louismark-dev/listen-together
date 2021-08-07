//
//  CompactUIView.swift
//  GroupMusic
//
//  Created by Louis on 2021-08-07.
//

import SwiftUI

struct CompactUIView: View {
    var body: some View {
        HStack {
            self.icon()
            self.labels()
        }
        .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
        .background(self.background())
    }
    
    @ViewBuilder private func icon() -> some View {
        Image(systemName: "arrow.uturn.backward.circle.fill")
            .foregroundColor(Color.blue)
            .imageScale(.large)
    }
    
    @ViewBuilder private func labels() -> some View {
        VStack {
            Text("Return to Now Playing")
                .fontWeight(.semibold)
                .opacity(0.8)
            Text("Blueberry Faygo")
                .fontWeight(.semibold)
                .opacity(0.6)
        }
        .font(.system(.footnote, design: .rounded))
        .foregroundColor(.black)
    }
    
    @ViewBuilder private func background() -> some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
    }
}

struct CompactUIView_Previews: PreviewProvider {
    static var previews: some View {
        CompactUIView()
    }
}
