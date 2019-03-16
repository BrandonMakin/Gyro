webPort = 8000;
gdPort = webPort + 1;
let GD_CODE = Object.freeze({"connect":1, "disconnect":2, "button":3, "rotate":4, "qr":8, "ping":9})

console.log("Server is starting up...")


const quaternion = require('quaternion');
const os = require('os');
const QRCode = require('qrcode')
// const defaultGateways = require('default-network');
const defaultGateways = require(process.cwd() + "\\..\\node_server\\node_modules\\default-network");
let express = require('express');
let app = express();
let server = app.listen(8000);
app.use(express.static('www'));

let socket = require('socket.io');
let io = socket(server);
io.sockets.on('connection', newConnection);

let QRCodeURL;
let ipAddr = "";
getIPAddr(generateQR);

function generateQR()
{
  let address = "http://" + ipAddr + ":" + webPort;
  //console.log(address)
  QRCode.toString(address, function(err, qr_string) {
    sendToGodot(qr_string, GD_CODE.qr)
    //console.log(qr_string)
  })
}

let pong = 0;
function ping()
{
  sendToGodot("", GD_CODE.ping)
  setTimeout(ping, 20000);
  if (pong == 2)
  {
    console.log("The game didn't reply to my ping. Shutting down.")
    process.exit(1);
  }
  pong++;
}

app.get("/qr", function(req, res)
{
  res.send("");
  sendToGodot(QRCodeURL, GD_CODE.qr)
})

app.get('/pong', function(req, res)
{
  res.send("");
  pong = 0;
  //console.log("pong")
})

function newConnection(socket)
{
  console.log("New connection: " + socket.id);
  sendToGodot(socket.id, GD_CODE.connect);

  socket.on('rotate', on_rotate);
  socket.on('disconnect', on_disconnect);
  socket.on('bshoot', on_button_shoot);
  socket.on('bshock', on_button_shock);
  socket.on('baccel', on_button_accel);

  function on_rotate(data)
  {
    // Orientations: x=beta, y=gamma, z=alpha
    // Ignore alpha, only use gamma to determine correct adjustment for beta
    let angle = data.x;
    let tilt = 0.5;
    // Landscape-left, tilted away from user, counter-clockwise or clockwise
    if(data.y < 0 && data.x < 90 && data.x > -90){
      // Speed
      tilt = (((data.y + 90) / 90) / 2) + 0.5;
    }
    // Landscape-left, tilted toward user, counter-clockwise
    else if(data.y > 0 && data.x < -90){
      // Steering
      angle = -180 - data.x;
      // Speed
      tilt = (data.y / 90) / 2;
    }
    // Landscape-left, tilted toward user, clockwise
    else if(data.y > 0 && data.x > 90){
      // Steering
      angle = 180 - data.x;
      // Speed
      tilt = (data.y / 90) / 2;
    }
    // Landscape-right, tilted away from user, counter-clockwise or clockwise
    else if(data.y > 0 && data.x < 90 && data.x > -90){
      // Steering
      angle = data.x;
      // Speed
      tilt = (((90 - data.y) / 90) / 2) + 0.5;
    }
    // Landscape-right, tilted toward user, counter-clockwise
    else if(data.y < 0 && data.x > 90){
      // Steering
      angle = 180 - data.x;
      // Speed
      tilt = (Math.abs(data.y) / 90) / 2;
    }
    // Landscape-right, tilted toward user, clockwise
    else if(data.y < 0 && data.x < -90){
      // Steering
      angle = -180 - data.x;
      // Speed
      tilt = (Math.abs(data.y) / 90) / 2;
    }
    // Set speed from tilt
    // console.log(Math.round(angle), Math.round(tilt * 100));
    // console.log(Math.round(data.x), Math.round(data.y), "-", Math.round(angle), Math.round(tilt * 100))

    // // Uncomment to get a quaternion:
    // let quat = get_quat(data, socket.id);
    // let msg = JSON.stringify(quat)
    let msg = JSON.stringify({id:socket.id, a:angle, t:tilt});
    sendToGodot(msg, GD_CODE.rotate)
  }

  function on_disconnect(reason)
  {
    console.log("Disconnected: " + socket.id + " (reason: " + reason + ")")
    sendToGodot(socket.id, GD_CODE.disconnect)
  }

  function on_button_shoot(data)
  {
      // console.log("BUTTON - shoot - " + data)
      sendToGodot('{"n":"shoot","s":"' + data + '","i":"' + socket.id + '"}', GD_CODE.button)
  }
  function on_button_shock(data)
  {
      // console.log("BUTTON - shock - " + data)
      sendToGodot('{"n":"shock","s":"' + data + '","i":"' + socket.id + '"}', GD_CODE.button)
  }
  function on_button_accel(data)
  {
      // console.log("BUTTON - accel - " + data)
      sendToGodot('{"n":"accel","s":"' + data + '","i":"' + socket.id + '"}', GD_CODE.button)
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

      let default_ifaces = os.networkInterfaces()[names[0]]
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
let client = require('dgram').createSocket('udp6');

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

function get_quat(data, id)
{
    let rad = Math.PI / 180;
    let quat = quaternion.fromEuler(data.z * rad, data.x * rad, data.y * rad, 'ZXY');
    quat.id = id;
    return quat
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
