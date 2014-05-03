class ParticleSystem{
  ArrayList<Particle> particles;
  PVector psOrigin;
  int pStrokeWeight = 3;
  int prox = 20;
  color pColor = color(220,50,255);
  
  ParticleSystem(PVector l){
   psOrigin = l;
   particles = new ArrayList();
   int incr = 30;
   for (int i = 0; i < width; i += incr){
     for (int j = 0; j < height; j+= incr){
       addParticle(new PVector(i, j));
      }
   } 
  }
  
  void addParticle(PVector l){
    particles.add(new Particle(l));
  }
 
  void updateParticles(int pX, int pY, float w){
   // update particle size
   pStrokeWeight  = int(w);
    // update particle loc
   canvas.strokeWeight(pStrokeWeight);
   for (int i = 0; i < particles.size(); i++){
      Particle p = particles.get(i);
      //PVector force = n.attract(p);
      //p.applyForce(force);
      // check for proximity to mouse, change color & vel
      if(p.mouseProximity(pX, pY, prox)){
        p.setColor(color(220,100,100));
      }
      p.update();
    }
  }
  
  void updateParticles(int pX, int pY, float w, PVector mouseHeading){
   // update particle size
   pStrokeWeight = int(w);
   // update particle loc
   canvas.strokeWeight(pStrokeWeight);
   for (int i = 0; i < particles.size(); i++){
      Particle p = particles.get(i);
      // check for proximity to mouse, change color & vel
      if(p.mouseProximity(pX, pY, prox)){
        p.setColor(color(220,100,100));
        p.applyForce(mouseHeading);
      }
      p.update();
    }
  }
  
  void display(){
    for (int i = 0; i < particles.size(); i++){
      Particle p = particles.get(i);
      canvas.stroke(p.getColor());
      canvas.point(p.getLoc().x, p.getLoc().y);
    }
  }
}

class Particle{
  PVector loc;
  PVector vel;
  PVector acc;
  float mass = 0.1;
  //float iniV = 0.2;
  float iniV = 2;
  int pHue = 220;
  color pColor = color(pHue, 100, 0);
  float dieOff = 0.9; // higher is faster fade to black
  float accDieOff = 1;
  
  Particle(PVector l){
    loc = l.get();
    vel = new PVector(random(-iniV, iniV), random(-iniV, iniV));
    acc = new PVector(0,0);
   }
  
  PVector getLoc(){
    return loc;
  }
  
  color getColor(){
    return pColor;
  }
  
  void setColor(color c){
    pColor = c;
  }
  
  void setAcc(float m){
    acc.setMag(m);
  }
  
  void update(){
    if(acc.mag() > 0){
      this.setAcc(acc.mag()-accDieOff);
    }
    else if(acc.mag() < 0){
      this.setAcc(acc.mag()+accDieOff);
    }
        
    vel.add(acc);
    this.bounds();
    loc.add(vel);
    if(brightness(pColor) > 0){
      this.setColor(color(pHue, 100, brightness(pColor) - dieOff));
    }
  }
  
   //method to bounce particles of canvas edges
  void bounds(){
    if(loc.y > height || loc.y < 0){
      vel.y *= -1;
    }
    if(loc.x > width || loc.x < 0){
      vel.x *= -1;
    }
  }
  void applyForce(PVector force){
    // originally: 
    acc.add(force);
    //vel.add(force);
  }
  
  // check if mouse is nearby
  boolean mouseProximity(int pX, int pY, int prox){
    return (pX > loc.x-prox && pX < loc.x+prox && pY > loc.y-prox && pY < loc.y+prox);
  }
}
