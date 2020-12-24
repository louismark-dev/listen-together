let port = parseInt(process.argv.slice(2)) || 4402;

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
        const id = generateUniqueID()
        addSession(id)
        console.log(`Starting session with id ${id}`)
        console.log(`Session data is: ${current_sessions[id]}`)
        socket.emit(MESSAGES.SESSION_STARTED, current_sessions[id])
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

function addSession(id) { 
    current_sessions[id] = { 
        start_time: new Date(),
        disconnect_time: null
    }
}

const MESSAGES = {
    START_SESSION: "startSession",
    SESSION_STARTED: "sessionStarted",
    FORWARD_EVENT: "forwardEvent",
    PREVIOUS_EVENT: "previousEvent",
    PLAY_EVENT: "playEvent",
    PAUSE_EVENT: "pauseEvent",
    TEST_EVENT: "testEvent"
}