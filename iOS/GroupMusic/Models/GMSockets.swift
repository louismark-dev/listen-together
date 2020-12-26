//
//  GMSockets.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-21.
//

import Foundation
import SocketIO

class GMSockets: ObservableObject {
    private let notificationCenter: NotificationCenter
    private var manager: SocketManager = SocketManager(socketURL: URL(string: "ws://localhost:4419")!, config: [.log(false), .compress])
    private var socket: SocketIOClient
    @Published var state: State = State()
    private var queuePlayerState: GMQueuePlayer.State?
    
    static let sharedInstance = GMSockets()
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        self.socket = self.manager.defaultSocket
        self.addHandlers()
        self.socket.connect()
    }
    // MARK: Handlers - Incoming Events
    private func addHandlers() {
        self.socket.on(clientEvent: .connect) { (data, ack) in
            // Wait for successful connection to emit events
            print("Socket status: \(self.socket.status)")
            self.socket.emit("testEvent", "Hello")
        }
        
        self.socket.on(Event.sessionStarted.rawValue) { (data, ack) in
            print(data)
            guard let data = data[0] as? [String:Any] else {
                print("Could not unwrap dictionary")
                // TODO: Handle this
                return
            }
            do {
                try self.state.update(with: data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        self.socket.on(Event.assigningID.rawValue) { (data, ack) in
            let id: String = data[0] as! String
            self.state.assignClientID(id)
        }
        
        self.socket.on(Event.joinFailed.rawValue) { (data, ack) in
            // TODO Send notification when join fails
            print("Join Failed")
        }
        
        self.socket.on(Event.requestStateUpdate.rawValue) { (data, ack) in
            print("State update requested.")
            self.notificationCenter.post(name: .stateUpdateRequested, object: nil)
        }
        
        self.socket.on(Event.stateUpdate.rawValue) { (data, ack) in
            print("State update recieved")
            guard let data = data[0] as? [String:Any] else {
                print("Could not unwrap dictionary")
                // TODO: Handle this
                return
            }
            do {
                try self.state.update(with: data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        self.socket.on(Event.playEvent.rawValue) { (data, ack) in
            print("playEvent recieved")
            self.notificationCenter.post(name: .playEvent, object: nil)
        }
        
        self.socket.on(Event.pauseEvent.rawValue) { (data, ack) in
            print("pauseEvent recieved")
            self.notificationCenter.post(name: .pauseEvent, object: nil)
        }
        
        self.socket.on(Event.forwardEvent.rawValue) { (data, ack) in
            print("forwardEvent recieved")
            self.notificationCenter.post(name: .forwardEvent, object: nil)
        }
        
        self.socket.on(Event.previousEvent.rawValue) { (data, ack) in
            print("previousEvent recieved")
            self.notificationCenter.post(name: .previousEvent, object: nil)
        }
    }
    
    // MARK: Emitters - Outgoing Events
    public func emitSessionStartRequest() {
        self.socket.emit(Event.startSession.rawValue, "")
    }
    
    public func emitSessionJoinRequest(withSessionID sessionID: String) {
        self.socket.emit(Event.joinSession.rawValue, sessionID)
    }
    
    public func emitStateUpdate(withState state: State) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(state)
            let encodedString = String(data: data, encoding: .utf8)! //
            self.socket.emit(Event.stateUpdate.rawValue, encodedString)
        } catch {
            fatalError("Could not contruct state update")
        }
    }
    
    public func emitPlayEvent() {
        self.socket.emit(Event.playEvent.rawValue, "")
    }
    
    public func emitPauseEvent() {
        self.socket.emit(Event.pauseEvent.rawValue, "")
    }
    
    public func emitForwardEvent() {
        self.socket.emit(Event.forwardEvent.rawValue, "")
    }
    
    public func emitPreviousEvent() {
        self.socket.emit(Event.previousEvent.rawValue, "")
    }
    
    /// SocketIO Events
    enum Event: String {
        case playEvent, pauseEvent, forwardEvent, previousEvent, startSession, sessionStarted, joinSession, joinFailed, stateUpdate, requestStateUpdate, assigningID
    }
    
    public func updateQueuePlayerState(with queuePlayerState: GMQueuePlayer.State) {
        self.queuePlayerState = queuePlayerState
        self.emitStateUpdate(withState: self.state)
    }
    
}
// MARK: Notification Center Events
/// Notification Center events
extension Notification.Name {
    static var playEvent: Notification.Name {
        return .init(rawValue: "GMSockets.playEvent")
    }

    static var pauseEvent: Notification.Name {
        return .init(rawValue: "GMSockets.pauseEvent")
    }
    
    static var forwardEvent: Notification.Name {
        return .init(rawValue: "GMSockets.forwardEvent")
    }
    
    static var previousEvent: Notification.Name {
        return .init(rawValue: "GMSockets.previousEvent")
    }
    
    static var stateUpdateRequested: Notification.Name {
        return .init(rawValue: "GMSockets.stateUpdateRequested")
    }
}

extension GMSockets {
    /// Represents the current state of the session
    /// - Parameters:
    ///     - sessionID: ID of current listening sesssion. This corresponds to the room ID on ths erver
    ///     - coordinatorID: ID of the coordinator
    ///     - clientID: ID given to this device
    struct State: Codable {
        var sessionID: String?
        var coordinatorID: String?
        var clientID: String?
        var isCoordinator: Bool  {
            guard let coordinatorID = self.coordinatorID,
                  let clientID = self.clientID else {
                return false
            }
            return coordinatorID == clientID
        }
        
        init() { }
        
        mutating func update(with dictionary: [String: Any]) throws {
            guard let sessionID = dictionary["session_id"] as? String,
                  let coordinatorID = dictionary["coordinator_id"] as? String else {
                throw StateError.decoding
            }
            self.sessionID = sessionID
            self.coordinatorID = coordinatorID
            
            if let clientID = dictionary["client_id"] as? String {
                self.clientID = clientID
            }
        }
        
        mutating func assignClientID(_ id: String) {
            self.clientID = id
        }
        
        enum StateError: Error {
            case decoding
        }
    }
}
