/**
*  This is the Wall class that the file PinballFinal uses.
*  Developers can use this class in order to create a Wall
*  in their Box2D world. They utilize this Wall functionality
*  by creating a Wall object, and calling it various methods:
*    1. render
*
*  This object contains the balls within the frame. The ball 
*  bounces off these walls.
*
*   @author Pranav Madanahalli
*   @version May 29, 2015
*
*/
class Wall 
{
  // Box2D body
  Body pBody; 
  PShape pShape;
  // The fill color of the object
  color fillColor = color(255);

  // The stroke color of the object
  color strokeColor = color(0); 

  // Position in processing coords
  Vec2 position;
  /**
   *  Wall Constuctor
   *  @param starting position of Bumper when it spawns
   *  @param Array Vector that stories the verticies of the points to make the Wall shape.
   */
  Wall(Vec2 position, Vec2[] vertices)
  {
    // Create shape
    PolygonShape shape = new PolygonShape();

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
    bodyDef.type = BodyType.STATIC;
    bodyDef.position.set(box2d.coordPixelsToWorld(position));

    // Add body to world
    this.pBody = box2d.createBody(bodyDef);
    this.pBody.createFixture(shape, 1);

    // Store the screen position for later
    this.position = position;

    // set the callback data to this instance
    this.pBody.setUserData(this);
  }
  /**
   *  Renders the Wall on the Screen
   */
  void render()
  {
    // Since we're using a PShape we can't just call fill and stroke
    pShape.setFill(fillColor);
    pShape.setStroke(strokeColor);

    pushMatrix();
    translate(position.x, position.y);
    shape(pShape);
    popMatrix();
  }
}

