let port = parseInt(process.argv.slice(2));

var express = require('express');
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(port);
console.log(`Server is running on port ${port}...`)

io.sockets.on("connection", function(socket) {
    console.log("NEW CONNECTION")

    socket.on("testEvent", function(data) { 
        console.log("Test event recieved")
    })

    socket.on("playEvent", function(data) { 
        console.log("Play event recieved")
        socket.broadcast.emit("playEvent", data)
    })

    socket.on("pauseEvent", function(data) { 
        console.log("Pause event recieved")
        socket.broadcast.emit("pauseEvent", data)
    })

    socket.on("forwardEvent", function(data) { 
        console.log("forwardEvent recieved")
        socket.broadcast.emit("forwardEvent", data)
    })

    socket.on("previousEvent", function(data) { 
        console.log("previousEvent recieved")
        socket.broadcast.emit("previousEvent", data)
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