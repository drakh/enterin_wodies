class Cam
{
  float ro;
  float fi;
  float r;
  float x0;
  float y0;
  float z0;
  float tx0;
  float ty0;
  float tz0;
  Cam(float x, float y, float z, float tx, float ty, float tz)
  {
    x0=x;
    y0=y;
    z0=z;
    tx0=tx;
    tz0=tz;
    ty0=ty;
    r=sqrt((x-tx)*(x-tx)+(y-ty)*(y-ty)+(z-tz)*(z-tz));
    ro=acos(y/r);
    fi=atan(z/x);  
    camera(x, y, z, tx, ty, tz, 0, -1, 0);
    perspective(45, float(width)/float(height), 10, 150000);
  }
  void sTOc()
  {
    x0=r*sin(ro)*cos(fi);
    y0=r*cos(ro);
    z0=r*sin(ro)*sin(fi);
    camera(x0+tx0, y0+ty0, z0+tz0, tx0, ty0, tz0, 0, -1, 0);
    perspective(45, float(width)/float(height), 10, 150000);
  }
  void camUP()
  {
    ro+=0.01;
    sTOc();
  }
  void camDOWN()
  {
    ro-=0.01;
    sTOc();
  }
  void camLEFT()
  {
    fi+=0.01;
    sTOc();
  }
  void camRIGHT()
  {
    fi-=0.01;
    sTOc();
  }
}

