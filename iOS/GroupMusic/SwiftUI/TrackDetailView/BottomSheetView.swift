//
//  BottomSheetView.swift
//  GroupMusic
//
//  Created by Louis on 2021-03-14.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    @Binding var maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    init(isOpen: Binding<Bool>, maxHeight: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight.wrappedValue * 0.0
        self._maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight)))
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: self.offset)
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 0.33
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(isOpen: .constant(true), maxHeight: .constant(500)) {
            Color.red
        }
    }
}
