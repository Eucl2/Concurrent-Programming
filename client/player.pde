class Player {
  String username;
  float fuel;
  int cor; 
  PVector pos;
  boolean enemy; // eu ou outro
  float speed=150;
  int alive=1;
  
 
  Player(){
    this.username="Default";
    this.fuel=0;
    this.cor=0;
    this.pos= new PVector(0,0);
    this.speed=150;
  }
  Player(String username,float x1, float y1, float fuel, int cor,boolean enemy,int alive){
    this.pos=new PVector(x1,y1);
    this.fuel=fuel;
    this.enemy=enemy;
    this.username=username;
    this.cor=cor;
    this.alive=alive;
    this.speed=150;
    
  }
  synchronized void move(float x1, float y1){
    this.pos=new PVector(x1,y1);
  }
  synchronized PVector getPos(){
    return pos;
  }
  synchronized void setFuel(float s){
  this.fuel=s;
  }
  synchronized float getFuel(){
    return fuel; 
  }
  void show(){
    if (alive==1){
    
    if(enemy){
      fill(255,140,0);
      stroke(0);
    }
    else{
      stroke(255,255,0);
      strokeWeight(3);
    if (this.cor == 0) {
      fill(0, 0, 255);
     
    }
    }
   
    
    ellipse(this.pos.x, this.pos.y, 40, 40);
    if (!enemy)
    {
      float endX = this.pos.x + 30 * cos(angle); // 30 é o comprimento da linha
      float endY = this.pos.y + 30 * sin(angle);
      line(this.pos.x, this.pos.y, endX, endY);
    }
    
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(this.username, pos.x, pos.y);
    
  }
  }


  
}
