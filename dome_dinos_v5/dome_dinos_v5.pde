// dome dinos
// a sketch to mimic glowing algae
// v1: added syphon client for output to resolume
//     fisheye shader to test fulldome effect
// v2: added midi controll (DJ2Go)
//     added midi control via junxion (logitech joystick)
// v3: scrapped midi, added osc
// v4: FFT to audio reactivity
//     4.1: added button 1 and abs rz for lights on function
//     4.2: scrapped syphon
// v5: more osc controls from pd
//     5.1: scrapped FFT

// press "l" for lights on; press "o" for lights off
// press "f" for fisheye on 

// libraries
import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

// canvas created for interaction w syphon server
PGraphics canvas;

// osc globals
OscP5 oscP5;

// sketch globals
ParticleSystem ps;
Path path;
PVector origin = new PVector(0, 0);
color bColor = color(0, 0, 0, 30);
int pointerX, pointerY;
int pointerXincr = 0;
int pointerYincr = 0;
float pSize;
boolean scatterOn = false;
boolean lightsOn = false;
int lightsHue = 0;
//int screenSize = 2048; // bleep
//int screenSize = 600; // testing
int screenSize = 800; // pico

// fisheye 
PShader fisheye;
boolean fishOn = false;

// setupl
void setup() {
  //size(screenSize, screenSize, P3D); 
  size(848, 480, P3D); 
  background(0);
  canvas = createGraphics(screenSize, screenSize);
  colorMode(HSB, 360, 100, 100);
  frameRate(30);
  canvas.background(0);
  pointerX = width/2;
  pointerY = height/2;
  // draw a grid of particles
  initPS();
  // init path to calculate mouse movement
  path = new Path(pointerX, pointerY);
  // set up fisheye shader
  fisheye = loadShader("FishEye.glsl");
  fisheye.set("aperture", 180.0);
  // initialize osc port
  oscP5 = new OscP5(this, 12000); // listen to port 12000
}

// main loop
void draw() {
  // particle size -- was controlled by minim
  pSize = 30;
  canvas.beginDraw();
  if(lightsOn){
    bColor=color(lightsHue, 100, 100);
  }
  else{
    bColor = color(0, 0, 0, 10);
  }
  // trails
  canvas.noStroke();
  canvas.fill(bColor);
  canvas.rect(0, 0, width, height);
  // user input will change particles' state
  pointerX += pointerXincr;
  pointerY += pointerYincr;
  if (scatterOn) {
    mouseDrag();
  }
  else {
    drawPS();
  }
  canvas.endDraw();
  if (fishOn) {
    shader(fisheye);
  }
  image(canvas, 0, 0);
}

// functions
void initPS() {
  ps = new ParticleSystem(origin);
}

void drawPS() {
  // update ps
  ps.updateParticles(pointerX, pointerY, pSize);
  // display ps
  ps.display();
}

// mouse interactions
boolean firstClick = true;

void mouseDrag() {  
  if (firstClick) {
    // update path to starting point
    path.update(pointerX, pointerY);
    firstClick = false;
    ps.updateParticles(pointerX, pointerY, pSize);
  }
  else {
    path.update(pointerX, pointerY);
    // update particle direction
    PVector ortho = path.getOrtho();
    ortho.mult(0.001);
    ps.updateParticles(pointerX, pointerY, pSize, ortho);
  }
  ps.display();
}

void mouseReleased() {
  firstClick = true;
}

void keyPressed() {
  switch(key) {
  case 'l': 
    if(lightsOn){
      lightsOn = false;
    }
    else{
      lightsOn = true;
    }
    //lightsOn();
    break;
  case 'o':
    lightsOff();
    break;
  case 'f':
    fishOn = true;
    break;
  case 's':
    if(scatterOn){
      scatterOn=false;
    }
    else{
      scatterOn=true;
    }
    break;
  }
}

void lightsOn() {
  bColor=color(0, 0, 100);
}

void lightsOff() {
  bColor = color(0, 0, 0, 30);
}

// osc controller signal 
void oscEvent(OscMessage message){
  int incr = 20; 
  if(message.checkAddrPattern("/joy_xyz")==true){
    if(message.checkTypetag("iii")){
      pointerXincr = int(map(message.get(0).intValue(), 0, 1023, -incr, incr));
      pointerYincr = int(map(message.get(1).intValue(), 0, 1023, -incr, incr));
      lightsHue = int(map(message.get(2).intValue(), 0, 255, 0, 360));
    }
  }
  else if(message.checkAddrPattern("/joy_btn_0")==true){
    if(message.checkTypetag("i")){
      scatterOn = boolean(message.get(0).intValue());
      println("message from button: " + message.get(0).intValue());
    }
  }
  else if(message.checkAddrPattern("/joy_btn_1")==true){
    if(message.checkTypetag("i")){
      lightsOn = boolean(message.get(0).intValue());
      println("message from button: " + message.get(0).intValue());
    }
  }
  constrainPointer();
}

void constrainPointer(){
  if(pointerX <= 0){
      pointerX = width/2;
  }
  else if(pointerX >= width){
    pointerX = width - width/2;
  }
  if(pointerY <= 0){
    pointerY = height/2;
  }
  else if(pointerY >= height){
    pointerY = height/2;
  }
}

