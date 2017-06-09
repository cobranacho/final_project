//<>// //<>// //<>// //<>// //<>// //<>//
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
int horizontalAccel = 0;

ArrayList<Boundary> boundaries;
ArrayList<Boundary> removalList;
ArrayList<Label> labels;

ArrayList<Building> buildings;
//ArrayList<Extrusion> extrusions;

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
  //  thread("getPosts");

  newsCanvas = createGraphics(int(width * 0.75), int(height * 0.1), P2D); 
  entityCanvas = createGraphics(int(width * 0.25), int(height * 0.1), P2D);
  tickerX = newsCanvas.width + 10;
  newsEntity = "Please wait";
  newsTitle = "Loading the most shared stories on climate change ...";

  camera = new PeasyCam(this, width / 2, height / 2, 0, 1200);
  smooth();
  // fullScreen(P3D);

  // Setup buildings and boundaries
  boundaries = new ArrayList<Boundary>();
  removalList = new ArrayList<Boundary>();
  labels = new ArrayList<Label>();
  buildings = new ArrayList<Building>();
  // extrusions = new ArrayList<Extrusion>();

  buildingTable = loadTable("buildings.csv", "header");
  for (TableRow row : buildingTable.rows()) {
    int x1 = row.getInt("x1");
    int y1 = row.getInt("y1");  
    int x2 = row.getInt("x2");
    int y2 = row.getInt("y2");   
    int x3 = row.getInt("x3");
    int y3 = row.getInt("y3");
    int x4 = row.getInt("x4");
    int y4 = row.getInt("y4");

    Building temp = new Building(x1, y1, x2, y2, x3, y3, x4, y4);
    buildings.add(temp);
  }


  // Initialize box2d physics
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // set the gravity
  box2d.setGravity(0, -9.8);

  // load the land obj
  land = loadShape("land.obj");

  // add the boundaries;
  boundaries.add(new Boundary(550, 450, 150, 20, radians(15), 110, true, false));

  boundaries.add(new Boundary( 400, 250, 260, 30, radians(20), 10, true, true));

  boundaries.add(new Boundary(width / 3, height - 300, width / 2 - 50, 20, radians(-15), 15, true, true));

  boundaries.add(new Boundary( 2 * width / 3, height - 100, width / 2 - 30, 40, radians(20), 30, true, false));
  
//  boundaries.get(2).setColor(color(22, 11, 122));
}

void draw() {

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

  if (random(1) < 0.05) {
    Label lbl = new Label(int(random(20, width - 20)), 30, 50, 40, color(random(255), random(255), random(255)), newsTitle);
    labels.add(lbl);
  }

  for (Building b : buildings) {
    b.display();
  }

  // draw the land and buildings
  pushMatrix();
  translate(0, 0, -5);
  rotateX(-PI / 2);
  shape(land, 0, 0);
  popMatrix();



  // draw the remaining building
  //for (int i = 0; i < boundaries.size(); i++) {
  //  println(boundaries.get(i).tallness);
  //  if (boundaries.get(i).tallness == 1) {
  //    removalList.add(boundaries.get(i));
  //  }
  //}

  //for (Boundary removeIt : removalList) {
  ////  boundaries.remove(removeIt);
  //}

  //removalList.clear();

  for (int i = 0; i < boundaries.size(); i++) {
    boundaries.get(i).display();
  }


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

void addFake() {
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

  newsColor = color(random(0, 255), random(200, 255), random(200, 255));
  tickerX = newsCanvas.width + 3;
}

void updateTickerPos() {
  tickerX -= width / 500;
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
  entityCanvas.background(0);
  int charCounts = newsEntity.length();
  entityCanvas.textSize(constrain(int(entityCanvas.width / charCounts), 36, 48));
  entityCanvas.fill(244, entityTransparency);
  entityCanvas.textAlign(CENTER, CENTER);
  entityCanvas.text(newsEntity, entityCanvas.width / 2, entityCanvas.height / 2);
  entityCanvas.endDraw();

  // draw the news ticker
  newsCanvas.beginDraw();
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
  if (key == 'f') {
    fakeHoax++;
    for (Boundary b : boundaries) {
      if (b.filled == 0 && b.permenent == false) {
        b.textureImg = createTexture(fakeHoax, realTruth, b);
      }
    }
  }

  if (key == 'r') {
    realTruth++;
    for (Boundary b : boundaries) {
      if (b.filled == 0 && b.permenent == false) {
        b.textureImg = createTexture(fakeHoax, realTruth, b);
      }
    }
  }
}