//
//  SessionSettingsView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-20.
//

import SwiftUI

struct SessionSettingsView: View {
    var body: some View {
        VStack {
            SessionView()
            MonitorView()
        }
        .padding()
    }
}

struct SessionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSettingsView()
    }
}
