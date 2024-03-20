//Vehicle class referenced from 'Nature of Code'
//Daniel Shiffman

class Vehicle {
  PVector acceleration, velocity, position;
  float r, maxspeed, maxforce;
  float[] dna;
  float health;
  float mutateScale;
  Vehicle(float x, float y, float[]d)
  {
    //movement
    acceleration = new PVector(0,0);
    velocity = new PVector(0, -2);
    position = new PVector(x,y);
    maxspeed = 5;
    maxforce = 0.2;
    //size
    r = 6;
    
    //mutation and dna
    //chance to mutate
    if(random(1) > 0.01)
    {
      //mutation scale
      mutateScale = random(-0.1,0.1);
    } else {
      mutateScale = 0;
    }
    
    dna = new float[4];
    for(int i = 0; i < 4; i++)
    {
      dna[i] = d[i]+=mutateScale;
    }
    
    health = 1;
  }
  
  void update()
  {
    //update health
    health -= 0.001;
    //update velocity
    velocity.add(acceleration);
    //limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    //reset acceleration to 0 each cycle
    acceleration.mult(0);
  }
  
  void behaviours(ArrayList<PVector> good, ArrayList<PVector> bad)
  {
    PVector steerGood = eat(good, 0.1, dna[2]);
    PVector steerBad = eat(bad, -0.5, dna[3]);
    
    steerGood.mult(dna[0]);
    steerBad.mult(dna[1]);
    
    applyForce(steerGood);
    applyForce(steerBad);
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  //boundary handling
  void boundaries()
  {
    //d = distance from the edge
    int d = 25;
    PVector desired = null;
    
    if(position.x < d) {
      desired = new PVector(maxspeed, velocity.y);
    }
    else if(position.x > width - d) {
      desired = new PVector(-maxspeed, velocity.y);
    }
    
    if(position.y < d) {
      desired = new PVector(velocity.x, maxspeed);
    }
    else if(position.y > height - d) {
      desired = new PVector(velocity.x, -maxspeed);
    }
    
    if(desired != null) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
  }
  
  //calculates a steering force towards a target
  //steer = desired - velocity
  PVector seek(PVector target)
  {
    PVector desired = PVector.sub(target, position);
    
    //scale to max speed
    desired.setMag(maxspeed);
    
    //steering = desired - velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce); //limit to max steering force
    
    return steer;
  }
  
  Vehicle reproduce()
  {
    if(random(1) < 0.001) {
    return new Vehicle(position.x,position.y,dna);
    } else
    {
      return null;
    }
  }
  
  //function that finds and eats closest piece of food
  PVector eat(ArrayList<PVector> list, float nutrition, float perception)
  {
    double record = Double.POSITIVE_INFINITY;
    int closestIndex = -1;
    for(int i = 0; i < list.size(); i++)
    {
      float d = position.dist(list.get(i));
      if(d < record && d < perception) {
        record = d;
        closestIndex = i;
      }
    }
    
    //moment of eating
    if(record < 5) {
      list.remove(closestIndex);
      health += nutrition;
    } else if(closestIndex > -1){
      return seek(list.get(closestIndex));
    }
    
    return new PVector(0,0);
  }
  
  boolean dead()
  {
    return health < 0;
  }
  
  void draw()
  {
    //draw a triangle rotated in the direction of velocity
    //angle
    float theta = velocity.heading() + PI / 2;
    
    if(debug)
    {
      //circles for food and poison perception
      stroke(255,100);
      noFill();
      //food
      ellipse(position.x,position.y,dna[2],dna[2]);
      stroke(0,100);
      noFill();
      //poison
      ellipse(position.x,position.y,dna[3],dna[3]);
    }
    
    //colour depending on health
    color gr = color(0,255,0);
    color rd = color(255,0,0);
    color col = lerpColor(rd,gr,health);
    fill(col,150);
    stroke(col,200);
    strokeWeight(1);
    
    //position and shape
    push();
    translate(position.x,position.y);
    rotate(theta);
    beginShape();
    vertex(0, -r * 2);
    vertex(-r, r *2);
    vertex(r,r*2);
    endShape(CLOSE);
    
    if(debug)
    {
      //dna food and poison weight visual
      strokeWeight(2);
      //food
      stroke(255,100);
      line(0,0,0,-dna[0]*50);
      //poison
      stroke(0,100);
      line(0,0,0,-dna[1]*50);
    }
    pop();
  }
}
