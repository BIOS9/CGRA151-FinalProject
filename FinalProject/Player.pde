class Player 
{
  PVector position = new PVector(width/2, height/2);
  float angle = 3*PI/2;
  float speed = 0.1;
  float turnSpeed = 0.004;
  boolean leftPressed = false;
  boolean rightPressed = false;
  boolean rightLastPressed = false;
    
  float opacity = 255;
  float playerScale = 1.2;
  color playerFill = color(#059cd4);
  color cloneFill = color(#D4053D);
  float shadowDarkness = 0.5;
  float lightSourceDistance = 40;
  
  float offScreenBuffer = 10 * playerScale; //playerScale is used so the buffer is consistent with sprite size
  
  boolean isFrozen = false;
  boolean isDead = false;
  boolean isExploding = false;
  boolean winExplode = false;
  ArrayList<Particle> explodeParticles = new ArrayList<Particle>();
  
  boolean isClone = false;
  int cloneLifetime = 0;
  long spawnTime = millis();
  int actionIndex = 0;
  ArrayList<PlayerAction> localActions;
  long deathTime;
  long fadeTime;
  float minCollideOpacity = 40;
  
  
  //EXPLOSION
  float minExplodeSpeed = 0.01;
  float maxExplodeSpeed = 0.1;
  
  float minExplodeRotateSpeed = 0.0001;
  float maxExplodeRotateSpeed = 0.03;
  
  float minExplodeDamping = 0.97;
  float maxExplodeDamping = 0.99;
  
  float minExplodeRotateDamping = 0.9;
  float maxExplodeRotateDamping = 0.99;
  
  float maxExplodeScale = 15;
  float minExplodeScale = 1;
  
  int explodeParticleCount = 30;
  
  float explodeParticleFadeSpeed = 0.07;
  
  long explodeAt = Long.MAX_VALUE;
  
  /*color[] explodePalete = new color[] { 
    color(#5C146F),
    color(#221A56),
    color(#492E9F),
    color(#7330A3),
    color(#9F3F5C),
    color(#EE6F60),
  };*/
  
  color[] explodePalete = new color[] { 
    color(#FED404),
    color(#FF5E34),
    color(#D4053D),
    color(#9B0A41),
    color(#5C184B)
  };
  
  color[] winExplodePalete = new color[] { 
    color(#03fe57),
    color(#02fef5),
    color(#01aefe),
    color(#d800fe),
    color(#00fe94)
  };
  
  public Player() {}
  
  public Player(ArrayList<PlayerAction> localActions)
  {
    this.isClone = true;
    this.localActions = (ArrayList)localActions.clone();
    deathTime = localActions.get(localActions.size() - 1).time;
    fadeTime = deathTime - 2000;
  }
  
  boolean isPlayerColliding()
  {
    if(isDead || player.isDead) return false;
    if(opacity < minCollideOpacity) return false; //Ensure player can only collide with visible clones
    if(abs(player.position.x - position.x) > 15 * playerScale) return false; //Ensure player is close enough to collide
    if(abs(player.position.y - position.y) > 15 * playerScale) return false; //Ensure player is close enough to collide
    return true;
  }
  
  /**
  * Main loop
  * time delta variable used to get time between frames to keep movements consistent
  */
  void update(long tDelta)
  {
    if(isExploding)
      handleExplode(tDelta);
    
    if(millis() >= explodeAt)
    {
        explode();
    }
    
    if(isFrozen)
    {
      redraw();
    }
    else if(!isDead)
    {      
      if(isClone)
      {
        if(opacity == 255 && localActions.size() > 0)
        {
          deathTime = localActions.get(localActions.size() - 1).time;
          fadeTime = deathTime - 2000;
        }
        handleCloneAction();
      }
      control(tDelta);
      checkOffScreen();
      
      //Get the individual componenets of the movement
      float xMovement = cos(angle) * speed * tDelta;
      float yMovement = sin(angle) * speed * tDelta;
      
      //Ensure the player cannot move off screen
      if(position.x + 11 > width && xMovement > 0) xMovement = 0;
      if(position.x - 11 < 0 && xMovement < 0) xMovement = 0;
      if(position.y + 11 > height && yMovement > 0) yMovement = 0;
      if(position.y - 11 < 0 && yMovement < 0) yMovement = 0;
      
      
      position.x += xMovement;
      position.y += yMovement;
      redraw();
    }
  }
  
  void redraw()
  {
    //Handle fade out
    if(isClone)
    {
      if(millis() - spawnTime > fadeTime)
      {
        opacity-=3;
        if(opacity <= 0)
        {
          deleteClone(this);
        }
      }
    }
    
    noStroke();
    
    pushMatrix();
    
      translate(position.x, position.y);
      scale(playerScale);
      
      //Draw player shadow
      pushMatrix();
        fill(0, 0, 0, shadowDarkness * opacity);
        translate((position.x - width/2)/lightSourceDistance, (position.y - height/2)/lightSourceDistance); //Calculate shadow position based on light source
        rotate(angle + PI/2);
        beginShape();
          vertex(0, -10);
          vertex(10, 10);
          vertex(0, 5);
          vertex(-10, 10);
        endShape(CLOSE);
      popMatrix();
      
      //Draw player arrow
      pushMatrix();
        fill(isClone ? cloneFill : playerFill, opacity);
        rotate(angle + PI/2);
        beginShape();
          vertex(0, -10);
          vertex(10, 10);
          vertex(0, 5);
          vertex(-10, 10);
        endShape(CLOSE);
      popMatrix();
      
    popMatrix();
  }
  
  void checkOffScreen()
  {
    if(position.x < -offScreenBuffer) //If player is off left edge of screen
      position.x = width + offScreenBuffer;
    else if(position.x > width + offScreenBuffer) //If player is off right edge of screen
      position.x = -offScreenBuffer;
      
    if(position.y < -offScreenBuffer) //If player is off bottom edge of screen
      position.y = height + offScreenBuffer;
    else if(position.y > height + offScreenBuffer) //If player is off top edge of screen
      position.y = -offScreenBuffer;
  }
  
  void control(long tDelta)
  {
    //Key override logic, latest key pressed will override other key.
    if(rightLastPressed)
    {
      if(rightPressed)
        angle += turnSpeed * tDelta;
      else if(leftPressed)
        angle -= turnSpeed * tDelta;
    }
    else
    {
      if(leftPressed)
        angle -= turnSpeed * tDelta;
      else if(rightPressed)
        angle += turnSpeed * tDelta;
    }
  }
  
  /**
  * Copies movements of player 
  */
  void handleCloneAction()
  {
    if(localActions.size() > actionIndex)
    {
      PlayerAction action = localActions.get(actionIndex);
      if(action.hasOccured(spawnTime))
      {
        switch(action.direction)
        {
          case "left":
            if(action.pressed)
            {
              rightLastPressed = false;
              leftPressed = true;
            }
            else
              leftPressed = false;
            break;
          case "right":
            if(action.pressed)
            {
              rightLastPressed = true;
              rightPressed = true;
            }
            else
              rightPressed = false;
            break;
        }
        actionIndex++;
      }
    }
  }
  
  /**
  * Updates each of the particles used for an explosion
  */
  void handleExplode(long tDelta)
  {
    for(Particle p : explodeParticles)
    {
      p.update(tDelta);
    }
  }
  
  /**
  * Explodes the player/clone using a graphical effec 
  */
  void explode()
  {
    if(isDead) return;
    isDead = true;
    explodeAt = Long.MAX_VALUE;
    for(int i = 0; i < explodeParticleCount; ++i)
      explodeParticles.add(getRandomExplodeParticle());
    isExploding = true;
    isFrozen = false;
  }
  
  /**
  * Generates an explosion particle with a random size, speed, direction, rotation and a color from the pallete
  */
  Particle getRandomExplodeParticle()
  {
    float xVel = nRand(minExplodeSpeed, maxExplodeSpeed);
    float yVel = nRand(minExplodeSpeed, maxExplodeSpeed);

    PVector vel = new PVector(xVel, yVel);
    PVector pos = new PVector(position.x, position.y); //Creates immutable position of player
    Particle p = new Particle(pos, vel);
    
    p.angularVelocity = nRand(minExplodeRotateSpeed, maxExplodeRotateSpeed);
    
    p.velocityDamping = random(minExplodeDamping, maxExplodeDamping);
    p.rotationDamping = random(minExplodeRotateDamping, maxExplodeRotateDamping);
    
    float typeRand = random(0, 3);
    
    if(typeRand < 1)
      p.type = "triangle";
    else if(typeRand < 2)
      p.type = "circle";
    else if(typeRand < 3)
      p.type = "square";
    
    p.scale = random(minExplodeScale, maxExplodeScale);
    
    p.fadeSpeed = explodeParticleFadeSpeed;
    int colorRand = (int)random(0, explodePalete.length);
    if(winExplode)
      p.fillColor = winExplodePalete[colorRand];
    else
      p.fillColor = explodePalete[colorRand];
    p.strokeWeight = 0;
    
    return p;
  }
  
  /**
  *  Random between a minimum and a maximum with a 50% chance of being negative
  */
  float nRand(float min, float max)
  {
    float num = random(min, max);
    if(random(1) > 0.5) num *= -1;
    return num;
  }
}
