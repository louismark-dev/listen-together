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
    private var manager: SocketManager = SocketManager(socketURL: URL(string: "ws://localhost:4430")!, config: [.log(false), .compress])
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
        self.socket.on(clientEvent: .connect, callback: self.connectEventHandler)
        
        self.socket.on(Event.sessionStarted.rawValue, callback: self.sessionStartedEventHandler)
        
        self.socket.on(Event.assigningID.rawValue, callback: self.assigningIdEventHandler)
        
        self.socket.on(Event.joinFailed.rawValue, callback: self.joinFailedEventHandler)
        
        self.socket.on(Event.requestStateUpdate.rawValue, callback: self.requestStateUpdateEventHandler)
        
        self.socket.on(Event.stateUpdate.rawValue, callback: self.stateUpdateEventHandler)
        
        self.socket.on(Event.playEvent.rawValue, callback: self.playEventHandler)
        
        self.socket.on(Event.pauseEvent.rawValue, callback: self.pauseEventHandler)
        
        self.socket.on(Event.forwardEvent.rawValue, callback: self.forwardEventHandler)
        
        self.socket.on(Event.previousEvent.rawValue, callback: self.previousEventHandler)
    }
    
    private func connectEventHandler(data: [Any], ack: SocketAckEmitter) {
        // Wait for successful connection to emit events
        print("Socket status: \(self.socket.status)")
        self.socket.emit("testEvent", "Hello")
    }
    
    private func sessionStartedEventHandler(data: [Any], ack: SocketAckEmitter) {
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
    
    private func assigningIdEventHandler(data: [Any], ack: SocketAckEmitter) {
        let id: String = data[0] as! String
        self.state.assignClientID(id)
    }
    
    private func joinFailedEventHandler(data: [Any], ack: SocketAckEmitter) {
        // TODO Send notification when join fails
        print("Join Failed")
    }
    
    private func requestStateUpdateEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("State update requested.")
        self.notificationCenter.post(name: .stateUpdateRequested, object: nil)
    }
    
    private func stateUpdateEventHandler(data: [Any], ack: SocketAckEmitter) {
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
    
    private func playEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("playEvent recieved")
        self.notificationCenter.post(name: .playEvent, object: nil)
    }
    
    private func pauseEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("pauseEvent recieved")
        self.notificationCenter.post(name: .pauseEvent, object: nil)
    }
    
    private func forwardEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("forwardEvent recieved")
        self.notificationCenter.post(name: .forwardEvent, object: nil)
    }
    
    private func previousEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("previousEvent recieved")
        self.notificationCenter.post(name: .previousEvent, object: nil)
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
    
    public func emitPlayEvent() throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        self.socket.emit(Event.playEvent.rawValue,  "{ \"roomID\": \"\(sessionID)\" }")
    }
    
    public func emitPauseEvent() throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        self.socket.emit(Event.pauseEvent.rawValue, "{ \"roomID\": \"\(sessionID)\" }")
    }
    
    public func emitForwardEvent() throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        self.socket.emit(Event.forwardEvent.rawValue,  "{ \"roomID\": \"\(sessionID)\" }")
    }
    
    public func emitPreviousEvent() throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        self.socket.emit(Event.previousEvent.rawValue,  "{ \"roomID\": \"\(sessionID)\" }")
    }
    
    enum EventEmitterErrors: Error, LocalizedError {
        case noSessionId
        
        public var errorDescription: String? {
            switch self {
            case .noSessionId: return String("No sessionID set when emitting this event")
            }
        }
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
        // TODO: Make this use Codable to decode the dictionary
        // We can put the session_id and coordinator_id keys into another Struct, and
        // feed that Struct to this function to update its values without overwriting
        // the clientID
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
