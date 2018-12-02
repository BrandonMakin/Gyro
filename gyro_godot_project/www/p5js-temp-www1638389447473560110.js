var socket, data, button_shoot, button_shock, button_accel;
function setup() {
  createCanvas(window.innerWidth, window.innerHeight);
  background(color(0, 90, 90));
  socket = io.connect();
  //socket.on('rotate', newMovement);
  window.addEventListener("deviceorientation", handleMotionEvent, true);

  noStroke();

  data = { x: 1000, y: 1000, z: 1000 }

  button_shoot = createButton('SHOOT');
  button_shock = createButton('SHOCK');
  button_accel = createButton('ACCELERATE');
  
  button_shoot.position(0, 0);
  button_shock.position(width/5, 0);
  button_accel.position(4*width/5, 0);
  
  button_shoot.size(width/5, height)
  button_shock.size(3*width/5, height)
  button_accel.size(width/5, height)
  
  button_shoot.mousePressed(on_button_shoot);
  button_shock.mousePressed(on_button_shock);
  button_accel.mousePressed(on_button_start);
  
  button_shoot.style('background-color', "224422")
  button_shock.style('background-color', "40c080")
  button_accel.style('background-color', "224422")
  
  button_shoot.style('color', "ffffff")
  button_accel.style('color', "ffffff")
  
  //button_shoot
  //button_shock
  //button_accel
  
  startButton.mousePressed(clickedStart);
  document.addEventListener('click', enableNoSleep, false);
}

function on_button_shoot()
{
  
}

function on_button_shock()
{
  
}

function on_button_start()
{
  
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
