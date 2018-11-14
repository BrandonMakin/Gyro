var socket, data, startButton;
function setup() {
  createCanvas(window.innerWidth, window.innerHeight);
  background(color(0, 90, 90));
  socket = io.connect();
  //socket.on('rotate', newMovement);
  window.addEventListener("deviceorientation", handleMotionEvent, true);

  noStroke();

  data = { x: 1000, y: 1000, z: 1000 }

  startButton = createButton('start');
  startButton.position(width/2, height/2);
  startButton.mousePressed(clickedStart);
  document.addEventListener('click', enableNoSleep, false);
}

function clickedStart()
{
    makeBackgroundForFun();
}

//function newMovement(data)
//{
//  fill(255,0,100);
//  ellipse(abs(data.z)*3, abs(data.y)*3, 20, 20);
//}


//function draw()
//{
//  var newData = {
//    z: rotationZ,
//    y: rotationY,
//    x: rotationX
//  }
//  var threshold = 1
//  if (  abs(data.z - newData.z) > threshold ||
//        abs(data.y - newData.y) > threshold ||
//        abs(data.x - newData.x) > threshold )
//  {
//    print("sending data")
//    data = newData;
//    socket.emit('rotate', data);
//  }
//}

function handleMotionEvent(e)
{

  // print(e.absolute)
  var newData = {
    x: e.beta,
    y: e.gamma,
    z: e.alpha
  }
  var threshold = 1
  if (  abs(data.z - newData.z) > threshold ||
         abs(data.y - newData.y) > threshold ||
         abs(data.x - newData.x) > threshold )
  {
     // print("sending data")
     data = newData;
     socket.emit('rotate', data);
  }
}

function makeBackgroundForFun()
{
  for (i = 4; i >= 0; i--)
  {
    fill(color(0, (i+2)*90/7, (i+2)*90/7));
    rect(0, i*height/6, width, height/6)
  }
}