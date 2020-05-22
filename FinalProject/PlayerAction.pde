/**
*  Class to store an input made by the player that can be later copied by a clone
*/
class PlayerAction 
{
  long time;
  String direction;
  boolean pressed;
  
  public PlayerAction(String direction, boolean pressed, long time)
  {
    this.direction = direction;
    this.pressed = pressed;
    this.time = time;
  }
  
  /**
  * Checks if the event has happened relative to a clone spawn time
  */
  public boolean hasOccured(long spawnTime)
  {
    return millis() - spawnTime >= time;
  }
}
