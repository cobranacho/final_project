 //<>// //<>//
// import box2d library
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

// import shapes3d library
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import peasy.*;

PeasyCam camera;

// A reference to our box2d world
Box2DProcessing box2d;

ArrayList<Boundary> boundaries;
ArrayList<Label> labels;

ArrayList<Extrusion> extrusions;
PShape land;
PImage texture;

Extrusion extrudeBuild;

Path path;
Contour contour;
ContourScale contourScale;

Posts posts;
Post currentDisplay;
String newsTitle, newsEntity;
int newsShares, tickerX, entityTransparency;
color newsColor;
PGraphics newsCanvas, entityCanvas;

ArrayList<String> newsPersons;
ArrayList<String> newsOrgs;  
ArrayList<String> newsLocales;

void getPosts() {
  posts.queryData();
}

void setup() {
  size(800, 800, P3D);


  // load the land obj
  land = loadShape("land.obj");

  // load the top shared news from social media with the tag climate change
  posts  = new Posts();
  thread("getPosts");

  newsCanvas = createGraphics(int(width * 0.7), int(height * 0.1), P2D); 
  entityCanvas = createGraphics(int(width * 0.3), int(height * 0.1), P2D);

  camera = new PeasyCam(this, 1200);
  smooth();
  // fullScreen(P3D);

  boundaries = new ArrayList<Boundary>();
  labels = new ArrayList<Label>();
  extrusions = new ArrayList<Extrusion>();

  // Initialize box2d physics
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // set the gravity
  box2d.setGravity(0, -9.8);

  // add the boundaries;
  boundaries.add(new Boundary(width / 3, height - 300, width / 2 - 50, 20, 110, color(random(255), random(255), random(255))));

  boundaries.add(new Boundary( 2 * width / 3, height - 100, width / 2 - 30, 40, 80, color(random(255), random(255), random(255))));

  for (Boundary bound : boundaries) {
    path = new P_LinearPath(new PVector(0, 0, bound.tallness), new PVector(0, 0, 0));
    contour = getBuildingContour(bound);
    contourScale = new CS_ConstantScale();
    contour.make_u_Coordinates();
    extrudeBuild = new Extrusion(this, path, 1, contour, contourScale);
    extrudeBuild.drawMode(S3D.SOLID, S3D.BOTH_CAP);
    extrudeBuild.fill(bound.c);
    extrusions.add(extrudeBuild);
  }
}

void updateNews() {
  currentDisplay = posts.thePosts.get( int(random(0, posts.thePosts.size())));
  newsPersons = currentDisplay.getPersons();
  newsOrgs = currentDisplay.getOrganizations();  
  newsLocales = currentDisplay.getLocations();
  newsTitle = currentDisplay.title;
  newsShares = currentDisplay.shares;
  newsColor = color(map(newsShares, 0, 1000, 0, 255), random(20, 255), random(20, 255));
  tickerX = newsCanvas.width + 3;
}

void updateTickerPos() {
  tickerX -= 2;
}

void updateEntity() {
  entityTransparency = 0;
  switch(int(random(0, 3))) {
  case 0:
    if (newsPersons.size() != 0) {
      newsEntity = newsPersons.get(int(random(0, newsPersons.size())));
    }
    break;
  case 1:
    if (newsOrgs.size() != 0) {
      newsEntity = newsOrgs.get(int(random(0, newsOrgs.size())));
    }
    break;
  case 2:
    if (newsLocales.size() != 0) {
      newsEntity = newsLocales.get(int(random(0, newsLocales.size())));
    }
    break;
  }
  if (newsEntity.length() > 20) {
    updateEntity();
  }
}


void drawNews() {

  // draw the entity display
  if (frameCount % 110 == 0) {
    updateEntity();
  }

  entityTransparency += 5;  
  entityTransparency = constrain(entityTransparency, 0, 255);

  entityCanvas.beginDraw();
  entityCanvas.background(0);
  int charCounts = newsEntity.length();
  entityCanvas.textSize(constrain(int(entityCanvas.width / charCounts), 22, 48));
  entityCanvas.fill(244, entityTransparency);
  entityCanvas.textAlign(CENTER, CENTER);
  entityCanvas.text(newsEntity, entityCanvas.width / 2, entityCanvas.height / 2);
  entityCanvas.endDraw();

  // draw the news ticker
  newsCanvas.beginDraw();
  newsCanvas.background(0);
  newsCanvas.textSize(newsCanvas.height / 6);
  newsCanvas.fill(newsColor);
  if (newsShares > 0) {
    newsCanvas.text(newsShares + " Shares", newsCanvas.width - 80, 20);
  }
  newsCanvas.textSize(newsCanvas.height / 3.5);
  newsCanvas.fill(240);

  newsCanvas.text(newsTitle, tickerX, newsCanvas.height / 1.3);
  newsCanvas.endDraw();

  updateTickerPos();

  if ((tickerX + textWidth(newsTitle) * 2) < 0) {
    updateNews();
  }
}

void draw() {
  
  background(34, 57, 106); //<>//

  if (posts.dataLoaded == true) {
    updateNews();
    updateEntity();
    posts.dataLoaded = false;
  } else {
    newsEntity = "Wait";
    newsTitle = "Loading Data...";
  }
  
  drawNews();

  camera.beginHUD();
  image(newsCanvas, width - newsCanvas.width, 0);
  image(entityCanvas, 0, 0);
  camera.endHUD();


  // forward box2d time
  box2d.step();



  if (random(1) < 0.05) {
    Label lbl = new Label(int(random(20, width - 20)), 30, 50, 40, color(random(255), random(255), random(255)), "Mike");
    labels.add(lbl);
  }



  // draw the land and buildings
  pushMatrix();
  scale(4);
  rotateX(-PI / 2);
  shape(land, 0, 0);
  popMatrix();



  // draw the building
  for (int i = 0; i < boundaries.size(); i++) {
    pushMatrix();
    translate(boundaries.get(i).x + boundaries.get(i).w / 2, boundaries.get(i).y - boundaries.get(i).h / 2);
    extrusions.get(i).draw();
    popMatrix();
  }


  for (Label lbl : labels) {
    Vec2 pos = box2d.getBodyPixelCoord(lbl.body);
    float angle = lbl.body.getAngle();


    pushMatrix();
    rectMode(CENTER);
    translate(pos.x, pos.y, 20);
    rotate(-angle);
    fill(lbl.c);
    stroke(lbl.c);
    rect(0, 0, lbl.w, lbl.h);
    popMatrix();
  }


  pushMatrix();

  //rotateY(PI / 6);
  //rotateX(PI / 4);
  // rotateZ(PI / 4);
  //translate(can, 0 -100);
  // image(canvas, 10, 0);
  popMatrix();

  for (int i = labels.size() - 1; i >= 0; i--) {
    Label tmp = labels.get(i);
    if (tmp.done()) {
      labels.remove(i);
    }
  }
}

Contour getBuildingContour(PVector[] points) {
  return new Building(points);
}


Contour getBuildingContour() {
  // PVector[] c;

  PVector[] c = new PVector[] {
    new PVector(0, 0), 
    new PVector(100, 20), 
    new PVector(120, 50), 
    new PVector(300, 50), 
    new PVector(400, 80), 
    new PVector(400, 180), 
    new PVector(400, 220), 
    new PVector(430, 300), 

    new PVector(600, 700)

  };
  return new Building(c);
}
Contour getBuildingContour(Boundary bound) {
  PVector[] c = new PVector[] {
    new PVector(0, 0), 
    new PVector(bound.w, 0), 
    new PVector(bound.w, bound.h), 
    new PVector(0, bound.h), 
  };
  return new Building(c);
}



PImage createTexture() {
  PImage img = createImage(20, 20, RGB);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(200);
  }
  img.updatePixels();
  return img;
}

PImage createTexture(int r, int g, int b) {
  PImage img = createImage(20, 20, RGB);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(200);
  }
  img.updatePixels();
  return img;
}