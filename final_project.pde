
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
PShader texlightShader;

// A reference to our box2d world
Box2DProcessing box2d;
int horizontalAccel = 0;

ArrayList<Boundary> boundaries;
ArrayList<Boundary> removalList;
ArrayList<Label> labels;

PShape land;
PImage texture;

Table buildingTable;

Posts posts;
Post currentDisplay;
String newsTitle, newsEntity;
int newsShares, tickerX, entityTransparency;
color newsColor;
PGraphics newsCanvas, entityCanvas;
boolean displayingNews;

int fakeHoax, realTruth;
float tiltAngle;

ArrayList<String> newsPersons;
ArrayList<String> newsOrgs;  
ArrayList<String> newsLocales;

void getPosts() {
  posts.queryData();
}

void setup() {
  size(1600, 1000, P3D);

  // load the top shared news from social media with the tag climate change
  posts  = new Posts();
  // thread("getPosts");

  newsCanvas = createGraphics(int(width * 0.75), int(height * 0.1), P2D); 
  entityCanvas = createGraphics(int(width * 0.25), int(height * 0.1), P2D);
  tickerX = newsCanvas.width + 10;
  newsEntity = "Please wait";
  newsTitle = "Loading the most shared stories on climate change ...";

  texlightShader = loadShader("texlightfrag.glsl", "texlightvert.glsl");

  camera = new PeasyCam(this, 0, height / 2 - 30, 0, 1600);
  smooth();
  // fullScreen(P3D);

  // Setup buildings and boundaries
  boundaries = new ArrayList<Boundary>();
  removalList = new ArrayList<Boundary>();
  labels = new ArrayList<Label>();

  // Initialize box2d physics
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // set the gravity
  box2d.setGravity(0, -9.8);

  // load the land obj
  land = loadShape("land.obj");

  // add the boundaries;
  buildingTable = loadTable("bins.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("h");
    x = x + w / 2;
    //y = y - h / 2;
    float angle = row.getFloat("angle");
    boundaries.add(new Boundary(x, y, w, h, radians(angle), 50, true, true));
  }
  
  buildingTable = loadTable("borders.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w") * 2;
    float h = row.getFloat("h") * 2;
    float angle = row.getFloat("angle");
    boundaries.add(new Boundary(x, y, w, h, radians(angle), 50, true, true));
  }

  buildingTable = loadTable("buildings.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("h");
    float angle = row.getFloat("angle");
    int tall = int(w * h / random(3, 6));

    boundaries.add(new Boundary(x, y, w, h, radians(angle), tall, true, false));
  }
}

void drawBins() {
}

void draw() {

  //  shader(texlightShader);


  if (random(0, 1) < 0.05) {
    Label lbl = new Label(int(random(-90, 150)), 30, 50, 40, newsColor, newsTitle);
    labels.add(lbl);
  }


  println("Truth: " + realTruth, "Fake: " + fakeHoax);


  colorMode(RGB);
  background(20, 19, 182);

  if (posts.dataLoaded == true && displayingNews == false ) {
    updateNews();
    updateEntity();
    displayingNews = true;
  } else if (posts.dataLoaded == false && tickerX == newsCanvas.width + 10) {
    tickerX = newsCanvas.width + 3;
    displayingNews = false;
  }

  drawNews();

  camera.beginHUD();
  image(newsCanvas, width - newsCanvas.width, 0);
  image(entityCanvas, 0, 0);
  camera.endHUD();

  // forward box2d time
  box2d.step();

  // draw the elements
  pushMatrix();
  rotateY(radians(tiltAngle));
  pushMatrix();
  translate(-300, 0, -5);
  rotateX(-PI / 2);
  shape(land, 0, 0);
  popMatrix();

  pushMatrix();
  translate(-300, 0, 0);

  for (int i = 0; i < boundaries.size(); i++) {
    boundaries.get(i).display();
  }

  popMatrix();

  // display news labels
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

  popMatrix();

  // remove the label if position if beyond play area
  for (int i = labels.size() - 1; i >= 0; i--) {
    Label tmp = labels.get(i);
    if (tmp.done()) {
      labels.remove(i);
    }
  }
}


Extrusion getExtrusion(Path path, Contour contour, ContourScale contourScale) {
  return new Extrusion(this, path, 1, contour, contourScale);
}

void changeDirection(float x) {
  // set the gravity
  box2d.setGravity(x, -9.8);
}

void addHoax() {
  fakeHoax++;
}

void addTruth() {
  realTruth++;
}

void updateNews() {
  currentDisplay = posts.thePosts.get( int(random(0, posts.thePosts.size())));
  newsPersons = currentDisplay.getPersons();
  newsOrgs = currentDisplay.getOrganizations();  
  newsLocales = currentDisplay.getLocations();
  newsTitle = currentDisplay.title;
  newsShares = currentDisplay.shares;
  colorMode(HSB);
  newsColor = color(random(0, 255), random(200, 255), random(200, 255));



  int labelCounts = int(ceil(newsShares / 100.0));
  for (int i = 0; i < labelCounts; i++) {
    Label lbl = new Label(int(random(-90, 150)), 30, 50, 40, newsColor, newsTitle);
    labels.add(lbl);
  }
  tickerX = newsCanvas.width + 3;
}

void updateTickerPos() {
  tickerX -= width / 400;
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

  if (newsEntity == "Please wait") {
    newsEntity = "Updating...";
  }
}


void drawNews() {

  // draw the entity display
  if (displayingNews == true && frameCount % 120 == 0) {
    updateEntity();
  }

  entityTransparency += 5;  
  entityTransparency = constrain(entityTransparency, 0, 255);

  entityCanvas.beginDraw();
  entityCanvas.colorMode(RGB);
  entityCanvas.background(0);
  int charCounts = newsEntity.length();
  entityCanvas.textSize(constrain(int(entityCanvas.width / charCounts), 36, 48));
  entityCanvas.fill(244, entityTransparency);
  entityCanvas.textAlign(CENTER, CENTER);
  entityCanvas.text(newsEntity, entityCanvas.width / 2, entityCanvas.height / 2);
  entityCanvas.endDraw();

  // draw the news ticker
  newsCanvas.beginDraw();
  newsCanvas.colorMode(HSB);
  newsCanvas.background(0);
  newsCanvas.textSize(newsCanvas.height / 5);
  newsCanvas.fill(newsColor);
  if (newsShares > 0) {
    newsCanvas.text(newsShares + " Shares", newsCanvas.width - 145, 32);
  }
  newsCanvas.textSize(newsCanvas.height / 3.5);
  newsCanvas.fill(255);

  newsCanvas.text(newsTitle, tickerX, newsCanvas.height / 1.3);
  newsCanvas.endDraw();

  updateTickerPos();

  if ((tickerX + textWidth(newsTitle) * 2) < 0 && displayingNews == true) {
    updateNews();
  } else if (tickerX + textWidth(newsTitle) * 2.3 < 0) {
    tickerX = newsCanvas.width + 3;
  }
}


PImage createTexture(color c, int tallness) {
  PImage img = createImage(1, tallness, RGB);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(c);
  }
  img.updatePixels();
  return img;
}


PImage createTexture(Boundary b) {
  PImage img = createImage(1, b.tallness, RGB);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(230);
  }
  img.updatePixels();
  return img;
}


PImage createTexture(int r, int g, Boundary b) {
  PImage img = createImage(1, b.tallness, RGB);
  img.loadPixels();

  for (int i = img.pixels.length - 1; i >= 0; i--) {
    if (r + g == b.tallness) {
      if (r > g) {
        img.pixels[i] = color(244, 0, 0);
        b.filled = 1;
      } else {
        img.pixels[i] = color(0, 244, 0);
        b.filled = 2;
      }
    } else {
      if (r > 0) {
        img.pixels[i] = color(244, 0, 0);
        r--;
      }

      if (r == 0 && g > 0) {
        img.pixels[i] = color(0, 244, 0);
        g--;
      }

      if (r == 0 && g == 0) {
        img.pixels[i] = color(230, 230, 230);
      }
    }
  }
  img.updatePixels();
  return img;
}




void keyPressed() {
  println(tiltAngle);

  if (key == CODED) {
    if (keyCode == RIGHT) {
      println("RIGHT");
      tiltAngle += 2;
      tiltAngle = constrain(tiltAngle, -10, 10);
      box2d.setGravity(tiltAngle / 2, -9.8);
    }
    if (keyCode == LEFT) {
      println("LEFT");
      tiltAngle -= 2;
      tiltAngle = constrain(tiltAngle, -10, 10);
      box2d.setGravity(tiltAngle / 2, -9.8);
    }
  } else {
    println("CENTERING");
    if (tiltAngle > 0) {
      tiltAngle -= 0.2;
    } else if (tiltAngle < 0) {
      tiltAngle += 0.2;
    }
  }

  if (key == 'f') {
    fakeHoax++;
    graphBuildings();
  }

  if (key == 'r') {
    realTruth++;
    graphBuildings();
  }
}


void graphBuildings() {
  for (Boundary b : boundaries) {
    if (b.filled == 0 && b.permenent == false) {
      b.textureImg = createTexture(fakeHoax, realTruth, b);
    }
  }
}