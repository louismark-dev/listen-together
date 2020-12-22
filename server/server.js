let port = 4401;

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
    })
})