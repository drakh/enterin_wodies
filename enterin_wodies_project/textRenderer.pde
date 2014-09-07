class textRenderer 
{
  PGraphics offScreen;
  PGraphics maskLayer;
  PGraphics textLayer;  

  PImage[] masks;
  PImage[] textures;
  PImage caress;

  String[] files= {
    "intro", "brain", "cell", "heart", "lungs", "muscles", "skin", "stomach", "outro"
  };
  Boolean[] stages= {
    false, false, false, false, false, false, false, false, false
  };

  GLTexture t_tex;//texture with rendered texts
  GLModel tL;//text layer
  int state=0;
  float sc=1.0;
  /*where the canvas is drawn*/
  float cx=0;
  float cy=0;
  float cz=cam_z+435;

  float w;
  float h;
  int cur_text=0;

  textRenderer(float wi, float hi)
  {
    w=wi;
    h=hi;
    textures=new PImage[files.length];
    masks=new PImage[files.length];
    caress=loadImage("textures/caress.png");
    for (int i=0;i<files.length;i++)
    {
      textures[i]=loadImage("textures/"+files[i]+".png");
      masks[i]=new PImage(int(w), int(h));
    }
    maskLayer = createGraphics(int(w), int(h), P2D);
    maskLayer.smooth();
    maskLayer.beginDraw();
    maskLayer.background(0);
    maskLayer.fill(255);
    maskLayer.stroke(255);
    maskLayer.endDraw();


    offScreen = createGraphics(int(w), int(h), P2D);
    offScreen.smooth();
    offScreen.beginDraw();
    offScreen.background(0);
    offScreen.endDraw();

    tL=new GLModel(app, 4, GLModel.QUADS, GLModel.DYNAMIC);
    t_tex = new GLTexture(app);
    setVertices();
    setColors();
    tL.setBlendMode(ADD);
  }
  void loadText(int j)
  {
    cur_text=j;
    textLayer = createGraphics(int(w), int(h), P2D);
    textLayer.beginDraw();
    textLayer.image(textures[j], 0, 0);
    textLayer.endDraw();
    offScreen = createGraphics(int(w), int(h), P2D);
    offScreen.smooth();
    offScreen.beginDraw();
    offScreen.background(0);
    offScreen.endDraw();
    if (j>0 && j<8)
    {
      maskLayer.beginDraw();
      maskLayer.background(0);
      maskLayer.image(masks[j], 0, 0);
      maskLayer.endDraw();
    }
    drawToTexture();
  }
  void setVertices()
  {
    tL.beginUpdateVertices();
    tL.updateVertex(0, (cx-(w/2)*sc), (cy+(h/2)*sc), cz);
    tL.updateVertex(1, (cx-(w/2)*sc), (cy-(h/2)*sc), cz);
    tL.updateVertex(2, (cx+(w/2)*sc), (cy-(h/2)*sc), cz);
    tL.updateVertex(3, (cx+(w/2)*sc), (cy+(h/2)*sc), cz);
    tL.endUpdateVertices();
  }
  void setColors()
  {
    tL.initColors();
    tL.beginUpdateColors();
    for (int i = 0; i < 4; i++) tL.updateColor(i, 255, 255, 255, 50);
    tL.endUpdateColors();
  }
  void updateTCoords()
  {
    tL.beginUpdateTexCoords(0);
    tL.updateTexCoord(0, 0, 0);
    tL.updateTexCoord(1, 0, 1);
    tL.updateTexCoord(2, 1, 1);
    tL.updateTexCoord(3, 1, 0);    
    tL.endUpdateTexCoords();
  }
  void render()
  {
    tL.render();
  }
  void drawToTexture()
  {
    offScreen.beginDraw();
    offScreen.background(0);
    if (cur_text==0 || cur_text==8)
    {
      offScreen.image(textLayer, 0, 0);
    }
    else if (stages[cur_text]==true)
    {
      textLayer.mask(maskLayer);
      masks[cur_text]=maskLayer.get(0, 0, int(w), int(h));
      offScreen.image(textLayer, 0, 0);
    }
    else if (stages[cur_text]==false)
    {
      offScreen.image(caress, 0, 0);
    }
    offScreen.endDraw();

    PImage temp = offScreen.get(0, 0, int(w), int(h));
    t_tex.putImage(temp);
    tL.initTextures(1);
    tL.setTexture(0, t_tex);
    updateTCoords();
  }

  void drawMask(PVector v)
  {
    stages[cur_text]=true;
    float hx;
    float hy;
    hx=map(v.x, -950/(paint_t/v.z), 950/(paint_t/v.z), 0, w);
    hy=map(-1*v.y, -700/(paint_t/v.z), 700/(paint_t/v.z), 0, h);
    maskLayer.beginDraw();
    maskLayer.ellipse(hx, hy, 50, 50);
    maskLayer.endDraw();
    drawToTexture();
  }

  void reset()
  {
    for (int i=0;i<stages.length;i++)
    {
      stages[i]=false;
    }
    for (int i=0;i<masks.length;i++)
    {
      masks[i]=new PImage(int(w), int(h));
    }
  }
}

