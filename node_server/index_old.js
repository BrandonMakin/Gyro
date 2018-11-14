const port = 8000;

const os = require('os');
const express = require('express');
const bodyParser = require('body-parser');
// const crypto = require('crypto');
const defaultGateways = require('default-network');

const app = express();
const server = app.listen(port, function() { console.log("Now listening..."); })

const socket = require('socket.io')(server);
const io = socket(server)

app.use(express.static('www')); //host static webpages

// var ipAddr;
// getIPAddr();

//////////////////////////////////////////////////////////////////////////////////////////
console.log("Server is starting up.");

io.sockets.on('connection', newConnection)

function newConnection()
{
  console.log('new connection: ' + socket.id)
}


// app.get('/serverIP.js', sendIPandPort);
// function sendIPandPort(request, response)
// {
//   response.send("var serverIP = \"" + ipAddr + "\"; \nvar serverPort = " + port + ";");
// }


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
function getIPAddr()
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
    }
  );
}
