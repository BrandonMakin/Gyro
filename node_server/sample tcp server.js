// // server to communicate with Godot
// const net = require('net');
// var sockets = [];
// var server = net.createServer();
// server.on('connection', function(socket)
// {
//   console.log("connection established");
//   socket.setEncoding('utf8');
//   sockets.push(socket);
//   socket.on('data', function(data)
//   {
//     console.log(data);
//   })
// })
//
// server.listen(gdPort);
