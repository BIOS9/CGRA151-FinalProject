Player player;
long levelStartTime;
long lastFrameTime = millis();
long lastCloneTime = millis();
int cloneInterval = 1500;
int explodeCascadeInterval = 100;

ArrayList<PlayerAction> playerActions = new ArrayList<PlayerAction>();
ArrayList<Player> clones = new ArrayList<Player>();
ArrayList<Player> clonesToDelete = new ArrayList<Player>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<Coin> coinsToDelete = new ArrayList<Coin>();
int coinCount = 1;

float progressBarPadding = 10;
float progressBarHeight = 10;
float progressBarTopMargin = 10;

int level = 1;
boolean switchingLevel = true;
boolean startDisplaying = false; //If the switch level screen should start displaying
long levelSwitchStart = millis(); //When the level switch started
long displayStart = millis(); //When the level switch display started
float levelSwitchLength = 200; //How long the switch lasts
float displayLength = 100; //How long the scree is displayed for
float cloneDelay = 1000; //Delay to prevent clones spawning after level starts
long lastCloneDelay = millis(); //When the last clone was spawned
long startLevelSwitch = millis();
boolean pauseCloneSpawn = false;
boolean explodingClones = false;
long explodeClonesFinish = millis();
boolean lost = false;

void setup()
{
  //fullScreen();
  size(600, 500);
  levelStartTime = millis();
  player = new Player();
  generateCoins();
}

void draw()
{
 
  if(coins.size() == 0 && !explodingClones)
  {
     explodingClones = true;
     explodeClones();
  }
  
  if(explodingClones && millis() > explodeClonesFinish)
  {
    explodingClones = false;
    nextLevel();
  }
  
  long tDelta = millis() - lastFrameTime;
  lastFrameTime = millis();
  
  background(#2F2E2E);
  
  if(switchingLevel)
  {
    drawLevelSwitch();
    return;
  }
  
  
  player.update(tDelta);
  
  for(Player clone : clones)
  {
    clone.update(tDelta);
    if(clone.isPlayerColliding())
      collide(clone);
  }
  
  clones.removeAll(clonesToDelete);
  clonesToDelete.clear();
  
  for(Coin c : coins)
  {
    c.update(tDelta);
    if(c.isPlayerColliding())
    {
      if(player.speed > 0.05)
        player.speed -= 0.001;
      c.eat();
    }
  }
  
  coins.removeAll(coinsToDelete);
  coinsToDelete.clear();
  
  if(millis() - lastCloneTime > cloneInterval && !player.isDead && !pauseCloneSpawn)
  {
    lastCloneTime = millis();
    if(millis() - lastCloneDelay > cloneDelay)
      spawnClone();
  }
  
  if(startDisplaying){
    float alpha = 5 - ((millis() - displayStart) / displayLength);
    if(alpha <= -0.2)
    {
      startDisplaying = false;
    }
    noStroke();
    fill(#2F2E2E, alpha * 100);
    rectMode(CORNER);
    rect(0, 0, width, height);
  }
  
  drawProgressBar();
}

/**
* Called when the player collides with a clone, causing a loss in the game. Everything gets exploded in a chain reaction
*/
void collide(Player clone)
{
  player.explode();
  clone.explode();
  deleteClone(clone);
  explodingClones = true;
  lost = true;
  
  int count = 1;
  for(Player c : clones)
  {
    c.isFrozen = true;
    c.explodeAt = millis() + (explodeCascadeInterval * count);
    count++;
  }
  explodeClonesFinish = millis() + (explodeCascadeInterval * count) + 2000;
}

void spawnClone()
{
  if(playerActions.size() == 0) return;
  clones.add(new Player(playerActions));
}

/**
*  Stores a player input to be later copied by the clones 
*/
void addAction(String direction, boolean pressed)
{
  if(playerActions.size() > 0)
  {
    PlayerAction lastAction = playerActions.get(playerActions.size() - 1);
    if(lastAction.direction.equals(direction) && lastAction.pressed == pressed) return;
  }
  PlayerAction pAction = new PlayerAction(direction, pressed, millis() - levelStartTime); 
  playerActions.add(pAction);
  
  //Add the new action to the existing clones
  for(Player c : clones)
  {
    c.localActions.add(pAction);
  }
}

void deleteClone(Player clone)
{
  clonesToDelete.add(clone);
}

void deleteCoin(Coin c)
{
  coinsToDelete.add(c);
}

/**
*  Creates new coins for the lvel
*/
void generateCoins()
{
  coins.clear();
  for(int i = 0; i < coinCount; ++i)
  {
    coins.add(new Coin());
  }
}

/**
*  Draws bar that shows how many coins are remaining
*/
void drawProgressBar() 
{
  float barWidth = width/2/coinCount;
  rectMode(CORNERS);
  noStroke();
  fill(255);
  pushMatrix();
    translate(width/2 - (barWidth / 2 * coinCount), progressBarTopMargin);
    for(int i = 0; i < coins.size(); ++i)
    {
      rect(0, 0, barWidth - (progressBarPadding / coinCount), progressBarHeight);
      translate(barWidth, 0);
    }
  popMatrix();
}

/**
*  Changes game values and increases the level
*/
void nextLevel()
{
  if(lost)
  {
    level = 1;
    coinCount = 1;  
    cloneInterval = 1500;
  }
  else
  {
    if(cloneInterval > 400)
      cloneInterval -= 200;
    level++;
    coinCount *= 2;  
  }
  switchingLevel = true;
  playerActions.clear();
  levelSwitchStart = millis();
  
  clones.clear();
  generateCoins(); 
}

/**
*  Explodes all clones on the screen with a chain reaction effect using time delays
*/
void explodeClones()
{
  pauseCloneSpawn = true;
  player.isFrozen = true;
  int count = 1;
  for(Player c : clones)
  {
    c.isFrozen = true;
    c.winExplode = true;
    c.explodeAt = millis() + (explodeCascadeInterval * count);
    count++;
  }
  explodeClonesFinish = millis() + (explodeCascadeInterval * count) + 2000;
}

/**
*  Draws screen showing level number and a lose message if the player lost
*/
void drawLevelSwitch()
{
  float alpha; //Opacity for the screen
  alpha = 7 - ((millis() - levelSwitchStart) / levelSwitchLength);
    
  if(alpha <= -0.1)
  {
    switchingLevel = false;
    startDisplaying = true;
    displayStart = millis();
    player.isFrozen = false;
    player = new Player();
    lastCloneDelay = millis();
    pauseCloneSpawn = false;
    lost = false;
    levelStartTime = millis();
    return;
  }
  
  fill(0, alpha * 255);
  rectMode(CORNER);
  rect(0, 0, width, height);
  textAlign(CENTER);
  textSize(100);
  fill(255, alpha * 100);
  text("Level " + level, width/2, height/2);
  if(lost)
  {
    textSize(70);
    fill(#FF5E34, alpha * 100);
    text("You Lost!", width/2, height/2 - 100);
  }
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode)
    {
      case LEFT:
        player.leftPressed = true;
        player.rightLastPressed = false;
        addAction("left", true);
        break;
      case RIGHT:
        player.rightPressed = true;
        player.rightLastPressed = true;
        addAction("right", true);
        break;
    }
  }
}
  
void keyReleased() {
  if (key == CODED) {
    switch(keyCode)
    {
      case LEFT:
        player.leftPressed = false;
        addAction("left", false);
        break;
      case RIGHT:
        player.rightPressed = false;
        addAction("right", false);
        break;
    }
  }
}
