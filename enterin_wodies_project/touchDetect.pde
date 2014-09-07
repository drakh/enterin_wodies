class touchReturn
{
  PVector p;
  int a;
  float d;
  touchReturn()
  {
  }
}
class touchDetect
{
  touchArea[][] areas;
  touchDetect()
  {
    areas =new touchArea[2][9];
    for (int i=0;i<2;i++)
    {
      String[] inp=loadStrings("model/areas_"+i+".txt");
      for (int j=0;j<inp.length;j++)
      {
        String s=trim(inp[j]);
        String[] e=split(s, "|");
        areas[i][j]=new touchArea(new PVector(float(e[0]), float(e[1]), float(e[2])), int(e[3]));
      }
    }
  }
  touchReturn detect(PVector p, int c)
  {
    touchReturn r=new touchReturn();
    float d=500000;

    for (int i=0;i<areas[c].length;i++)
    {
      touchReturn ra=areas[c][i].detect(p);
      if (ra.d<d)
      {
        d=ra.d;
        r=ra;
      }
    }
    return r;
  }
  void render(int c)
  {
    for (int i=0;i<areas[c].length;i++)
    {
      areas[c][i].render();
    }
  }
}

