//
//  GMSockets.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-21.
//

import Foundation

class GMSockets {
    let queuePlayer: GMQueuePlayer
    private var socketConnection: URLSessionWebSocketTask?
    
    init(queuePlayer: GMQueuePlayer) {
        self.queuePlayer = queuePlayer
        
        self.connectToSocket()
    }
    
    func connectToSocket() {
        let url = URL(string: "wss://echo.websocket.org")!
        self.socketConnection = URLSession.shared.webSocketTask(with: url)
    
        self.setRecieveHandler()
        self.socketConnection?.resume()
        self.sendTestMessage()
    }
    
    private func setRecieveHandler() {
        self.socketConnection?.receive { (result) in
            defer { self.setRecieveHandler() }
            
            switch result {

            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data recieved \(data)")
                case .string(let string):
                    print("String recieved \(string)")
                @unknown default:
                    print("Unknown datatype recieved")
                }
            case .failure(let error):
                print("Error in recieving message \(error)")
            }
        }
    }
    
    private func sendTestMessage() {
        let message = URLSessionWebSocketTask.Message.string("Hello World")
        self.socketConnection?.send(message) { error in
          if let error = error {
            print("WebSocket couldn’t send message because: \(error)")
          }
        }
    }
    
}
