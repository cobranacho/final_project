
class Label {

  Body body;
  float x, y, w, h;
  color c;
  boolean voted;
  String text;

  Label(float x_, float y_, float w_, float h_, color c_, String text_) {
    x = x_;
    y = y_;
    w = 10;
    h = 6;
    c = c_;
    text = text_;

    // Add the box to the box2d world
    makeBody(new Vec2(x, y), w, h);
  }

  void killBody() {
    if (!voted) {
      Vec2 pos = box2d.getBodyPixelCoord(body);
 
      if (pos.x < 0 && pos.x > -250) {
        if (selector == 1) {
          addTruth(text);
        } else {
          addHoax(text);
        }
      } else if (pos.x > 0 && pos.x < 250) {
        if (selector == 0) {
          addTruth(text);
        } else {
          addHoax(text);
        }
      }
      graphBuildings();
    }
    box2d.destroyBody(body);
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // kill this it is beyond the screen view
    if (pos.y > height + w * h || pos.x > 300 + w * h || pos.x < -300 - w * h) {
      killBody();
      return true;
    }
    return false;
  }


  void display() {
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    body.setAngularVelocity(random(-5, 5));
  }
}