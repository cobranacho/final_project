class Boundary {

  float x, y, w, h, angle;
  int tallness, filled;
  PImage textureImg;
  boolean visible, permenent;
  Body boundaryBody;
  Path path;
  Contour contour;
  ContourScale contourScale;
  Extrusion extrudeBoundary;

  PolygonShape ps;
  Fixture fixture;
  // color thisColor;

  Boundary(float x_, float y_, float w_, float h_, float angle_, int tallness_, boolean visible_, boolean permenent_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    angle = angle_;
    tallness = tallness_;
    visible = visible_;
    permenent = permenent_;
    textureImg = createTexture(this);

    ps = new PolygonShape();

    float box2dW = box2d.scalarPixelsToWorld(w / 2);
    float box2dH = box2d.scalarPixelsToWorld(h / 2);
    
    ps.setAsBox(box2dW, box2dH);

    // define the body
    BodyDef bodydefinition = new BodyDef();
    bodydefinition.type = BodyType.STATIC;
    bodydefinition.angle = angle;
    bodydefinition.position.set(box2d.coordPixelsToWorld(x - 300, y));
    boundaryBody = box2d.createBody(bodydefinition);

    // Attached the shape to the body
    boundaryBody.createFixture(ps, 1);

    // keep a fixture
    fixture = boundaryBody.getFixtureList();

    // create the extrusion
    path = new P_LinearPath(new PVector(0, 0, tallness), new PVector(0, 0, 0));

    PVector[] ct = new PVector[] {
      new PVector(0, 0), 
      new PVector(w, 0), 
      new PVector(w, h), 
      new PVector(0, h), 
    };

    contour = new BuildContour(ct);
    contourScale = new CS_ConstantScale();
    contour.make_u_Coordinates();
    extrudeBoundary = getExtrusion(path, contour, contourScale);
    extrudeBoundary.drawMode(S3D.SOLID, S3D.BOTH_CAP);

    extrudeBoundary.setTexture(textureImg, (w + h) * 2, 1);
    extrudeBoundary.drawMode(S3D.TEXTURE);
  }

  void reduceHeight() {
    path = new P_LinearPath(new PVector(0, 0, tallness), new PVector(0, 0, 0));
    extrudeBoundary = getExtrusion(path, contour, contourScale);
    extrudeBoundary.drawMode(S3D.SOLID, S3D.BOTH_CAP);
    extrudeBoundary.setTexture(textureImg, S3D.S_CAP);
    extrudeBoundary.drawMode(S3D.TEXTURE, S3D.S_CAP);
    extrudeBoundary.setTexture(textureImg, (w + h) * 2, 1);
    extrudeBoundary.drawMode(S3D.TEXTURE);
  }

  void setColor(color c) {
    textureImg = createTexture(c, tallness);
    extrudeBoundary.drawMode(S3D.SOLID, S3D.BOTH_CAP);
    extrudeBoundary.setTexture(textureImg, S3D.S_CAP);
    extrudeBoundary.drawMode(S3D.TEXTURE, S3D.S_CAP);
    extrudeBoundary.setTexture(textureImg, (w + h) * 2, 1);
    extrudeBoundary.drawMode(S3D.TEXTURE);
  }
  
  void display() {

    if (tallness == 1) {
      boundaryBody.destroyFixture(fixture);
      tallness = 0;
      visible = false;
    }

    if (filled == 1 && tallness > 1) {
      tallness--;
      reduceHeight();
    }

 
    if (visible == true) {
      pushMatrix();
      translate(x, y);
      rotate(-angle);
      translate(w / 2, -h / 2);
      pushMatrix();
 
      extrudeBoundary.setTexture(textureImg, (w + h) * 2, 1);
      extrudeBoundary.draw();

      if (filled != 0) {
        extrudeBoundary.setTexture(textureImg, S3D.S_CAP);
        extrudeBoundary.drawMode(S3D.TEXTURE, S3D.S_CAP);
      }
      popMatrix();
      popMatrix();
    }
  }
}