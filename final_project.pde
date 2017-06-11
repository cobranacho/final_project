/* //<>//
 Project: Final Project 
 Student: James Hu
 Pasadena City College, Spring 2017
 Prof. Masood Kamandy
 Project Description: The program grabs the most shared social media stories and metaphorically 
 illustrates the difficulty of ascertain both source and authenticity, and the effect of sea level rise
 Last Modified: June 10, 2017
 
 Controls: 1, 2, 3, 4, 5 - change view angle
           left, right - tilt the land 
           r - add real news
           f - add fake news
 */

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
import ddf.minim.*;

Minim minim;
AudioPlayer ding, collapse;

PeasyCam camera;
PShader texlightShader;

// A reference to our box2d world
Box2DProcessing box2d;

ArrayList<Boundary> boundaries;
ArrayList<Boundary> removalList;
ArrayList<Label> labels;
ArrayList<NewsMessage> newsMessages;
ArrayList<NewsMessage> removeM;

PShape land;
PImage texture;
float alphaStep, landAlpha = 255;
color landColor = color(160, 160, 160, landAlpha);
color oceanColor = color(92, 162, 198);


Table buildingTable;

Posts posts;
Post currentDisplay;
String newsTitle, newsEntity, newsLabel1, newsLabel2;
int newsShares, tickerX, entityTransparency, randomSelect, selector, counter, numBuildings;
color newsColor;
PGraphics newsCanvas, entityCanvas;
boolean displayingNews;

int fakeHoax, realTruth;
float tiltAngle, centering;

ArrayList<String> newsPersons;
ArrayList<String> newsOrgs;  
ArrayList<String> newsLocales;


int generateSeed() {
  return int(random(120, 480));
}
void getPosts() {
  posts.queryData();
}

void setup() {
  // size(800, 1000, P3D);
  noCursor();

  minim = new Minim(this);
  ding = minim.loadFile("ding.mp3");
  ding.setVolume(0.2);
  collapse = minim.loadFile("collapse.mp3");
  collapse.setVolume(0.5);

  // load the top shared news from social media with the tag climate change
  posts  = new Posts();
  thread("getPosts");

  newsCanvas = createGraphics(int(width * 0.75), int(height * 0.1), P2D); 
  entityCanvas = createGraphics(int(width * 0.25), int(height * 0.1), P2D);
  tickerX = newsCanvas.width + 10;
  newsEntity = "Please wait";
  newsTitle = "Loading the most shared stories on climate change ...";
  texlightShader = loadShader("texlightfrag.glsl", "texlightvert.glsl");
  newsLabel1 = "Fake Hoax";
  newsLabel2 = "Real Truth";
  randomSelect = generateSeed();

  camera = new PeasyCam(this, 0, height / 2 - 50, 0, 1200);
  camera.setActive(false);

  smooth();
  fullScreen(P3D);

  // Setup buildings and boundaries
  boundaries = new ArrayList<Boundary>();
  removalList = new ArrayList<Boundary>();
  labels = new ArrayList<Label>();
  newsMessages = new ArrayList<NewsMessage>();
  removeM = new ArrayList<NewsMessage>();

  // Initialize box2d physics
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // set the gravity
  box2d.setGravity(0, -9.8);

  // load the land obj
  land = loadShape("land.obj");
  land.setFill(landColor);

  // add the boundaries;
  buildingTable = loadTable("bins.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("h");
    x = x + w / 2;
    float angle = row.getFloat("angle");
    boundaries.add(new Boundary(x, y, w, h, radians(angle), 50, true, true));
  }

  buildingTable = loadTable("borders.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("h");
    x = x + w / 2;
    y = y + h / 2;
    float angle = row.getFloat("angle");
    boundaries.add(new Boundary(x, y, w, h, radians(angle), 50, false, true));
  }

  buildingTable = loadTable("buildings.csv", "header");

  for (TableRow row : buildingTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("h");
    float angle = row.getFloat("angle");
    int tall = int(w * h / random(4.5, 6.5));

    boundaries.add(new Boundary(x, y, w, h, radians(angle), tall, true, false));
  }

  numBuildings = boundaries.size();
  alphaStep = 255.0 / numBuildings;
}

void draw() {

  //  shader(texlightShader);

  colorMode(RGB); 
  background(oceanColor);

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

  for (int i = 0; i < newsMessages.size(); i++) {
    float cc = newsMessages.get(i).alpha;
    if (newsMessages.get(i).type == 0) {
      fill(0, 244, 0, cc);
    } else {
      fill(244, 0, 0, cc);
    }
    newsMessages.get(i).display();
    newsMessages.get(i).updatePos();
  }

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

  if (counter >= randomSelect) {
    randomSelect = generateSeed();
    counter = 0;
  }

  selector = randomSelect % 2;
  drawNewsLabels(selector);

  popMatrix();

  // find and remove old messages
  if (newsMessages.size() > 0) {
    for (NewsMessage n : newsMessages) {
      if (n.visible == 0) {
        removeM.add(n);
      }
    }
  }
  for (NewsMessage m : removeM) {
    newsMessages.remove(m);
  } 

  // remove the label if position if beyond play area
  for (int i = labels.size() - 1; i >= 0; i--) {
    Label tmp = labels.get(i);
    if (tmp.done()) {
      labels.remove(i);
    }
  }
  counter++;

  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == RIGHT) {
        tiltAngle += 0.2;
        tiltAngle = constrain(tiltAngle, -15, 15);
        box2d.setGravity(tiltAngle / 1.5, -9.8);
      }
      if (keyCode == LEFT) {

        tiltAngle -= 0.2;
        tiltAngle = constrain(tiltAngle, -10, 10);
        box2d.setGravity(tiltAngle / 1.5, -9.8);
      }
    }
  }

  if (tiltAngle > 0) {
    centering = -0.1;
  } 
  if (tiltAngle < 0) {
    centering = 0.1;
  }

  if (centering != 0) {
    tiltAngle += centering;
    box2d.setGravity(tiltAngle / 1.5, -9.8);
  }
}

void drawNewsLabels(int select) {
  int x1, x2;

  if (select == 0) {
    x1 = 150;
    x2 = 450;
  } else {
    x1 = 450;
    x2 = 150;
  }

  int y = 1080;
  pushMatrix();
  translate(-300, 0);
  pushStyle();
  textSize(36);
  colorMode(RGB);
  rectMode(CENTER);
  fill(244, 0, 0);
  stroke(200, 0, 0);
  rect(x1, y, 200, 50);
  fill(255);
  textAlign(CENTER, CENTER);
  text(newsLabel1, x1, y - 6, 2);
  popStyle();

  pushStyle();
  textSize(36);
  colorMode(RGB);
  rectMode(CENTER);
  fill(0, 244, 0);
  stroke(0, 200, 0);
  rect(x2, y, 200, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  text(newsLabel2, x2, y - 6, 2);
  popStyle();
  popMatrix();
}

void reduceColor() {
  landAlpha -= alphaStep * 1.1;
  landColor = color(160, 160, 160, landAlpha);
  land.setFill(landColor);
}

Extrusion getExtrusion(Path path, Contour contour, ContourScale contourScale) {
  return new Extrusion(this, path, 1, contour, contourScale);
}

void playDing() {
  if (!ding.isPlaying()) {
    if (ding.position() == ding.length()) {
      ding.rewind();
      ding.play();
    } else {      
      ding.rewind();
      ding.play();
    }
  }
}


void playCollapse() {
  if (!collapse.isPlaying()) {
    if (collapse.position() == collapse.length()) {
      collapse.rewind();
      collapse.play();
    } else {      
      collapse.rewind();
      collapse.play();
    }
  }
}
void changeDirection(float x) {
  // set the gravity
  box2d.setGravity(x, -9.8);
}

void addHoax(String hoax) {
  fakeHoax++;
  newsMessages.add(new NewsMessage("+Hoax: " + hoax, 1));
  playDing();
}

void addTruth(String truth) {
  realTruth++;
  newsMessages.add(new NewsMessage("+Truth: " + truth, 0));
  playDing();
}

void updateNews() {
  currentDisplay = posts.thePosts.get( int(random(0, posts.thePosts.size())));
  newsPersons = currentDisplay.getPersons();
  newsOrgs = currentDisplay.getOrganizations();  
  newsLocales = currentDisplay.getLocations();
  newsTitle = currentDisplay.title;
  newsShares = currentDisplay.shares;
  colorMode(HSB);
  newsColor = color(random(0, 255), random(200, 255), random(200, 255), 255);

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

  if (key == '6') {
    camera.setRotations(0.5, 0, -PI);
    camera.setDistance(1000);
    camera.lookAt(0, height / 2 - 30, 0);
  }
  if (key == '5') {
    camera.setRotations(PI / 2, -PI / 2, PI);
    camera.setDistance(1000);
    camera.lookAt(0, height / 2, 100);
  }

  if (key == '4') {
    camera.setRotations(-PI / 2, PI / 2, 0);
    camera.setDistance(1000);
    camera.lookAt(0, height / 2, 100);
  }

  if (key == '3') {
    camera.setRotations(-0.732, 0.716, -0.618);
    camera.setDistance(1100);
    camera.lookAt(0, height / 2, 0);
  }

  if (key == '2') {
    camera.setRotations(-0.732, -0.716, 0.618);
    camera.setDistance(1100);
    camera.lookAt(0, height / 2, 0);
  }

  if (key == '1') {
    camera.reset();
  }

  if (key == 'f') {
    fakeHoax++;
    graphBuildings();
  }

  if (key == 'r') {
    realTruth++;
    graphBuildings();
  }

  if (key == 's') {
    Label lbl = new Label(int(random(-90, 150)), 30, 50, 40, newsColor, newsTitle);
    labels.add(lbl);
  }
}

void mouseReleased() {
  //float[] pos = camera.getPosition();
  //float[] rot = camera.getRotations();
  //float[] lat = camera.getLookAt();
  //println("position:", pos[0], pos[1], pos[2]);
  //println("rotation:", rot[0], rot[1], rot[2]); 
  //println("looking at:", lat[0], lat[1], lat[2]);
  //println("distance:", camera.getDistance());
}

void graphBuildings() {
  for (Boundary b : boundaries) {
    if (b.filled == 0 && b.permenent == false) {
      b.textureImg = createTexture(fakeHoax, realTruth, b);
    }
  }
}