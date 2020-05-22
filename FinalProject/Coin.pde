class Coin {
  PVector position;
  float size = 25;
  float edgeBuffer = 30;
  float bouncePos = random(0, 360);
  float bounceSpeed = 0.002;
  float bounceDist = 3;
  
  public Coin(PVector pos) {
    position = pos;
  }
  
  public Coin() {
    float x = random(edgeBuffer, width-edgeBuffer);
    float y = random(edgeBuffer, height-edgeBuffer);
    position = new PVector(x, y);
  }
  
  public void update(long tDelta) {
    bouncePos += bounceSpeed * tDelta;
    
    //Draw coin
    pushMatrix();
      translate(position.x, position.y + (bounceDist * sin(bouncePos)));
      scale(abs(sin(bouncePos)) + 0.01, 1);
      
      fill(#f7cd00);
      noStroke();
      ellipse(0, 0, size, size);
      
      textAlign(CENTER);
      fill(#d49205);
      stroke(#d49205);
      textSize(25);
      
      if(sin(bouncePos) >= 0)
      {
        text("$", 0, 9);
      }
      else
      {
        text("1", 0, 9);
      }
    popMatrix();
    
    //Draw coin edge
    noFill();
    stroke(#d49205);
    strokeWeight((abs(cos(bouncePos)) + 0.5) * 3);
    ellipse(position.x, position.y + (bounceDist * sin(bouncePos)), size * (abs(sin(bouncePos)) + 0.01), size);
  }
  
  public void eat() {
    deleteCoin(this);
  }
  
  /**
  *  Checks if the player is colliding with the coin, used to check if the coin should be eaten and count as a point
  */
  public boolean isPlayerColliding() {
    if(abs(player.position.x - position.x) > size * player.playerScale) return false; //Ensure player is close enough to collide
    if(abs(player.position.y - position.y) > size * player.playerScale) return false; //Ensure player is close enough to collide
    return true;
  }
}
