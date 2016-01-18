/**
*  This is the Ball class that the file PinballFinal uses.
*  Developers can use this class in order to create a Ball
*  in their Box2D world. They utilize this Ball functionality
*  by creating a Ball object, and calling it various methods:
*    1. render
*    2. bumpAway
*    3. offScreen
*    4. remove
*    5. getPosition
*   
*   @author Pranav Madanahalli
*   @version May 29, 2015
*
*/
class Ball
{
  // Box2D body
  Body pBody; 

  // The fill color of the object
  color fillColor = color(255);

  // The stroke color of the object
  color strokeColor = color(0); 
  
  //diameter of ball
  float diameter;
  
  //starting position of ball
  Vec2 startPos;
  /**
   *  Ball contructor
   *  @param diameter
   *  @param starting position of Ball when it spawns
   */
  Ball(float diameter, Vec2 position){
    --ballCount;
    
    this.startPos = position;
    this.diameter = diameter;

    // Create circle shape
    CircleShape shape = new CircleShape();
    shape.m_radius = box2d.scalarPixelsToWorld(diameter/2);

    // Create circle fixture
    FixtureDef fixture = new FixtureDef();
    fixture.shape = shape;
    fixture.density = 1.0f;
    fixture.restitution = 0.5f;

    // Define physics body
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(position));

    // Add body to world
    this.pBody = box2d.createBody(bodyDef);
    this.pBody.createFixture(fixture);
    this.pBody.isBullet();

    // set the callback data to this instance
    this.pBody.setUserData(this);
  }
  
  /**
   *  This method renders the Ball in the Box2D world
   */
  void render(){
  
    stroke(strokeColor);
    fill(fillColor);

    Vec2 ballPos = box2d.getBodyPixelCoord(this.pBody);

    float angle = this.pBody.getAngle();

    pushMatrix();
    translate(ballPos.x, ballPos.y);
    rotate(-angle);
    ellipse(0, 0, diameter, diameter);
    line(0, 0, 0, diameter/2);
    popMatrix();
  }
  /**
   *  This method bumps the ball away from a Body in the Box2D world
   *  @param amount the force to apply to the ball
   *  @normal Vec2 containing points of first contact
   */
  void bumpAway(float amount, Vec2 normal){
    normal.normalize();
    Vec2 pushForce = normal.mul(-amount);
    this.pBody.applyLinearImpulse(pushForce, this.pBody.getPosition(), true);
  }
  /**
   *  This method removes the Body of the Ball when called
   */
  void remove(){
     box2d.destroyBody(this.pBody);
  }
  /**
   *  This method checks if the ball is off the screen
   *  @return true if it is off the screen, false if not
   */
  boolean offScreen()
  {
    Vec2 ballPos = box2d.getBodyPixelCoord(this.pBody);

    return ballPos.y > height;
  }
  /**
   *  This method gets the current position of the ball object
   *  @return Vec2 containing the x and y cordinated of the Ball
   */
  Vec2 getPosition(){

    return box2d.getBodyPixelCoord(this.pBody);
  }
}

