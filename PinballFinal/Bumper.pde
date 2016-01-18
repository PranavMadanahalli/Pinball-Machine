/**
*  This is the Bumper class that the file PinballFinal uses.
*  Developers can use this class in order to create a Bumper
*  in their Box2D world. They utilize this Bumper functionality
*  by creating a Bumper object, and calling its various methods:
*    1. render
*    2. getPosition
*    3. randomize
*    4. getRandomLocation
*    5. randomCheck
*    6. collide
*    7. removeBody
*    8. getRanX
*    9. getRanY
*
*  This object bumps the ball away when they collide.
*   
*   @author Pranav Madanahalli
*   @version May 29, 2015
*
*/
class Bumper 
{
  // Box2D body
  Body pBody; 
  //shape of body
  PShape pShape;
  //if it is within the sound thread or not
  boolean inThread;
  //shape of Bumper
  PolygonShape shape;
  //Body Definitiion
  BodyDef bodyDef;
  
  //Vector that holds the position of the bumper
  Vec2 pos;
  //radius of the bumper
  Float radi;
  //if the bumper is randomly changed or not
  boolean changed;
  
  //the random positions of the bumper
  int ranx;
  int rany;

  // The fill color of the object
  color fillColor = color(255);

  // The stroke color of the object
  color strokeColor = color(0); 


 /**
   *  Bumper Constuctor
   *  @param starting position of Bumper when it spawns
   *  @param radius of Bumper
   */
  Bumper(Vec2 position, float radius)
  {
    pos = position;
    changed = false;
    radi = radius;
    
    // Create shape
    shape = new PolygonShape();

    Vec2[] vertices = new Vec2[8];
    float angleStep = PI/4;
    for (int i = 0; i < 8; i++)
    {
      vertices[i] = new Vec2(radius * cos(angleStep*i), radius * sin(angleStep*i));
    }

    // Create an array to temporarily store the box2D vertex coordinates
    Vec2[] box2DVertices = new Vec2[vertices.length];

    // Create a new PShape
    pShape = createShape();
    pShape.beginShape();

    // Iterate through every vertex
    for (int i = 0; i < vertices.length; i++)
    {
      float x = vertices[i].x;
      float y = vertices[i].y;

      // Add the vertex to the shape
      pShape.vertex(x, y);

      // Add the vertex (converted to box2D coords)
      box2DVertices[i] = new Vec2(box2d.scalarPixelsToWorld(x), -box2d.scalarPixelsToWorld(y));
    }

    // End the PShape
    pShape.endShape(CLOSE);

    // Set the box2D vertices 
    shape.set(box2DVertices, box2DVertices.length);

    // Define physics body
    bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(position));

    // Add body to world
    this.pBody = box2d.createBody(bodyDef);
    this.pBody.createFixture(shape, 1);

    // set the callback data to this instance
    this.pBody.setUserData(this);
  }
  /**
   *  Gets the current position of the Bumper
   */
  Vec2 getPosition(){
    return pos;
    
  }
  /**
   *  This method is called to get a random
   *  position of the bumper.
   */
  void randomize(){
    
    //gets the Random X and Y cordinates
    getRandomLocation();
    //creats a new Body
    shape = new PolygonShape();
    Vec2[] vertices = new Vec2[8];
    float angleStep = PI/4;
    for (int i = 0; i < 8; i++)
    {
      vertices[i] = new Vec2(radi * cos(angleStep*i), radi * sin(angleStep*i));
    }

    // Create an array to temporarily store the box2D vertex coordinates
    Vec2[] box2DVertices = new Vec2[vertices.length];

    // Create a new PShape
    pShape = createShape();
    pShape.beginShape();

    // Iterate through every vertex
    for (int i = 0; i < vertices.length; i++)
    {
      float x = vertices[i].x;
      float y = vertices[i].y;

      // Add the vertex to the shape
      pShape.vertex(x, y);

      // Add the vertex (converted to box2D coords)
      box2DVertices[i] = new Vec2(box2d.scalarPixelsToWorld(x), -box2d.scalarPixelsToWorld(y));
    }

    // End the PShape
    pShape.endShape(CLOSE);

    // Set the box2D vertices 
    shape.set(box2DVertices, box2DVertices.length);

    // Define physics body
    bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(pos));
   
    
     //removes current bumper Body
    removeBody();
    // Add new Body to the world
    this.pBody = box2d.createBody(bodyDef);
    //set pastBumper to bodydef;
    this.pBody.createFixture(shape, 1);

    // set the callback data to this instance
    this.pBody.setUserData(this);
  }
  /**
   *  Removes the current Bumper Body from Box2D world.
   */
  void removeBody(){
    box2d.destroyBody(this.pBody);
  }
  /**
   *  Generates the Random X and Y cordinates between
   *  a general zone in the playing field(xmin: 100, xmax: 500, ymin: 100, ymax: 500)
   */
  void getRandomLocation(){
    
    int tempx = (int)pos.x;
    int tempy = (int)pos.y;
    //Random points
    ranx = (int)(Math.random()*500) +100;
    rany = (int)(Math.random()*500) +50;
    tempx = ranx;
    tempy = rany;
    //Checks if random points are in the general zone of playing map
    if(randomCheck(tempx, tempy)){
      pos.x = tempx;
      pos.y = tempy;
      changed = true;
    } 
    //if not, keep the same position
    else{
      pos.x = pos.x;
      pos.y = pos.y;
      changed = false;
    }
  }
  /**
   *  Checks the new Random points to see if it lies
   *  between the general zone stated above
   */
  boolean randomCheck(int x, int y){
    return y < 501 && x < 501 && x > 49 && y > 99;
  }
  /**
   *  Gets the new Random X position
   */
  int getRanX(){
    if(changed){
      return ranx;
    }
    else{
      return (int)pos.x;
    }
  }
  /**
   *  Gets the new Random Y position
   */
  int getRanY(){
    if(changed){
      return rany;
    }
    else{
      return (int)pos.y;
    }
  }
  /**
   *  This method renders the Bumper in the Box2D world
   */
  void render()
  {
    // Since we're using a PShape we can't just call fill and stroke
    pShape.setFill(fillColor);
    pShape.setStroke(strokeColor);

    Vec2 ballPos = box2d.getBodyPixelCoord(this.pBody);

    float angle = this.pBody.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    shape(pShape);
    popMatrix();
  }
  /**
   *  Controls the collision between the ball and the Bumper
   *  @param Ball is the current ball object
   *  @param Vec2 containing points of first contact
   */
  void collide(Ball ball, Vec2 normal)
  {
    // Physically bump the ball away
    ball.bumpAway(200, normal); 


    // Create a new thread
    Thread resetBumper = new Thread()
    {
      @Override
        public void run()
      {
        // Wait one second and change
        // The color back to it's original color
        delay(250);
        inThread = false;
      }
    };

    if (!inThread)
    {
      inThread = true;

      // Set volume to max
      gainValue.setValue(1.0f);

      // Reset the scrubber on the sound to start position
      dingSound.setToLoopStart();

      // Play the ding sound!
      dingSound.start();

      // Run the new thread
      resetBumper.start();
    }

    // Add to Player Score
    playerScore += 10;
  }
}

