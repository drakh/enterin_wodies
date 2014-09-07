public class Timer
{
  Timer()
  {
    _currTime = 0.0;
    _startTime = 0.0;

    _currFrame = 0;
  }

  void start()
  {
    _startTime = (millis()*0.001);
  }
  
  void update()
  {
    _currTime = (millis()*0.001) - _startTime;
    _currFrame ++;
  }
  
  void reset()
  {
    _startTime = (millis()*0.001);
    _currTime = (millis()*0.001) - _startTime;
  }    
  
  float getTimePassed()
  {
    return _currTime;
  }

  int getCurrFrame()
  {
    return _currFrame;
  }


  //
  // Members
  //
  int _currFrame;  // tells us how many frames passed since the first iteration in the mainloop

  float _currTime;
  float _startTime;

} // end class
