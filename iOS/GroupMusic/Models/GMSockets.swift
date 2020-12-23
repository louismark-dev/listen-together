//
//  GMSockets.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-21.
//

import Foundation
import SocketIO

class GMSockets {
    private var manager: SocketManager = SocketManager(socketURL: URL(string: "ws://localhost:4000")!, config: [.log(false), .compress])
    private var socket: SocketIOClient
    
    static let sharedInstance = GMSockets()
    
    init() {
        self.socket = self.manager.defaultSocket
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print("Socket status: \(self.socket.status)")
            self.socket.emit("testEvent", "Hello")
        }
        self.socket.connect()
    }
    
    public func emitPlayEvent() {
        self.socket.emit(Event.playEvent.rawValue, "")
    }
    
    public func emitPauseEvent() {
        self.socket.emit(Event.pauseEvent.rawValue, "")
    }
    
    enum Event: String {
        case playEvent, pauseEvent
    }
    
}
