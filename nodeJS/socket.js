const express = require("express");
const cors = require("cors");
const app = express();
const fileUpload = require("express-fileupload");
const fsExtra = require("fs-extra");
var server = require("http").Server(app);
var io = require("socket.io")(server, {
  cors: {
    origin: "*",
  },
});

let port = parseInt(process.argv.slice(2)); // First argument is the port where this server will live.

fsExtra.emptyDirSync("public"); // Empty ./public/ on start of server

app.use(cors());
app.use(express.static("public")); // Serve the items in /public for download
app.use(
  fileUpload({
    createParentPath: true, // Make /public available for file uploads
  })
);
app.options("*", cors());

app.get("/", (req, res) => {
  res.send("Hello World!"); // Print "Hello World" on server homepage
});

/**
 * Post request to "/" endpoint will save the provided file to the ./public/ directory
 */
app.post("/", async (req, res) => {
  try {
    if (!req.files) {
      res.send({
        status: false,
        message: "No file uploaded",
      });
    } else {
      //Use the name of the input field (i.e. "song") to retrieve the uploaded file
      let song = req.files.song;

      //Use the mv() method to place the file in upload directory (i.e. "uploads")
      song.mv("./public/" + song.name);

      //send response
      res.send({
        status: true,
        message: "File is uploaded",
        data: {
          name: song.name,
          mimetype: song.mimetype,
          size: song.size,
        },
      });
    }
  } catch (err) {
    res.status(500).send(err);
  }
});

/**
 * Setup socket connections between server and clients.
 * Listen for incoming events from clients, and forward that same event to all other clients.
 * 
 * Note: Very important to use socket.broadcast.emit(), rather than socket.emit(), to ensure that 
 * events aren't emitted back to the original sender.
 */
io.on("connection", function (socket) {
  console.log(`A user connected with ID`, socket.id);

  socket.emit("test event", "here is some data");

  socket.on("playEvent", (data) => {
    console.log(`Emitting playEvent to all clients. Sender: ${data.senderID}`);
    socket.broadcast.emit("playEvent", data);
  });

  socket.on("pauseEvent", (data) => {
    console.log(`Emitting pauseEvent to all clients. Sender: ${data.senderID}`);
    socket.broadcast.emit("pauseEvent", data);
  });

  socket.on("nextEvent", (data) => {
    console.log(`Emitting nextEvent to all clients. Sender: ${data.senderID}`);
    socket.broadcast.emit("nextEvent", data);
  });

  socket.on("previousEvent", (data) => {
    console.log(
      `Emitting previousEvent to all clients. Sender: ${data.senderID}`
    );
    socket.broadcast.emit("previousEvent", data);
  });

  socket.on("sample message", () => {
    console.log(`Emitting sample message to all clients.`);
    socket.broadcast.emit("sample message");
  });

  socket.on("seekEvent", (data) => {
    console.log(
      `Emitting previousEvent to all clients. Sender: ${data.senderID}`
    );
    socket.broadcast.emit("seekEvent", data);
  });

  socket.on("deleteEvent", (data) => {
    console.log(
      `Emitting deleteEvent to all clients. Sender: ${data.senderID}`
    );
    socket.broadcast.emit("deleteEvent", data);
  });

  socket.on("addEvent", (data) => {
    console.log(`Emitting addEvent to all clients. Sender: ${data.senderID}`);
    socket.broadcast.emit("addEvent", data);
  });
});
/**
 * Start the server at given port number
 */
server.listen(port, () => {
  console.log(`Socket.io server is listening on port ${port}.`);
});
