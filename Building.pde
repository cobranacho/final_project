class Building {
  int x1, x2, x3, x4;
  int y1, y2, y3, y4;
  
  
  Building(int x1_, int y1_, int x2_, int y2_, int x3_, int y3_, int x4_, int y4_) {
    x1 = x1_;
    y1 = y1_;
    
    x2 = x2_;
    y2 = y2_;
    
    x3 = x3_;
    y3 = y3_;
    
    x4 = x4_;
    y4 = y4_;
    
  }
  
  
  void display() {
    beginShape();
    vertex(x1, y1);
    vertex(x2, y2);
    vertex(x3, y3);
    vertex(x4, y4);
    endShape(CLOSE);  
  }
}