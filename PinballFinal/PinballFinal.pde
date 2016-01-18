

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.Manifold;
import org.jbox2d.common.*;
import org.jbox2d.callbacks.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.dynamics.contacts.*;
import beads.*;


/**
*  This class uses the following classes:
*    1. Ball
*    2. Bumper
*    3. Flipper
*    4. Plunger
*    5. Wall
*  in order to make the basic functionality of a Pinball Machine.
*  This pinball machine has an intragalactic theme with my our cool
*  twist. It includes a Black Hole that you have to avoid, randomly 
*  generated bumper locations, and a moving wraping backgroung picture.
*
*   Requires the following libraries:
*     1. Box2D For Processing
*     2. Beads
*   
*   @author Pranav Madanahalli
*   @version May 29, 2015
*
*/

//Photos for all the planets and the background
PImage photo;
PImage jup;
PImage ven;
PImage merc;
PImage mars;
PImage sat;
PImage uran;
PImage nep;
PImage ear;


// Audio contexts
AudioContext ac;
SamplePlayer dingSound;
Gain gain;
Glide gainValue;

//Flipper objects
Flipper flipperL;
Flipper flipperR;

//Box2D world
Box2DProcessing box2d;

//Ball Object
Ball ball;

//ArrayList of Wall Objects
ArrayList<Wall> wallList;

//Array of the x and y positions of the images
int[] imagePos = new int[16];

//Plunger Object
Plunger plunger;


//ArrayList of Bumper Objects
ArrayList<Bumper> bumperList;

//Player's Score
int playerScore;

//Number of Balls in the Game - 1
// actual Ballcount = 4
int ballCount = 5;

//true -> game is over
//false -> game is still going
boolean lostGame;

//Y position of Background Photo
// Used for the wraping photo effect
int yPos;

//BlackHole Y position
int blackholey;
//BlackHole X position
int blackholex;

void setup()
{
  //Setting all the planets image positions
  imagePos[0] = 230;
  imagePos[1] = 200;
  imagePos[2] = 100;
  imagePos[3] = 450;
  imagePos[4] = 400;
  imagePos[5] = 450;
  imagePos[6] = 253;
  imagePos[7] = 445;
  imagePos[8] = 355;
  imagePos[9] = 300;
  imagePos[10] = 50;
  imagePos[11] = 100;
  imagePos[12] = 425;
  imagePos[13] = 125;
  imagePos[14] = 100;
  imagePos[15] = 320;
  
  //setting spawn point for black hole
  blackholey = blackholex = 350;
  
  //background image
  photo = loadImage("galax.jpg");
  
  //Jupiter
  jup = loadImage("jup.png");
  jup.resize(0, 80);
  
  //Venus
  ven = loadImage("ven.png");
  ven.resize(0, 30);
  
  //Mercury
  merc = loadImage("merc.png");
  merc.resize(0, 30);
  
  //Mars
  mars = loadImage("mars.png");
  mars.resize(0, 40);
  
  //Saturn
  sat = loadImage("sat.png");
  sat.resize(0, 80);
  
  //Neptune
  nep = loadImage("nep.png");
  nep.resize(0, 80);
  
  //Uranus
  uran = loadImage("uran.png");
  uran.resize(0, 80);
  
  //Earth
  ear = loadImage("ear.png");
  ear.resize(0, 60);
  
  //setting frame width and height
  size(600, 700, P2D);
  smooth();

  // Init box2d world
  box2d = new Box2DProcessing (this);
  box2d.createWorld();

  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Start listening for collisions
  box2d.listenForCollisions();

  // Instantiate the new audio context
  ac = new AudioContext();

  // Attempt to load the ding sound
  // If it doesn't load exit the program
  try
  {
    dingSound = new SamplePlayer(ac, new Sample(sketchPath("") + "buzzer.wav"));
  }
  catch(Exception ex)
  {
    ex.printStackTrace();
    exit();
  }

  // The sound is used more than once
  dingSound.setKillOnEnd(false);

  // Create a gain for volume control
  gainValue = new Glide(ac, 0.0, 20);
  gain = new Gain(ac, 1, gainValue);

  // Set gain to allow dingSound for input
  gain.addInput(dingSound);

  // Set gain to be an audio output
  ac.out.addInput(gain);

  // Start the AudioContext
  ac.start();
  
  //Creates a Ball object
  ball = new Ball(17.0f, new Vec2(550, 100));
  ball.fillColor = color(0, 255,255); //cyan color
  
  wallList = new ArrayList<Wall>();  

  plunger = new Plunger(new Vec2( 550, 650));

  bumperList = new ArrayList<Bumper>();

  //adds the walls, bumpers, and flippers on the program
  addWalls();
  addBumpers();
  addFlippers();
}

void draw()
{
  //displays background scheme
  wrapBackground();
  
  //listens for user input
  userInput();

  if (!lostGame)
  {
    //renders the different objects that are apart of this game
    drawGame();
    //draws the images of planets on screen
    drawImages();
    // Set fill to black and draw score
    fill(0);
    textSize(20);
    text("Score: " + playerScore, 20, 670);
    text("Balls Left: " + ballCount, 19, 694);
    
    fill(0);
    textSize(32);
    text("Endurance", width/2-80, 27);
    
    
    fill(0);
    textSize(18);
    text("SpaceBar:",395 , 615);
    text("Plunger", 450, 635);
    text("z: Left Flipper", 390, 655);
    text("/: Right Flipper",390, 675);
    text("r: Random", 390, 695);
    
    //makes the Blackhole
    //controls the movement
    //checks with collision with ball
    blackHoleLogic();
    
  } 
  if(lostGame){
    
    // Set fill to black and draw score
    fill(255);
    textSize(32);
    text("Score: " + playerScore, width/2-70, height/2);
    text("Game Over: Press Spacebar to Restart", width/2-293, height/2 +30);
  }
}
/**
 *  Wraps the background image continously
 */
void wrapBackground(){
  image(photo, 0, yPos);
  yPos-=4;
  int imageOff = 500;
  if(yPos*-1> imageOff){
    image(photo,0, 700 - (yPos*-1 -imageOff));
  }
  if(yPos ==-1200){
    yPos = 0;
  }
}
/**
 *  Draws the planet images withthe imagePos array data
 */
void drawImages(){
  image(jup, imagePos[0], imagePos[1]);//jupiter
  image(ven, imagePos[2], imagePos[3]); //venus
  image(merc, imagePos[4], imagePos[5]); //mercury
  image(mars, imagePos[6], imagePos[7]); //mars
  image(sat, imagePos[8], imagePos[9]); // saturn
  image(nep, imagePos[10], imagePos[11]); //neptune
  image(uran, imagePos[12], imagePos[13]); // uranus
  image(ear, imagePos[14], imagePos[15]); // earth
}
/**
 *  Black Hole Logic
 *  1. Draws the Black hole
 *  2. Controls Random Movement
 *  3. Checks collision with Ball
 */
void blackHoleLogic(){
  fill(255);
  ellipse(blackholex, blackholey, 50, 30);
  fill(0);
  ellipse(blackholex, blackholey, 45, 25 );
  int temp1 = blackholex;
  int temp2 = blackholey;
  int ran = (int)(Math.random()*4) +1;
  if(blackHoleCheck()){
    //switch to determine random movement
    switch(ran){
      case 1: 
      blackholex+=5;
      blackholey+=5;
      if(!blackHoleCheck()){
        blackholey -=5;
        blackholex -=5;
      }
      break;
      case 2:
      blackholex+=5; 
      blackholey-=5;
     if(!blackHoleCheck()){
        blackholey +=5;
        blackholex -=5;
      }
      break;
      case 3: 
      blackholex-=5;
      blackholey+=5; 
      if(!blackHoleCheck()){
        blackholey -=5;
        blackholex +=5;
      }
      break;
      case 4: 
      blackholex-=5;
      blackholey-=5; 
      if(!blackHoleCheck()){
        blackholey +=5;
        blackholex +=5;
      }
      break;
    }
  }
  else{
    blackholey = temp2;
    blackholex = temp1;
    
  }
  //Checks for collision with Ball
  Vec2 pos = ball.getPosition();
  int a = blackholex +50;
  int b = blackholey +30;
  if(pos.x > blackholex && pos.x < a && pos.y > blackholey && pos.y <b){
    if(ballCount > 0){
      ball.remove();
      ball = new Ball(17.0f, new Vec2(550, 100));
      ball.fillColor = color(255, 0,0);
    }
  }
}
/**
 *  Checks the x and y coordinates of the BlackHole
 *  @return true if the coordinates stay within parameters, false if not.
 */
boolean blackHoleCheck(){
  return blackholey < height-100 && blackholex < width-100 && blackholex > 50 && blackholey > 50;
}
/**
 *  Renders the Ball, Walls, Bumpers, Flippers, and Plunger 
 */
void drawGame(){
  // Update physics world
  box2d.step();
  ball.render();
  
  //if ball is off screen
  if (ball.offScreen()){
    if ( ballCount > 0){
      ball.remove();
      ball = new Ball(17.0f, new Vec2(550, 100));
      ball.fillColor = color(0, 255,255);
    } 
    else{
      lostGame = true;
    }
  }
  
  //renders walls
  for (Wall w : wallList)
  {
    w.render();
  }
  
  //renders bumpers
  for (Bumper b : bumperList)
  {
    b.render();
  }
  
  //renders plunger
  plunger.render();
  
  //renders Flippers
  flipperL.render();
  flipperR.render();
}
/**
 *  Detect collisions for objects
 *  @param 
 */
void beginContact(Contact c)
{
  // Get the colliding fixtures
  Fixture f1 = c.getFixtureA();
  Fixture f2 = c.getFixtureB();

  // Get the bodies of each fixture
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get the objects that the bodies are from
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  // If either object is null return
  if (o1 == null || o2 == null)
  {
    return;
  }

  // Get Contact Manifold (for normal)
  Manifold m = c.getManifold();

  if (o1 instanceof Bumper && o2 instanceof Ball) 
  {
    Bumper bumper = (Bumper)o1;
    Ball ball = (Ball)o2;

    bumper.collide(ball, m.localNormal);
  } else if (o1 instanceof Ball && o2 instanceof Bumper) 
  {
    Bumper bumper = (Bumper)o2;
    Ball ball = (Ball)o1;

    bumper.collide(ball, m.localNormal);
  }
}

/**
 *  Listens for User inputs and acts accordingly
 */
void userInput(){
  // Check if plunger button on gamepad is pressed
  // or if the spacebar is pressed
  if ((keyPressed && key == ' ' )) {
    if (!lostGame) {
      // If the player is still in game pull the plunger
      plunger.pullPlunger();
    }
    else{
      // If the player has lost the game restart it
      
      lostGame = false;
      ballCount = 5;
      playerScore = 0;
      
      
    }
  }

  // If the left bumper has been pressed (or the Z key) activate the left flipper
  if ((keyPressed && (key == 'z' || key == 'Z'))){
    
      flipperL.flip(1000000, true);
  }

  // If the right bumper has been pressed (or the (/-?) key) activate the right flipper
  if ((keyPressed && (key == '/' || key == '?'))){
   
      flipperR.flip(1000000, false);
   
  }
  //if the key r is pressed then it randomizes the location of the bumpers on the map
  if (keyPressed && (key == 'r')){
    //parse through the bumperList
    for(int i = 0; i < bumperList.size(); i++){
      bumperList.get(i).randomize();
      //These series of if statements changes the image 
      // position when the bumper location changes
      
      //neptune
      if(i== 0){
        imagePos[10] = bumperList.get(i).getRanX()-40;
        imagePos[11] = bumperList.get(i).getRanY()-40;
      }
      //jupiter
      if(i ==1){
        imagePos[0] = bumperList.get(i).getRanX()-39;
        imagePos[1] = bumperList.get(i).getRanY()-40;
      }
      //uranus
      if(i ==2){
        imagePos[12] = bumperList.get(i).getRanX()-40;
        imagePos[13] = bumperList.get(i).getRanY()-40;
      }
      //saturn
      if(i ==3){
        imagePos[8] = bumperList.get(i).getRanX()-40;
        imagePos[9] = bumperList.get(i).getRanY()-40;
      }
      //earth
      if(i ==4){
        imagePos[14] = bumperList.get(i).getRanX()-30;
        imagePos[15] = bumperList.get(i).getRanY()-30;
      }
      //mars   
      if(i ==5){
        imagePos[6] = bumperList.get(i).getRanX()-20;
        imagePos[7] = bumperList.get(i).getRanY()-20;
      }
      //venus
      if(i==6){
        imagePos[2] = bumperList.get(i).getRanX()-15;
        imagePos[3] = bumperList.get(i).getRanY()-15;
      }
      //mercury
      if(i ==7){
        imagePos[4] = bumperList.get(i).getRanX()-15;
        imagePos[5] = bumperList.get(i).getRanY()-15;
      }
    }
  } 
}

/**
 *  Adds different Wall Objects to ArrayList wallList 
 */
void addWalls()
{
  Vec2[] vertices = new Vec2[4];
  vertices[0] = new Vec2(0, 500);
  vertices[1] = new Vec2(0, 560);
  vertices[2] = new Vec2(140, 560);
  vertices[3] = new Vec2(140, 15);

  Wall wallToAdd = new Wall(new Vec2(385, 140), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);
  
  
   vertices = new Vec2[4];
   
  vertices[3] = new Vec2(0, 15);
  vertices[2] = new Vec2(0, 560);
  vertices[0] = new Vec2(155, 500);
  vertices[1] = new Vec2(155, 560);

  wallToAdd = new Wall(new Vec2(0,140), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);

  
  //right most wall
  vertices = new Vec2[4];
  vertices[0] = new Vec2(0, 0);
  vertices[1] = new Vec2(0, 700);
  vertices[2] = new Vec2(20, 700);
  vertices[3] = new Vec2(20, 0);

  wallToAdd = new Wall(new Vec2(580, 0), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);
  
  
  //pluger bouncer
  vertices = new Vec2[4];
  vertices[0] = new Vec2(300, 0);
  vertices[1] = new Vec2(325, 10);
  vertices[2] = new Vec2(400, 80);
  vertices[3] = new Vec2(400, 0);

  wallToAdd = new Wall(new Vec2(200, 0), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);

  //top wall
  vertices = new Vec2[4];
  vertices[0] = new Vec2(0, 0);
  vertices[1] = new Vec2(0, 30);
  vertices[3] = new Vec2(600, 0);
  vertices[2] = new Vec2(600, 30);

  wallToAdd = new Wall(new Vec2(0, 0), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);
  
  
  //left top wall
  vertices = new Vec2[4];
  vertices[0] = new Vec2(0, 0);
  vertices[1] = new Vec2(10, 0);
  vertices[3] = new Vec2(0, 700);
  vertices[2] = new Vec2(10, 700);

  wallToAdd = new Wall(new Vec2(0, 0), vertices);
  wallToAdd.fillColor = color(204,204,255);
  wallToAdd.strokeColor = color(0);
  wallList.add(wallToAdd);
 
}
/**
 *  Adds different Bumper Objects to ArrayList bumperList
 */
void addBumpers()
{ 
  Bumper bumper = new Bumper(new Vec2( 90, 140), 25);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 269, 240), 30);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 465, 165), 30);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 395, 341), 22);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 130, 350), 30);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  
  bumper = new Bumper(new Vec2( 273, 465), 13);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 115, 465), 13);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);
  
  bumper = new Bumper(new Vec2( 415, 465), 11);
  bumper.fillColor = color(255, 0, 0);
  bumperList.add(bumper);  
}
/**
 *  Instantiates the flipperL and flipperR objects
 */
void addFlippers()
{
  flipperL = new Flipper(new Vec2( 164, 650), true);
  flipperL.fillColor = color(255,150,255);

  flipperR = new Flipper(new Vec2( 376, 650), false);
  flipperR.fillColor = color(255,150,255);
}
