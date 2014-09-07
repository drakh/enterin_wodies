class textAlert {
  GLTexture a_tex;
  GLModel tA;//text layer
  float cz=cam_z+500;
  textAlert()
  {
    tA=new GLModel(app, 4, GLModel.QUADS, GLModel.STATIC);
    a_tex = new GLTexture(app);
    tA.setBlendMode(BLEND);
    tAinit();
  }
  void tAinit()
  {
    tA.beginUpdateVertices();
    tA.updateVertex(0, -330, -150, cz);
    tA.updateVertex(1, -330, -250, cz);
    tA.updateVertex(2, -50, -250, cz);
    tA.updateVertex(3, -50, -150, cz);
    tA.endUpdateVertices();

    tA.initColors();
    tA.beginUpdateColors();
    for (int i = 0; i < 4; i++) tA.updateColor(i, random(240, 255), random(127, 255), random(127, 255), 127);
    tA.endUpdateColors();
    /*
    PGraphics aoffScreen;
    aoffScreen = createGraphics(280, 100, P2D);
    aoffScreen.beginDraw();
    aoffScreen.background(255,255,255);
    aoffScreen.fill(50, 0, 0);
    aoffScreen.textFont(font[8], 20);
    aoffScreen.text("You are too close.\nYou are hurting me.\nPlease, step back.", 15, 30);
    PImage temp = aoffScreen.get(0, 0, 280, 100);
    a_tex.putImage(temp);
    tA.initTextures(1);
    tA.setTexture(0, a_tex);
    tA.beginUpdateTexCoords(0);
    tA.updateTexCoord(0, 0, 0);
    tA.updateTexCoord(1, 0, 1);
    tA.updateTexCoord(2, 1, 1);
    tA.updateTexCoord(3, 1, 0);    
    tA.endUpdateTexCoords();
    */
  }
  void render()
  {
    tA.render();
  }
}

