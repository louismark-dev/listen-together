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