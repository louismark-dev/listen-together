//
//  MonitorView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-26.
//

import SwiftUI

struct MonitorView: View {
    @ObservedObject var socketManager: GMSockets = GMSockets.sharedInstance
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.socketManager.state.isCoordinator ? "Coordinator" : "Not Coordinator")
            Text("Client ID: \(self.socketManager.state.clientID ?? "Unavailable")")
            Text("Coordinator ID: \(self.socketManager.state.coordinatorID ?? "Unavailable")")
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(self.socketManager.state.isCoordinator ? Color.green : Color.orange)
        
    }
    
}

struct MonitorView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorView()
    }
}
