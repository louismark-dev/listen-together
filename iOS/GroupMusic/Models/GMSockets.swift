//
//  GMSockets.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-21.
//

import Foundation
import SocketIO
import MediaPlayer

class GMSockets: ObservableObject {
    private let notificationCenter: NotificationCenter
    private var manager: SocketManager = SocketManager(socketURL: URL(string: "ws://192.168.2.139:\((UIApplication.shared.delegate as! AppDelegate).port)")!, config: [.log(false), .compress])
    private var socket: SocketIOClient
    private var backgroundTaskID: UIBackgroundTaskIdentifier? = nil
    private var timer: Timer? = nil
    @Published var state: State = State()
    
    static let sharedInstance = GMSockets()
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        self.socket = self.manager.defaultSocket
        self.addHandlers()
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Sockets") {
            print("SOCKET CONNECTION WILL DIE")
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
        }
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
        
        self.socket.on(Event.appendToQueue.rawValue, callback: self.appendToQueueEventHandler)
        
        self.socket.on(Event.prependToQueue.rawValue, callback: self.prependToQueueEventHandler)
        
        self.socket.on(Event.nowPlayingIndexDidChangeEvent.rawValue, callback: self.nowPlayingIndexDidChangeEventHandler)
        
//        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer: Timer) in
//            print("Execution time remaining: \(UIApplication.shared.backgroundTimeRemaining)")
//        }
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
        
        
        guard let jsonString = data[0] as? String else {
            print("Could not unwrap string")
            // TODO: Handle this
            return
        }
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        do {
            let newState = try decoder.decode(GMSockets.State.self, from: jsonData)
            
            self.state.sessionID = newState.sessionID
            self.state.coordinatorID = newState.coordinatorID
            
            self.notificationCenter.post(name: .stateUpdateEvent, object: newState.playerState)
        } catch {
            print("State update decoding failed \(error)")
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
    
    private func appendToQueueEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("appendToQueueEvent recieved")
        do {
            let tracks = try self.dataToObject(data: data) as [Track]
            self.notificationCenter.post(name: .appendToQueueEvent, object: tracks)
        } catch {
            fatalError("prependToQueueEventHandler decoding failed \(error.localizedDescription)")
        }
    }
    
    private func prependToQueueEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("prependToQueueEvent recieved")
        do {
            let tracks = try self.dataToObject(data: data) as [Track]
            self.notificationCenter.post(name: .prependToQueueEvent, object: tracks)
        } catch {
            print("prependToQueueEventHandler decoding failed \(error.localizedDescription)")
        }
    }
    
    private func nowPlayingIndexDidChangeEventHandler(data: [Any], ack: SocketAckEmitter) {
        print("nowPlayingIndexDidChangeEvent recieved")
        do {
            let indexOfNowPlayingItem = try self.dataToObject(data: data) as Int
            self.notificationCenter.post(name: .nowPlayingIndexDidChangeEvent, object: indexOfNowPlayingItem)
        } catch {
            fatalError("nowPlayingDidChangeEventHandler decoding failed \(error.localizedDescription)")
        }
    }
    
    private func dataToObject<T: Codable>(data: [Any]) throws -> T {
        guard var jsonString = data[0] as? String else {
            throw JSONDecodingErrors.couldNotCastAsString
        }
        // URLs in the JSONString will have "\\" before each "/". Remove these.
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        let decodedValue = try decoder.decode(SocketIOArguments<T>.self, from: jsonData)
        return decodedValue.data
    }
    
    // MARK: Emitters - Outgoing Events
    public func emitSessionStartRequest() {
        self.socket.emit(Event.startSession.rawValue, "")
    }
    
    public func emitSessionJoinRequest(withSessionID sessionID: String) {
        self.socket.emit(Event.joinSession.rawValue, sessionID)
    }
    
    public func emitStateUpdate(withState state: State) throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        let arguments = SocketIOArguments<State>(roomID: sessionID, data: state)
        let encodedJSON = try self.encodeJSON(fromObject: arguments)
        self.socket.emit(Event.stateUpdate.rawValue, encodedJSON)
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
    
    public func emitPrependToQueueEvent(withTracks tracks: [Track]) throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        let arguments = SocketIOArguments<[Track]>(roomID: sessionID, data: tracks)
        let encodedJSON = try self.encodeJSON(fromObject: arguments)
        self.socket.emit(Event.prependToQueue.rawValue, encodedJSON)
    }
    
    public func emitAppendToQueueEvent(withTracks tracks: [Track]) throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        let arguments = SocketIOArguments<[Track]>(roomID: sessionID, data: tracks)
        let encodedJSON = try self.encodeJSON(fromObject: arguments)
        self.socket.emit(Event.appendToQueue.rawValue, encodedJSON)
    }
    
    public func emitNowPlayingDidChangeEvent(withIndex index: Int) throws {
        guard let sessionID = self.state.sessionID else { throw EventEmitterErrors.noSessionId }
        let arguments = SocketIOArguments<Int>(roomID: sessionID, data: index)
        let encodedJSON = try self.encodeJSON(fromObject: arguments)
        self.socket.emit(Event.nowPlayingIndexDidChangeEvent.rawValue, encodedJSON)
    }
    
    private func encodeJSON<T: Codable>(fromObject object: T) throws -> String {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(object)
            let encodedString = String(data: data, encoding: .utf8)!
            return encodedString
        } catch {
            throw JSONEncodingErrors.couldNotEncodeJSON
        }
    }
    
    enum JSONDecodingErrors: Error, LocalizedError {
        case couldNotCastAsString
        
        
        public var errorDescription: String? {
            switch self {
            case .couldNotCastAsString: return String("Was unable to cast the incoming data as a string")
            }
        }
    }
    
    enum JSONEncodingErrors: Error, LocalizedError {
        case couldNotEncodeJSON
        
        public var errorDescription: String? {
            switch self {
            case .couldNotEncodeJSON: return String("Was unable to encode this object into JSON")
            }
        }
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
        case playEvent
        case pauseEvent
        case forwardEvent
        case previousEvent
        case startSession
        case sessionStarted
        case joinSession
        case joinFailed
        case stateUpdate
        case requestStateUpdate
        case assigningID
        case queueUpdate
        case appendToQueue
        case prependToQueue
        case nowPlayingIndexDidChangeEvent
    }
    
    public func updateQueuePlayerState(with queuePlayerState: GMAppleMusicHostController.State) {
        self.state.playerState = queuePlayerState
        do {
            try self.emitStateUpdate(withState: self.state)
        } catch {
            print("WARNING: Could not emit state update. Error: \(error.localizedDescription)")
        }
    }
    
}
// MARK: Notification Center Events
/// Notification Center events
extension Notification.Name {
    static var stateUpdateEvent: Notification.Name {
        return .init(rawValue: "GMSockets.stateUpdateEvent")
    }
    
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
    
    static var appendToQueueEvent: Notification.Name {
        return .init(rawValue: "GMSockets.appendToQueueEvent")
    }
    
    static var prependToQueueEvent: Notification.Name {
        return .init(rawValue: "GMSockets.prependToQueueEvent")
    }
    
    static var stateUpdateRequested: Notification.Name {
        return .init(rawValue: "GMSockets.stateUpdateRequested")
    }
    
    static var nowPlayingIndexDidChangeEvent: Notification.Name {
        return .init(rawValue: "GMSockets.nowPlayingIndexDidChangeEvent")
    }
}

extension GMSockets {
    struct SocketIOArguments<Wrapped:Codable>: Codable {
        let roomID: String
        let data: Wrapped
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
        var playerState: GMAppleMusicHostController.State?
        
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
