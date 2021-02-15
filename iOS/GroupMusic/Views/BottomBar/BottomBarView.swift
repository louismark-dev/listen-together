//
//  BottomBarView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI

struct BottomBarView: View {
    @State var showSessionSettings: Bool = false
    @State var activeSheet: ActiveSheet?
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    var body: some View {
        HStack {
            EndSessionButton()
            AddToQueueButton(activeSheet: self.$activeSheet)
            SessionSettingsButton(activeSheet: self.$activeSheet)
        }
        .foregroundColor(.white)
        .opacity(0.9)
        .frame(maxHeight: 60)
        .font(.custom("Arial Rounded MT Bold", size: 18, relativeTo: .title))
        .sheet(isPresented: self.$showSessionSettings) {
            SessionSettingsView()
        }
        .sheet(item: self.$activeSheet) { (item: ActiveSheet) in
            switch item {
            case .sessionSettings: SessionSettingsView()
            case .addToQueue: AppleMusicSearchView()
                .environmentObject(self.playerAdapter)
            }
        }
    }
    
    struct AddToQueueButton: View {
        @Binding var activeSheet: ActiveSheet?
        
        var body: some View {
            Button(action: { self.activeSheet = .addToQueue  }) {
                HStack {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to Queue")
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .foregroundColor(Color("Emerald")))
                .padding()
            }
        }
    }
    
    struct EndSessionButton: View {
        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(Color("Amaranth"))
                Image(systemName: "stop.fill")
            }
            .aspectRatio(contentMode: .fit)
        }
    }
    
    struct SessionSettingsButton: View {
        @Binding var activeSheet: ActiveSheet?
        
        var body: some View {
            Button(action: { self.activeSheet = .sessionSettings }) {
                ZStack {
                    Circle()
                        .foregroundColor(Color("Bluetiful"))
                    Image(systemName: "person.3.fill")
                }
                .aspectRatio(1.0, contentMode: .fit)
            }
        }
    }
    
    enum ActiveSheet: Identifiable {
        case sessionSettings, addToQueue
        
        var id: Int {
            hashValue
        }
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("RussianViolet")
                .ignoresSafeArea(.all, edges: .all)
            BottomBarView()
            
        }
    }
}
