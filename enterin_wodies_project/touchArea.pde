class touchArea
{
  PVector cntr;
  int area;
  GLModel m;
  int cs=0;
  int ps=0;

  touchArea(PVector c, int a)
  {
    cntr=c;
    area=a;
    mkModel();
  }
  void mkModel()
  {
    m=new GLModel(app, 4, GLModel.QUADS, GLModel.STATIC);
    m.beginUpdateVertices();
    m.updateVertex(0, cntr.x-13, cntr.y-13, cntr.z);
    m.updateVertex(1, cntr.x+13, cntr.y-13, cntr.z);
    m.updateVertex(2, cntr.x+13, cntr.y+13, cntr.z);
    m.updateVertex(3, cntr.x-13, cntr.y+13, cntr.z);    
    m.endUpdateVertices();
    setDefault();
    m.setBlendMode(ADD);
  }
  void setActive()
  {
    m.initColors();
    m.setColors(255, 50, 50, 63);
  }
  void setDefault()
  {
    m.initColors();
    m.setColors(200, 200, 255, 32);
  }
  touchReturn detect(PVector p)
  {
    touchReturn r=new touchReturn();
    float d=cntr.dist(p);
    if (d<150)
    {
      setActive();
    }
    else
    {
      setDefault();
    }
    r.p=cntr;
    r.a=area;
    r.d=d;
    return r;
  }
  void render()
  {
    m.render();
  }
}

