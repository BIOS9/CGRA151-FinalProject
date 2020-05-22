/**
*  Particles used in explosions
*/
class Particle
{
  PVector position;
  PVector velocity;
  float angle;
  float angularVelocity;

  float velocityDamping = 1;
  float rotationDamping = 1;

  color fillColor;
  color strokeColor;
  float strokeWeight;
  String type = "square"; //Can be square, circle, triangle
  float scale = 1;
  float fadeSpeed = 0;
  float opacity = 255;

  public Particle(PVector position, PVector velocity)
  {
    this.position = position;
    this.velocity = velocity;
  }

  void update(long tDelta)
  {
    velocity.x *= velocityDamping;
    velocity.y *= velocityDamping;

    position.x += velocity.x * tDelta;
    position.y += velocity.y * tDelta;

    angularVelocity *= rotationDamping;
    angle += angularVelocity * tDelta;

    if (opacity > 0)
    {
      opacity -= fadeSpeed * tDelta;

      switch(type)
      {
      case "square":
        drawSquare();
        break;
      case "triangle":
        drawTriangle();
        break;
      case "circle":
        drawCircle();
        break;
      }
    }
  }

  void drawSquare()
  {
    pushMatrix();
      translate(position.x, position.y);
      strokeWeight(strokeWeight);
      scale(scale);
      rotate(angle);
      fill(fillColor, opacity);
      stroke(strokeColor, opacity);
      rectMode(CENTER);
      rect(0, 0, 1, 1);
    popMatrix();
  }

  void drawCircle()
  {
    pushMatrix();
      translate(position.x, position.y);
      strokeWeight(strokeWeight);
      scale(scale);
      fill(fillColor, opacity);
      stroke(strokeColor, opacity);
      ellipse(0, 0, 1, 1);
    popMatrix();
  }

  void drawTriangle()
  {
    pushMatrix();
      translate(position.x, position.y);
      strokeWeight(strokeWeight);
      scale(scale);
      rotate(angle);
      fill(fillColor, opacity);
      stroke(strokeColor, opacity);
      triangle(0, -0.5, 0.5, 0.25, -0.5, 0.25);
    popMatrix();
  }

  boolean hasFaded() 
  {
    return opacity <= 0;
  }
}
