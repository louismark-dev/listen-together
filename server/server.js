let port = parseInt(process.argv.slice(2)) || 4403;

var express = require('express');
var app = express();
app.use(express.json()) // for parsing application/json
var server = require('http').Server(app);
var io = require('socket.io')(server);
const fetch = require('node-fetch');
const fs = require('fs')

server.listen(port);
console.log(`Server is running on port ${port}...`)

// TODO: Need to put the Apple Music API code into a different file

let headers = { "Content-Type": "application/json",
                "Authorization": `Bearer ` };

fs.readFile(`./bearer-token.txt`, 'utf8', function(err, data) { 
    if (err) { return console.log(err) }
    console.log(data)
    const token = data
    headers["Authorization"] = `Bearer ${token}`
})
                                  
app.post("/am-api", (req, res) => {
    const requestJSON = req.body
    const targetURL = requestJSON.requestURL
    // TODO: Error handling. 404, etc...
    fetch(targetURL, { headers })
        .then(res => res.text())
        .then(text => {
            console.log("Sending response")
            console.log(text)
            res.send(text)
        })
  });

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
        const sessionID = data.data.sessionID
        const coordinatorID = data.data.coordinatorID
        const playerState = data.data.playerState

        const encodedString = JSON.stringify({  sessionID: sessionID,
                                                coordinatorID: coordinatorID,
                                                playerState: playerState })

        // console.log(`Clients in room: ${sessionID}`)
        // console.log(io.sockets.clients(sessionID))

        io.to(sessionID).emit(MESSAGES.STATE_UPDATE, encodedString)
    })

    socket.on(MESSAGES.PLAY_EVENT, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Play msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting playEvent to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.PLAY_EVENT, data)
        } else { // Play msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending playEvent to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.PLAY_EVENT, data)
        }
    })

    socket.on(MESSAGES.PAUSE_EVENT, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Pause msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting pauseEvent to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.PAUSE_EVENT, data)
        } else { // Pause msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending pauseEvent to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.PAUSE_EVENT, data)
        }
    })

    socket.on(MESSAGES.FORWARD_EVENT, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Forward msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting fowardEvent to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.FORWARD_EVENT, data)
        } else { // Forward msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending fowardEvent to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.FORWARD_EVENT, data)
        }
    })

    socket.on(MESSAGES.PREVIOUS_EVENT, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Previous msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting previousEvent to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.PREVIOUS_EVENT, data)
        } else { // Previous msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending previousEvent to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.PREVIOUS_EVENT, data)
        }
    })

    socket.on(MESSAGES.NOW_PLAYING_INDEX_DID_CHANGE_EVENT, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        console.log(parsedData)

        if (socket.id == sessionData.coordinatorID) { // Previous msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting nowPlayingIndexDidChangeEvent to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.NOW_PLAYING_INDEX_DID_CHANGE_EVENT, data)
        }
    })

    socket.on(MESSAGES.PREPEND_TO_QUEUE, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Prepend msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting prependToQueue to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.PREPEND_TO_QUEUE, data)
        } else { // Prepend msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending prependToQueue to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.PREPEND_TO_QUEUE, data)
        }
    })

    socket.on(MESSAGES.APPEND_TO_QUEUE, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]

        if (socket.id == sessionData.coordinatorID) { // Append msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting appendToQueue to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.APPEND_TO_QUEUE, data)
        } else { // Append msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending appendToQueue to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.APPEND_TO_QUEUE, data)
        }
    })

    socket.on(MESSAGES.REMOVE_FROM_QUEUE, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]
        
        if (socket.id == sessionData.coordinatorID) { // REMOVE_FROM_QUEUE msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting removeFromQueue to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.REMOVE_FROM_QUEUE, data)
        } else { // Append msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending removeFromQueue to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.REMOVE_FROM_QUEUE, data)
        }
    })

    socket.on(MESSAGES.MOVE_TO_START_OF_QUEUE, function(data) {
        const parsedData = JSON.parse(data)
        const roomID = parsedData.roomID
        const sessionData = current_sessions[roomID]
        
        if (socket.id == sessionData.coordinatorID) { // MOVE_TO_START_OF_QUEUE msg is from coordinator -> Broadcast to all in room
            console.log(`Coordinator ${socket.id} is broadcasting moveToStartOfQueue to room ${roomID}`)
            socket.broadcast.to(roomID).emit(MESSAGES.MOVE_TO_START_OF_QUEUE, data)
        } else { // MOVE_TO_START_OF_QUEUE msg is from guest -> Send to coordinator
            console.log(`Client ${socket.id} is sending moveToStartOfQueue to coordinator ${sessionData.coordinatorID}`)
            socket.broadcast.to(sessionData.coordinatorID).emit(MESSAGES.MOVE_TO_START_OF_QUEUE, data)
        }
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
    ASSIGNING_ID: "assigningID",
    APPEND_TO_QUEUE: "appendToQueue",
    PREPEND_TO_QUEUE: "prependToQueue",
    NOW_PLAYING_INDEX_DID_CHANGE_EVENT: "nowPlayingIndexDidChangeEvent",
    REMOVE_FROM_QUEUE: "removeFromQueue",
    MOVE_TO_START_OF_QUEUE: "moveToStartOfQueue"
}