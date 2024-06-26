class Corpo{
  int cor; 
  PVector pos;
  float tam;
  float ang;
  Corpo(float x1, float y1, float tam, int cor, float ang1){
    this.pos=new PVector(x1,y1);
    this.tam=tam;
    this.cor=cor;
    this.ang=ang1;
  }
  void show(){
    strokeWeight(3);
    if (this.cor == 0) {
      stroke(255, 0, 0);
      fill(255, 0, 0);
     
    } else if (this.cor == 1) {
      stroke(0, 255, 0);
      fill(0, 255, 0);
      
    
    } else if (this.cor == 2) {
      stroke(255, 0, 255);
      fill(255, 0, 255);
    }

    else if (this.cor == 3) {
      stroke(255, 255, 0);
      fill(255, 255, 0);
    }
    
    ellipse(this.pos.x, this.pos.y, tam+40, tam+40);
    fill(0);
  }
  
}
