//
//  BottomButtonView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI

struct BottomBarView2: View {
    var actions: Actions
    
    struct Actions {
        let sessionSettingsAction: () -> Void
    }
        
    struct Configuration {
        let actions: Actions
    }
    
    init(withConfiguration configuration: Configuration) {
        self.actions = configuration.actions
    }
    
    var body: some View {
        HStack {
            EndSessionButton()
            Spacer()
            AddToQueueButton()
            Spacer()
            self.sessionSettingsButton
        }
        .foregroundColor(.white.opacity(0.9))
        .frame(maxHeight: 60)
        .font(.custom("Arial Rounded MT Bold", size: 18, relativeTo: .title))
    }
    
    struct AddToQueueButton: View {
        var body: some View {
            Button(action: { }) {
                HStack {
                    HStack {
                        Image.ui.plus
                        Text("Add to Queue")
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(Color(UIColor.ui.emerald)))
            }
        }
    }
    
    struct EndSessionButton: View {
        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(Color(UIColor.ui.amaranth))
                Image.ui.stop_fill
            }
            .aspectRatio(contentMode: .fit)
        }
    }
    
    var sessionSettingsButton: some View {
        Button(action: self.actions.sessionSettingsAction) {
            ZStack {
                Circle()
                    .foregroundColor(Color(UIColor.ui.bluetiful))
                Image.ui.person_3_fill
            }
            .aspectRatio(1.0, contentMode: .fit)
        }
    }
}

//struct BottomButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color("RussianViolet")
//                .ignoresSafeArea(.all, edges: .all)
//            BottomBarView2(sessionSettingsAction: {})
//                .padding(.horizontal)
//            
//        }
//    }
//}
