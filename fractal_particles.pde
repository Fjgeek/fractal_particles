/**this sketch generates 3D fractal particle patterns that 
   respond to face tracking and mouse commands.
   
   CONTROLS:
   -face tracking: modulates the arrangement of particles in X,Y, and Z space.
   -left mouse click/hold: warps the evolution of particles to a random point.
   -right mouse click/hold: moves the center axis to mouse X/Y coordinates.
   
*/

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

float n = 1;
float elapsed = 1;
float warp = 1;
float orbit = 1;
boolean dir = false;

float mX = 0;
float mY = 0;
float mZ = 0;

int transY = 0;
int transX  = 0;


void setup(){
  //frameRate(30);
  size(800,800, P3D); 
  //fullScreen(P3D, 1);
  pixelDensity(displayDensity());
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  video.start();
  transX = width/2;
  transY = height/2;
  translate(transX,transY);
}

void draw() { 
  background(255);
  opencv.loadImage(video);

  //image(video, 0, 0);

  Rectangle[] faces = opencv.detect(); // face tracking
  for (int i = 0; i < faces.length; i++) {
  mX = map(faces[i].x+(faces[i].width/2), 0, video.width, width*.0016, -width*.0016);
  mY = map(faces[i].y+(faces[i].height/2), 0, video.height, height*.0016, -height*.0016);
  mZ = map(faces[i].width, 0, video.width, -width*.016, width*.016);
  }
  if(mousePressed && mouseButton == RIGHT){ //move the center axis while right mouse button clicked 
    transX = mouseX;
    transY = mouseY; 
  }
  translate(transX, transY); //center axis
  
  rotateY(orbit); //rotation around ceter axis
  orbit = orbit + .0005; 
  if(orbit > 361){
    orbit = 1;
  }
  
  for(float i = -8; i < 8; i = i + .8) { // layer 3 of recursion repetition
    rotateX(i*10);
    rotateX(sin(n*10));
    translate(sin(n*10)*100,sin(n*10)*100,sin(n*10)*100); //layer 2 of recursion repetition
    for(float r = -4; r < 4; r = r + .5) {
      rotateY(sin(r));
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      recursion(width/16*r,height/16*r,10);
      rotateX(cos(-r));
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      recursion(width/32*r,height/32*r ,1);
      rotateZ(map(noise(r), 0, 1, -1, 1));
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      recursion(width/64*r,height/64*r,1);
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      rotateY(sin(-r));
      recursion(width/128*r,height/128*r,1);
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      rotateX(cos(r));
      recursion(width/256*r,height/256*r,1);
      translate(sin(n)*2, sin(n)*2, sin(n)*2);
      rotateZ(map(noise(r), 0, 1, 1, -1));
      recursion(width/512*r,height/512*r,1);
      
    }
  }
  println(n, warp, dir);
  
  if(mousePressed && mouseButton == LEFT) { //warps the evolution of the particles to a random point
    if(n < warp) {
    n = n+((warp-n)/10);
    }
    if(n > warp) {
    n = n-((n-warp)/10);
    }
    if((n < warp) && (n > warp)) {
      n = warp;
    }
  }else{
    if(dir == true){
      n = n + map((noise(sin(elapsed))*.01), 0, 1, 0, .01);
      elapsed = cos(elapsed) + sin(n);
    }
    if(dir == false) { //reverses direction of evolution
      n = n - map((noise(sin(elapsed))*.01), 0, 1, 0, .01);
      elapsed = cos(elapsed) - sin(n); 
    }
    if(n > 2){
      dir = false;
    }
    if(n < 1) {
      dir = true;
    }
  }
}

void recursion(float x, float y, float z) { //layer 1 of recursion 
  for(float i = 1 ; i < 3; i = i + 1) {
    translate(noise(n)*(mX), noise(n)*(mY), noise(n)*(mZ));
    stroke(map(noise(n), 0, 1, 20, 100), 0, map(noise(n), 0, 1, 20, 125)); //color 1
    strokeWeight(noise(sin(n*2)*20)*5);
    point(x*noise(n*18), y*noise(n*i), z*sin(n*35)*10+i); //point 1
    
    strokeWeight(noise(cos(n*3)*22)*4.5);
    rotateY(cos(n));
    translate(noise(n)*(mX), noise(n)*(mY), noise(n)*(mZ));
    point(x*noise(n*81), y*noise(n*51), z*cos(n*99)*10); //point 2
    
    strokeWeight(noise(tan(n*2)*30)*6);
    rotateX(sin(n));
    stroke(map(random(255), 0, 255, 100, 255), map(noise(n), 0, 1, 0, 40), random(200)); //color 2
    translate(noise(-n)*(mX), noise(n)*(mY), noise(-n)*(mZ));
    point(x*noise(n*92), y*noise(n*87), z*sin(n*i)*10); //point 3
      if(z < 1.001) {
        strokeWeight(noise(tan(n)*12)*4.8);
        rotateZ(cos(n)/2);
        translate(map(noise(n), 0, 1, -10, 10)*mX,map(noise(n), 0, 1, -10, 10)*mY,map(noise(n), 0, 1, -10, 10)*mZ);
        recursion(x*1.001,y*1.001, z*1.001);
    }
  }
}

void mousePressed() { //changes the warp value to a random number
  warp = random(100)*.01 +1;
  
}

void captureEvent(Capture c) {
  c.read();
}