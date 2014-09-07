class closeArea
{
  GLModel cls;
  GLTexture cls_t;
  int pstate=0;
  closeArea()
  {
    cls_t=new GLTexture(app, "textures/explore_more.png");
    cls=new GLModel(app, 4, GLModel.QUADS, GLModel.STATIC);
    cls.beginUpdateVertices();
    cls.updateVertex(0, 110, 15, (cam_z+500));
    cls.updateVertex(1, 370, 15, (cam_z+500));
    cls.updateVertex(2, 370, -50, (cam_z+500));
    cls.updateVertex(3, 110, -50, (cam_z+500));    
    cls.endUpdateVertices();

    setWhite();
    cls.initTextures(1);
    cls.setTexture(0, cls_t);
    cls.beginUpdateTexCoords(0);
    cls.updateTexCoord(0, 0, 0);
    cls.updateTexCoord(1, 1, 0);    
    cls.updateTexCoord(2, 1, 1);
    cls.updateTexCoord(3, 0, 1);
    cls.endUpdateTexCoords();
    cls.setBlendMode(ADD);
  }
  void setRed()
  {
    cls.initColors();
    cls.setColors(255, 0, 0, 80);
  }
  void setWhite()
  {
    cls.initColors();
    cls.setColors(255, 255, 255, 80);
  }
  boolean detect(PVector vr, PVector vl)
  {
    int cstate;
    boolean r=false;
    if ((vr.x>330 && vr.x<900 && vr.y>-100 && vr.y<15 && vr.z<2400) || (vl.x>330 && vl.x<900 && vl.y>-100 && vl.y<15 && vl.z<2400))
    {
      setRed();
      cstate=1;
    }
    else
    {
      setWhite();
      cstate=0;
    }
    if(pstate==1 && cstate==0) r=true;
    pstate=cstate;
    return r;
  }
  void render()
  {
    cls.render();
  }
}

