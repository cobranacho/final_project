class Boundary {

  float x, y, w, h, tallness;
  color c;
  Body boundaryBody;

  Boundary(float x_,float y_, float w_, float h_, float tallness_, color c_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    c = c_;
    tallness = tallness_;

    PolygonShape ps = new PolygonShape();
    
    float box2dW = box2d.scalarPixelsToWorld(w / 2);
    float box2dH = box2d.scalarPixelsToWorld(h / 2);

    ps.setAsBox(box2dW, box2dH);

    // define the body
    BodyDef bodydefinition = new BodyDef();
    bodydefinition.type = BodyType.STATIC;
    bodydefinition.position.set(box2d.coordPixelsToWorld(x, y));
    boundaryBody = box2d.createBody(bodydefinition);
    
    // Attached the shape to the body
    boundaryBody.createFixture(ps, 1);
  }

  void display() {
    
  }

}