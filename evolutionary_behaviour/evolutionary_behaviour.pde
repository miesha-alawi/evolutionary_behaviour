int foodnum = 30;
int poisonnum = 10;
int vehiclenum= 10;
ArrayList<Vehicle> vehicles = new ArrayList<Vehicle>();
ArrayList<PVector> food = new ArrayList<PVector>();
ArrayList<PVector> poison = new ArrayList<PVector>();

boolean debug = false;

void setup()
{
  size(600,400);
  //vehicle generation
  for(int i = 0; i < vehiclenum; i++)
  {
    float[] dna = new float[4];
    //food weight
    dna[0] = random(-2,2);
    //poison weight
    dna[1] = random(-2,2);
    //food perception
    dna[2] = random(10,100);
    //poison perception
    dna[3] = random(10,100);
    vehicles.add(new Vehicle(random(width), random(height), dna));
  }
  
  //food generation
  for(int i = 0; i < foodnum; i++)
  {
    addFood(random(width), random(height));
  }
  
  //poison generation
  for(int i = 0; i < poisonnum; i++)
  {
    addPoison();
  }
}

void mousePressed()
{
  debug = !debug;
}

void addFood(float x, float y)
{
  food.add(new PVector(x,y));
}

void addPoison()
{
  float x = random(width);
  float y = random(height);
  poison.add(new PVector(x,y));
}

void draw()
{
  background(50);
  //spawn food 5% chance
  if(random(1) < 0.05) {
    addFood(random(width), random(height));
  }
  //spawn poison 1% chance
  if(random(1) < 0.01) {
    addPoison();
  }
  
  //draw food
  for(int i = 0; i < food.size(); i++)
  {
    fill(0,255,0);
    noStroke();
    ellipse(food.get(i).x, food.get(i).y, 8, 8);
  }
  
  //draw poison
  for(int i = 0; i < poison.size(); i++)
  {
    fill(255,0,0);
    noStroke();
    ellipse(poison.get(i).x, poison.get(i).y, 8, 8);
  }
  
  //iterate backwards to help with concurrent modification
  for(int i = vehicles.size()-1; i >=0 ; i--)
  {
    Vehicle v = vehicles.get(i);
    v.boundaries();
    v.behaviours(food,poison);
    v.update();
    v.draw();
    
    Vehicle baby = v.reproduce();
    if(baby != null)
    {
      vehicles.add(baby);
    }
    
    if(v.dead()) {
    addFood(v.position.x, v.position.y);
    vehicles.remove(v);
    }
    
  }
}
