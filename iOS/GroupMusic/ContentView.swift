//
//  ContentView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            SessionView()
            Spacer()
            PlayerView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
