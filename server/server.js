let port = parseInt(process.argv.slice(2)) || 4440;

var express = require('express');
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(port);
console.log(`Server is running on port ${port}...`)

io.sockets.on("connection", function(socket) {
    console.log("NEW CONNECTION")

    socket.on(MESSAGES.TEST_EVENT, function(data) { 
        console.log("Test event recieved")
    })

    // Host calls this to start a new session
    socket.on(MESSAGES.START_SESSION, function(data) { 
        const sessionId = generateUniqueID()
        const coordinatorID = socket.id
        addSession(sessionId, coordinatorID)
        console.log(`Starting session with sessionID ${sessionId} and coordinator ID ${coordinatorID}`)
        console.log(`Session data is: ${current_sessions[sessionId]}`)
        socket.join(sessionId) // Create room with session id
        socket.emit(MESSAGES.SESSION_STARTED, { session_id: sessionId,
                                                coordinator_id: coordinatorID,
                                                client_id: coordinatorID })
    })

    socket.on(MESSAGES.JOIN_SESSION, function(data) { 
        // Find ID in current_sessions
        // If the ID is not found, send JOIN_FAILED.
        // If the ID is found, request state update from coordinator
        const sessionID = data
        let coordinatorID = null 
        if (!(sessionID in current_sessions)) {
            socket.emit(MESSAGES.JOIN_FAILED, data)
        } else {
            socket.join(sessionID) // Join the room, so this client can get future state updates.
            coordinatorID = current_sessions[sessionID]["coordinatorID"]
            console.log(`The coordinator ID is ${coordinatorID}`)
            // Need to request current state from coordinator
            console.log("Requesting state update from coordinator")
            socket.emit(MESSAGES.ASSIGNING_ID, socket.id)
            socket.to(coordinatorID).emit(MESSAGES.REQUEST_STATE_UPDATE)
        }
    })

    socket.on(MESSAGES.STATE_UPDATE, function(data) { 
        console.log("State update recieved.")
        console.log(data)
        data = JSON.parse(data)
        // Need to forward this to all clients in room
        const sessionID = data["sessionID"]
        const coordinatorID = data["coordinatorID"]

        // console.log(`Clients in room: ${sessionID}`)
        // console.log(io.sockets.clients(sessionID))

        io.to(sessionID).emit(MESSAGES.STATE_UPDATE, {  session_id: sessionID,
                                                            coordinator_id: coordinatorID })
    })

    socket.on(MESSAGES.PLAY_EVENT, function(data) { 
        console.log("Play event recieved")
        socket.broadcast.emit(MESSAGES.PLAY_EVENT, data)
    })

    socket.on(MESSAGES.PAUSE_EVENT, function(data) { 
        console.log("Pause event recieved")
        socket.broadcast.emit(MESSAGES.PAUSE_EVENT, data)
    })

    socket.on(MESSAGES.FORWARD_EVENT, function(data) { 
        console.log("forwardEvent recieved")
        socket.broadcast.emit(MESSAGES.FORWARD_EVENT, data)
    })

    socket.on(MESSAGES.PREVIOUS_EVENT, function(data) { 
        console.log("previousEvent recieved")
        socket.broadcast.emit(MESSAGES.PREVIOUS_EVENT, data)
    })
})

// HELPER FUNCTIONS

let current_sessions = { }
const ID_LENGTH = 6

/**
 * Creates a unique ID comprised of six randomly generated alphanumeric characters.
 * The ID is not case sensitive. The ID is guaranteed not to exist in current_sessions
 */
function generateUniqueID() {
    let length = ID_LENGTH
    let chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    var id = '';
    for (var i = length; i > 0; --i) {
        id += chars[Math.floor(Math.random() * chars.length)]
    }
    if (id in current_sessions) {
        return generateUniqueID()
    } else { 
        return id
    }
}

function addSession(sessionID, coordinatorID) { 
    current_sessions[sessionID] = { 
        sessionID: sessionID,
        coordinatorID: coordinatorID
    }
}

const MESSAGES = {
    START_SESSION: "startSession",
    JOIN_SESSION: "joinSession",
    JOIN_FAILED: "joinFailed",
    STATE_UPDATE: "stateUpdate",
    REQUEST_STATE_UPDATE: "requestStateUpdate",
    SESSION_STARTED: "sessionStarted",
    FORWARD_EVENT: "forwardEvent",
    PREVIOUS_EVENT: "previousEvent",
    PLAY_EVENT: "playEvent",
    PAUSE_EVENT: "pauseEvent",
    TEST_EVENT: "testEvent",
    ASSIGNING_ID: "assigningID"
}