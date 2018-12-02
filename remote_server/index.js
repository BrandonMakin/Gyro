console.log("Gyro server starting up...");

let quaternion = require('quaternion');
let express   = require('express');
let app       = express();
let http      = require('http').Server(app);
let io        = require('socket.io')(http);
let dgram     = require('dgram')
let client_v4 = dgram.createSocket('udp4');
// let client_v6  = dgram.createSocket('udp6');

let port_web = 80;
let port_godot = 8001;
let remote_address_of_host = "localhost";

/* Serve the website in the www folder */
app.use(express.static('www'));

app.get("/testip", function(req, res)
{
  let address = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log("IP requested by: " + req.headers['x-forwarded-for'] + " , " + req.connection.remoteAddress + " -- " + address)
  res.send(req.connection.remoteAddress);
})

app.get("/hostgame", function(req, res)
{
  let address = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log("" + address + " is hosting a game.")
  remote_address_of_host = address;
  res.send("200 OK");
})

io.sockets.on('connection', new_connection);
function new_connection(socket)
{
  // Possible messages:
  socket.on('rotate', onRotate);
  socket.on('disconnect', onDisconnect)


  console.log("New connection: " + socket.id);
  sendToGodot(socket.id, GD_CODE.connect);


  function onRotate(data)
  {
    var rad = Math.PI / 180;
    var quat = quaternion.fromEuler(data.z * rad, data.x * rad, data.y * rad, 'ZXY');
    quat.id = socket.id;
    var msg = JSON.stringify(quat)
    sendToGodot(msg, GD_CODE.misc)
  }

  function onDisconnect(reason)
  {
    console.log("Disconnected: " + socket.id + " (reason: " + reason + ")")
    sendToGodot(socket.id, GD_CODE.disconnect)
  }
}

http.listen(port_web, '0.0.0.0', function(){
  console.log('listening on *:' + port_web);
});

// Send messages to Godot:
let GD_CODE = Object.freeze({"misc": 0, "connect":1, "disconnect":2, "qr":8, "ping":9})
function sendToGodot(msg, code) { //code must be a member of GD_CODE; expected to be a digit between 0-9
  msg = "" + code + msg;
  bufferedMessage = new Buffer(msg);

  client_v4.send(bufferedMessage, 0, bufferedMessage.length, port_godot, remote_address_of_host, function(err, bytes) {
      if (err) throw err;
  });
}
