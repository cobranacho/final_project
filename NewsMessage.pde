class NewsMessage {
  
  String message;
  float alpha;
  color c;
  int y, visible;
  int type;
  
  NewsMessage(String message_, int type_) {
    message = message_;
    type = type_;
    alpha = 255;
    y = 280 + int(random(-30, 30));
    visible = 1;
    getColor();
    
    if (message.length() > 48) {
      message = message.substring(0, 47) + " ...";
    }
  }
  
  void updatePos() {
    y = y - 3;
    alpha = alpha - 4;
    alpha = constrain(alpha, 0, 255);
    if (alpha == 0) {
      visible = 0;
    }
  }
  
  void getColor() {
    if (type == 0) {
      c = color(0, 244, 0, alpha);
    } else {
      c = color(244, 0, 0, alpha);
    }
  }
  
  void display() {
    pushMatrix();
    pushStyle();
    textSize(24);
    if ((selector == 0 && type == 1) || (selector == 1 && type == 0)) {
      text(message, 20, y);
      println(message);
    } else if ((selector == 1 && type == 1) || (selector == 0 && type == 0)) {
      text(message, width - 610, y);
      println(message);
    }
    
  popStyle();
  popMatrix();
  
    
  }
}