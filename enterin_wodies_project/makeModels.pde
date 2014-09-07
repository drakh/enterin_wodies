class bodyParts
{
  bodyPart[][] bp;
  int state=0;//0 spreaded, 1 assembling, 2 assembled, 3 spreading

  float sp=25;//spreaded
  float as=0.25;//assembled

  float frr=25;//initial
  float stp=0.75;//step

  bodyParts(Scene3ds scene)
  {
    bp=new bodyPart[2][8];
    float ld=0.05;
    float zo=3000.0;
    float yo=-1000.0;

    for (int i=0;i<scene.meshes();i++)
    {
      Mesh3ds m = scene.mesh( i );
      int li;
      String[] mn=m.name().split("_");
      String mi=mn[0];
      int lj=int(mn[1]);
      if (mi.equals("f"))
      {
        li=0;
      }
      else li=1;
      ArrayList vertices = new ArrayList();
      for ( int vi=0; vi<m.vertices(); vi++ )
      {
        Vertex3ds p = m.vertex( vi );
        vertices.add(new PVector(p.X, ((p.Y))+yo, (p.Z)+zo ));
        vertices.add(new PVector(p.X, ((p.Y))+yo, (p.Z+ld)+zo ));
        for (int ki=0;ki<23;ki++)
        {
          vertices.add(new PVector(p.X, ((p.Y))+yo, ((p.Z+ld*(ki+1)))+zo ));
          vertices.add(new PVector(p.X, ((p.Y))+yo, ((p.Z+ld*(ki+2)))+zo ));
        }
      }
      bp[li][lj]=new bodyPart(vertices);
    }
  }
  int render(int c)
  {
    int ret=-1;
    if (state==1)
    {
      frr-=stp;
      if (frr<=as)
      {
        state=2;
        frr=as;
        ret=1;
        for (int i=0;i<bp[cm].length;i++)
        {
          bp[cm][i].mkgrey();
        }
      }
    }
    else if (state==3)
    {
      frr+=stp;
      if (frr>=sp)
      {
        state=0;
        frr=sp;
        ret=2;
      }
    }

    float spr=frr+(sin(p)+1)*frr;//spread
    shader.setFloatUniform("sprd", spr);
    for (int i=0;i<bp[c].length;i++)
    {
      bp[c][i].render();
    }

    return ret;
  }
  void spread()
  {
    if (state!=3 && state!=0)
    {
      if (cm==0) cm=1;
      else cm=0;
      for (int i=0;i<bp[cm].length;i++)
      {
        bp[cm][i].mkorigin();
      }
      state=3;
    }
  }
  void assemble()
  {
    if (state!=1 && state!=2)
    {
      state=1;
    }
  }
}
class bodyPart
{
  GLModel m;
  float rnd;
  float n=1;
  float r;
  float g;
  float b;
  bodyPart(ArrayList v)
  {
    m=new GLModel(app, v.size(), GLModel.LINES, GLModel.STATIC);
    m.updateVertices(v);  
    m.setLineWidth(1);
    m.setBlendMode(ADD);
    rnd=random(0, 0.05);
    mkorigin();
  }
  void mkgrey()
  {
    r=0.5;
    g=0.5;
    b=0.5;
  }
  void mkred()
  {
    r=1.0;
    g=0.2;
    b=0.2;
  }
  void mkorigin()
  {
    r=random(0, 1);
    g=random(0, 1);
    b=random(0, 1);
  }
  void render()
  {
    rnd+=n*0.0001;
    if (rnd>0.06) n=-1;
    if (rnd<-0.06) n=-1;
    float cr=r+ (sin(p*10)*((1.0-r)/2));
    float cg=g+ (sin(p*2)*((1.0-g)/2));
    float cb=b+ (sin(p*5)*((1.0-b)/2));
    shader.setFloatUniform("rand", rnd);
    shader.setFloatUniform("cr", cr);
    shader.setFloatUniform("cg", cg);
    shader.setFloatUniform("cb", cb);
    shader.setFloatUniform("ca", 0.1);
    m.render();
  }
}

