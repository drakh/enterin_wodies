class bodyPicture
{
  GLModel bp;
  GLTexture[] t;
  bodyPicture()
  {
    t=new GLTexture[7];
    for (int i=0;i<7;i++)
    {
      t[i]=new GLTexture(app, "textures/"+(i+1)+".png");
    }
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
    setTexture(0);
  }
  void randomizePos()
  {
    float rx=0.0;
    float ry=random(-2, 2);
    float rz=random(-2, 2);
    int ra=int(random(-30, 30));
    bp.initColors();
    bp.setColors(200, 200, 200, 80+ra);

    bp.beginUpdateVertices();
    bp.updateVertex(0, 110+rx, 15+ry, (cam_z+500)+rz);
    bp.updateVertex(1, 370-rx, 15+ry, (cam_z+500)+rz);
    bp.updateVertex(2, 370+rx, 275+ry, (cam_z+500)+rz);
    bp.updateVertex(3, 110+rx, 275+ry, (cam_z+500)+rz);    
    bp.endUpdateVertices();
  }
  void setTexture(int i)
  {
    bp.setTexture(0, t[i]);
    bp.beginUpdateTexCoords(0);
    bp.updateTexCoord(0, 0, 0);
    bp.updateTexCoord(1, 1, 0);    
    bp.updateTexCoord(2, 1, 1);
    bp.updateTexCoord(3, 0, 1);
    bp.endUpdateTexCoords();
  }
  void render()
  {
    randomizePos();
    bp.render();
  }
}

