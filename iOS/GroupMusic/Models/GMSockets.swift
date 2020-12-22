//
//  GMSockets.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-21.
//

import Foundation
import SocketIO

class GMSockets {
    let queuePlayer: GMQueuePlayer
    private var manager: SocketManager = SocketManager(socketURL: URL(string: "ws://localhost:4400")!, config: [.log(false), .compress])
    private var socket: SocketIOClient
    
    init(queuePlayer: GMQueuePlayer) {
        self.queuePlayer = queuePlayer
        self.socket = self.manager.defaultSocket
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print("Socket status: \(self.socket.status)")
            self.socket.emit("testEvent", "Hello")
        }
        self.socket.connect()
    }
    
}
