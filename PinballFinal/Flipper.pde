/**
*  This is the Flipper class that the file PinballFinal uses.
*  Developers can use this class in order to create a Flipper
*  in their Box2D world. In order to provide motion to the 
*  flipper, I used the Box2D physics element Revolute Joint.
*  They utilize this Flipper functionality by creating a 
*  Flipper object, and calling it various methods:
*    1. render
*    2. flip
*
*  This object flips the ball upwards towards the Bumpers.
*  You control these flipper using the z and / keys.
*
*   @author Pranav Madanahalli
*   @version May 29, 2015
*
*/
class Flipper 
{
  // Box2D body
  Body pBody; 
  PShape pShape;
  //is it the left flipper?
  boolean leftFlipper;

  // The fill color of the object
  color fillColor = color(255);

  // The stroke color of the object
  color strokeColor = color(0); 

  /**
   *  Flipper Constuctor
   *  @param starting position of Flipper when it spawns
   *  @param boolean is left flipper?
   */
  Flipper(Vec2 position, boolean leftFlipper)
  {
    this.leftFlipper = leftFlipper;

    // Create shape
    PolygonShape shape = new PolygonShape();

    Vec2[] vertices = new Vec2[4];

    if (leftFlipper)
    {
      vertices[0] = new Vec2(0, 0);
      vertices[1] = new Vec2(0, 20);
      vertices[2] = new Vec2(100, 12);
      vertices[3] = new Vec2(100, 8);
    } else
    {
      vertices[0] = new Vec2(0, 12);
      vertices[1] = new Vec2(0, 8);
      vertices[2] = new Vec2(100, 0);
      vertices[3] = new Vec2(100, 20);
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
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(position));

    // Add body to world
    this.pBody = box2d.createBody(bodyDef);
    this.pBody.createFixture(shape, 10);


    // Create base
    PolygonShape baseShape = new PolygonShape();
    baseShape.setAsBox(1, 1);

    // Define physics body
    BodyDef baseBodyDef = new BodyDef();
    baseBodyDef.type = BodyType.STATIC;
    baseBodyDef.position.set(box2d.coordPixelsToWorld(new Vec2(position.x, position.y)));
    baseBodyDef.setFixedRotation(true);

    // Add body to world
    Body baseBody = box2d.createBody(baseBodyDef);
    baseBody.createFixture(baseShape, 1);

    RevoluteJointDef rotationJoint = new RevoluteJointDef();
    rotationJoint.bodyA = pBody;
    rotationJoint.bodyB = baseBody;
    rotationJoint.collideConnected = false;

    // Set rotation origin
    if (leftFlipper)
    {
      rotationJoint.localAnchorA = new Vec2(0.0, -0.5);
    } else
    {
      rotationJoint.localAnchorA = new Vec2(10.0, -0.5);
    }
    rotationJoint.enableLimit = true;
    rotationJoint.lowerAngle = radians(-25);
    rotationJoint.upperAngle = radians(25);

    box2d.createJoint(rotationJoint);
    // set the callback data to this instance
    this.pBody.setUserData(this);
  }
  /**
   *  Renders the Flipper 
   */
  void render()
  {
    // Since we're using a PShape we can't just call fill and stroke
    pShape.setFill(fillColor);
    pShape.setStroke(strokeColor);

    Vec2 ballPos = box2d.getBodyPixelCoord(this.pBody);

    float angle = this.pBody.getAngle();

    pushMatrix();
    translate(ballPos.x, ballPos.y);
    rotate(-angle);
    shape(pShape);
    popMatrix();
  }
  /**
   *  flips the flipper by applying torque to it
   *  @param the amount of torque to apply to Flipper
   *  @param boolean is left Flipper?
   */
  void flip(float amt, boolean isLeftFlipper)
  {
    if (isLeftFlipper == leftFlipper)
    {
      this.pBody.applyTorque(amt * (leftFlipper ? 1 : -1));
    }

  }
}

