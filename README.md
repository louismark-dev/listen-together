# Listen Together
Listen Together lets users share control of their music playback with friends.

Please note that this project remains a work in progress.

## Video Demo
[A video demonstration is available here](https://youtu.be/TglLpBrY1bg).

## Screenshots and User Interface
### Party Queue
The background of the Party Queue adopts the colours of the currently playing song.
![Queue Screenshots](https://i.imgur.com/gLOND0K.png)

Users can add, remove and rearrange songs in the Party Queue.
![Managing songs in the queue (Screenshot)](https://i.imgur.com/2rS3pT7.png)

When scrolling, users are provided a shortcut to return to the currently playing item in the Party Queue.
![Return to Now Playing (Screenshot)](https://i.imgur.com/2bHYjnQ.png)

## Apple Music Library
Users can search and select from millions of songs in the Apple Music Catalog. Please note that the Seach UI remains a work in progress.

<img src="https://i.imgur.com/yAzCktu.png" width="400">

The user interface adapts to the predominant colors of the music artwork.
![Album Pages (Screenshot)](https://i.imgur.com/AZ1rCID.png)

Users can preview songs on their own device, before adding it to the Party Queue.

<img src="https://i.imgur.com/bjzyU63.png" width="400">

## Architectural Details
Socket.IO (based on WebSocket technology) was selected to enable bidirectional, low-latency, event-based communication between Play Together clients. Messages are routed through a centralized Socket.IO server running on Node.JS. A handshake procedure has been established to ensure that all clients remain synchronized, even in case of network disruption.

All music and associated metadata is provided via the Apple Music API.

## Running the Project
### Server
`listen-together/server/server.js` contains all the code necessary to run the server. Messages are passed between the server and clients using Socket.IO. To start the server `node server.js [desired port number]`

Connecting to the Apple Music API requires you to generate a unique [Apple Music developer token](https://developer.apple.com/documentation/applemusicapi/generating_developer_tokens). This token must be stored in a plain text file at `server/bearer-token.txt`. To create a token you must be a member of the Apple Developer Program.

### iOS
Before to compiling the project, the following values must be updated in the source code to connect to the server:
* The `port` variable on line 13 of AppDelegate must be the port associated with the server.
* The IP address on line 22 of `GMAppleMusic.swift` must be the IP address of the server on your local network.
* The IP address on line 14 of `GMSockets.swift` must be the IP address of the server on your local network.

A production version of this application would include a handshake procedure to automatically connect the iOS app to the server.

After compiling the Xcode project, Play Together can be run on any iPhone. Due to limitations of the Apple Music API, the application cannot be run on the iOS simulator.
