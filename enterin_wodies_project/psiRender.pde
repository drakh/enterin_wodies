class psiRender
{
  GLModel bp;
  GLTexture t;
  float w=480;
  float h=640;
  float cx=0;
  float cy=0;
  float cz=0;
  psiRender()
  {
    t=new GLTexture(app, "textures/psi.png");
    bp = new GLModel(app, 4, GLModel.QUADS, GLModel.DYNAMIC);

    bp.beginUpdateVertices();
    bp.updateVertex(0, -256, 0, 0);
    bp.updateVertex(1, 0, 0, 0);
    bp.updateVertex(2, 0, 256, 0);
    bp.updateVertex(3, -256, 256, 0);    
    bp.endUpdateVertices();

    bp.initColors();
    bp.setColors(200, 200, 200, 80);
    bp.initTextures(1);
    bp.setBlendMode(ADD);
    setTexture();
  }
  void randomizePos()
  {
    float rx=random(-10, 10);
    float ry=random(-2, 2);
    float rz=random(-10, 20);
    int ra=int(random(-50, 10));

    bp.initColors();
    bp.setColors(200, 200, 200, 80+ra);

    bp.beginUpdateVertices();
    bp.updateVertex(0, cx-(w/2)+rx, cy-(h/2)+ry, (cam_z+500)+0+rz);
    bp.updateVertex(1, cx+(w/2)+rx, cy-(h/2)+ry, (cam_z+500)+0+rz);
    bp.updateVertex(2, cx+(w/2)+rx, cy+(h/2)+ry, (cam_z+500)+0+rz);
    bp.updateVertex(3, cx-(w/2)+rx, cy+(h/2)+ry, (cam_z+500)+0+rz);    
    bp.endUpdateVertices();
  }
  void setTexture()
  {
    bp.setTexture(0, t);
    bp.beginUpdateTexCoords(0);
    bp.updateTexCoord(0, 1, 1);
    bp.updateTexCoord(1, 0, 1);
    bp.updateTexCoord(2, 0, 0);
    bp.updateTexCoord(3, 1, 0);    
    bp.endUpdateTexCoords();
  }
  void render()
  {
    randomizePos();
    bp.render();
  }
}

