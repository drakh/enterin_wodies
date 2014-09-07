class BgPlayer
{
  int c=1;
  AudioPlayer song[];
  String[] files= {
    "body", "brain", "cell", "heart", "lungs", "muscles", "skin", "stomach"
  };
  BgPlayer()
  {
    song=new AudioPlayer[files.length];
    for (int i=0;i<files.length;i++)
    {
      song[i] = minim.loadFile("wavs/"+files[i]+".wav", 9096);
      song[i].rewind();
      song[i].setGain(-30.0);
      song[i].loop();
    }
  }
  void fadeIn(int i)
  {
    song[i].shiftGain(-30.0,0,1200);
  }
  void fadeOut(int i)
  {
    song[i].shiftGain(0,-30,1200);
  }
}

