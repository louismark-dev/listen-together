//
//  JoinSessionView.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-24.
//

import SwiftUI

struct SessionView: View {
    @State var sessionID: String = ""
    var socketManager: GMSockets
    
    var body: some View {
        VStack {
            Button("Start New Session") {
                startSession()
            }
            HStack {
                TextField("Session ID", text: $sessionID)
                Button(action: joinSession, label: { Text("Join") })
            }
        }
    }
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.socketManager = socketManager
        GMAppleMusic.generateSampleURL()
    }
    
    private func joinSession() {
        self.socketManager.emitSessionJoinRequest(withSessionID: sessionID)
    }
    
    private func startSession() {
        self.socketManager.emitSessionStartRequest()
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
            .previewLayout(.sizeThatFits)
    }
}
