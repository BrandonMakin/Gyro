webPort = 8000;
gdPort = webPort + 1;
var GD_CODE = Object.freeze({"misc": 0, "connect":1, "disconnect":2, "qr":8, "ping":9})

console.log("Server is starting up...")


const quaternion = require('quaternion');
const os = require('os');
const QRCode = require('qrcode')
// const defaultGateways = require('default-network');
const defaultGateways = require(process.cwd() + "\\..\\node_server\\node_modules\\default-network");
var express = require('express');
var app = express();
var server = app.listen(8000);
app.use(express.static('www'));

var socket = require('socket.io');
var io = socket(server);
io.sockets.on('connection', newConnection);

var QRCodeURL;
var ipAddr = "";
getIPAddr(generateQR);

function generateQR()
{
  var address = "http://" + ipAddr + ":" + webPort;
  //console.log(address)
  QRCode.toString(address, function(err, qr_string) {
    sendToGodot(qr_string, GD_CODE.qr)
    //console.log(qr_string)
  })
}

var pong = true;
function ping()
{
  sendToGodot("", GD_CODE.ping)
  setTimeout(ping, 6000);
  if (pong == false)
  {
    console.log("The game didn't reply to my ping. Shutting down.")
    process.exit(1);
  }
  pong = false;
}

app.get("/qr", function(req, res)
{
  res.send("");
  sendToGodot(QRCodeURL, GD_CODE.qr)
})

app.get('/pong', function(req, res)
{
  res.send("")
  pong = true;
  //console.log("pong")
})

function newConnection(socket)
{
  console.log("New connection: " + socket.id)
  sendToGodot(socket.id, GD_CODE.connect)

  socket.on('rotate', rotateMsg);
  socket.on('disconnect', onDisconnected)

  function rotateMsg(data)
  {
    var rad = Math.PI / 180;
    var quat = quaternion.fromEuler(data.z * rad, data.x * rad, data.y * rad, 'ZXY');

    // socket.broadcast.emit('mouse', data)
    quat.id = socket.id;
    var msg = JSON.stringify(quat)
    // console.log(msg)
    sendToGodot(msg, GD_CODE.misc)
  }

  function onDisconnected(reason)
  {
    console.log("Disconnected: " + socket.id + " (reason: " + reason + ")")
    sendToGodot(socket.id, GD_CODE.disconnect)
  }
}


/*
function getIPAddr()
finds the ipv4 address of an interface with a default gateway.
default_ifaces holds a list of network interfaces that have default gateways.
As far as I understand, this means that they are networks that are actually connected
to a LAN. The ip addresses associated with these interfaces are therefore the
local ip addresses for the particular LAN.  For simplicity, my code assumes you'll only
be connected to one LAN, so there'll only be at most two valid networks in default_ifaces:
one for ipv4 and one for ipv6.  getIPAddr() just chooses the first ipv4 interface
in default_ifaces, and returns its address.
*/
function getIPAddr(callback)
{
  defaultGateways.collect( //get default gateways
    function(error, data) {
      names = Object.keys(data);

      var default_ifaces = os.networkInterfaces()[names[0]]
      for (let iname in default_ifaces)
      {
        if (default_ifaces[iname].family != "IPv6")
        {
          ipAddr = default_ifaces[iname].address;
          console.log("IP address is: " + ipAddr);
        }
      }
      callback();
    }
  );
}
/////////////////////////////////////////////////////////////////////////
//code to communicate with godot
var client = require('dgram').createSocket('udp4');

///////////////////////
// UNCOMMENT IF YOU WANT THE UDP CLIENT TO BE BOUND TO A SPECIFIC PORT
// client.bind({
//   port: 54345,
//   exclusive: false
// });

function sendToGodot(msg, code) { //code must be a member of GD_CODE; expected to be a digit between 0-9
  msg = "" + code + msg;
  // bufferedMessage = new Buffer('Hello, Go\ndot of mine.');
  bufferedMessage = new Buffer(msg);

  client.send(bufferedMessage, 0, bufferedMessage.length, gdPort, "localhost", function(err, bytes) {
      if (err) throw err;
      // console.log('UDP message sent to localhost:'+ gdPort);
      // client.close();
  });
}
/////////////////////
// UNCOMMENT IF YOU WANT GODOT TO BE ABLE TO SEND UDP MESSAGES TO NODE
// client.on('message', (msg, rinfo) => {
//   console.log(`${msg}`);
// });
//
// client.on('listening', () => {
//   pong = true;
//   const address = client.address();
//   console.log(`udp server listening on port: ${address.port}`);
// });
/////////////////////////////////////////////////////////////////////////


// console.log(process.cwd() + "node_modules\\default-network");

ping();
