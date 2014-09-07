class Vector3
{
  Vector3()
  {
	x = y = z = 0;
  };

  Vector3( float xx, float yy, float zz )
  {
	x = xx;
	y = yy;
	z = zz;
  };

  Vector3( Vector3 v )
  {
	x = v.x;
	y = v.y;
	z = v.z;
  };

  void set( float xx, float yy, float zz )
  {
	x = xx;
	y = yy;
	z = zz;
  };

  void set( Vector3 v )
  {
	x = v.x;
	y = v.y;
	z = v.z;
  };

  void reset()
  {
	x = 0;
	y = 0;
	z = 0;
  };

  Vector3 copy()
  {
	return new Vector3( x, y, z );
  };

  void add( Vector3 v )
  {
    x += v.x;
    y += v.y;
    z += v.z;
  }

  void add( float x, float y, float z )
  {
    this.x += x;
    this.y += y;
    this.z += z;
  }

  void sub( Vector3 v )
  {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }
  
  Vector3 subtract( Vector3 v )
  {
    Vector3 tmp = new Vector3();
    tmp.x = x - v.x;
    tmp.y = y - v.y;
    tmp.z = z - v.z;
    return tmp;
  }
  

  void mul( Vector3 v )
  {
    x *= v.x;
    y *= v.y;
    z *= v.z;
  }

  void div( Vector3 v )
  {
    x /= v.x;
    y /= v.y;
    z /= v.z;
  }

  //
  // Scalar
  //
  void mul( float s )
  {
    x *= s;
    y *= s;
    z *= s;
  }

  void div( float s )
  {
    x /= s;
    y /= s;
    z /= s;
  }

  float dot( Vector3 v )
  {
    return ( x*v.x + y*v.y + z*v.z );
  } 

  public Vector3 cross( Vector3 v )
  {
     float crossX = y * v.z - v.y * z;
     float crossY = z * v.x - v.z * x;
     float crossZ = x * v.y - v.x * y;
     return( new Vector3(crossX, crossY, crossZ) );
  }

  public float length()
  {
    return (float)Math.sqrt( (x*x) + (y*y) + (z*z) );
  } 

  public float lengthSqr()
  {
    return ( (x*x) + (y*y) + (z*z) );
  } 

  public float lengthXY()
  {
    return (float)Math.sqrt( (x*x) + (y*y) );
  } 

  public void normalize() 
  {
     float m = length();
     if (m > 0) 
     {
        div(m);
     }
  }


boolean SetCatmullRom( Vector3 V1, Vector3 V2, Vector3 V3, Vector3 V4, float s )
{
    float   ss, sss, a, b, c, d;

    ss  = s * s;
    sss = s * ss;

    a = -0.5f * sss + ss - 0.5f * s;
    b =  1.5f * sss - 2.5f * ss + 1.0f;
    c = -1.5f * sss + 2.0f * ss + 0.5f * s;
    d =  0.5f * sss - 0.5f * ss;

    x = a * V1.x + b * V2.x + c * V3.x + d * V4.x;
    y = a * V1.y + b * V2.y + c * V3.y + d * V4.y;
    z = a * V1.z + b * V2.z + c * V3.z + d * V4.z;

    return true;
}

boolean SetHermite( Vector3 V1, Vector3 T1, Vector3 V2, Vector3 T2, float s )
{
    float   ss, sss, a, b, c, d;

    ss  = s * s;
    sss = s * ss;

    a =  2.0f * sss - 3.0f * ss + 1.0f;
    b = -2.0f * sss + 3.0f * ss;
    c =  sss - 2.0f * ss + s;
    d =  sss - ss;

    x = a * V1.x + b * V2.x + c * T1.x + d * T2.x;
    y = a * V1.y + b * V2.y + c * T1.y + d * T2.y;
    z = a * V1.z + b * V2.z + c * T1.z + d * T2.z;

    return true;
}

  boolean SetBaryCentric( Vector3 V1, Vector3 V2, Vector3 V3,  float f, float g )
  {
    x = V1.x + f * (V2.x - V1.x) + g * (V3.x - V1.x);
    y = V1.y + f * (V2.y - V1.y) + g * (V3.y - V1.y);
    z = V1.z + f * (V2.z - V1.z) + g * (V3.z - V1.z);
    
    return true;
  }

  Vector3 lerp( Vector3 V1, float s )
  {
      return new Vector3( x + s * (V1.x - x), y + s * (V1.y - y), z + s * (V1.z - z) );
  }

  Vector3 transform( Matrix m )
  {
      float xx = ( x*m._M[0] + y*m._M[4] + z*m._M[8] + m._M[12] );
      float yy = ( x*m._M[1] + y*m._M[5] + z*m._M[9] + m._M[13] );
      float zz = ( x*m._M[2] + y*m._M[6] + z*m._M[10] + m._M[14] );
        
      return new Vector3( xx, yy, zz );
  }

  /**********************************************************************
  // Static methods
  **********************************************************************/
  public static Vector3 add( Vector3 a, Vector3 b )
  {
    return new Vector3( a.x+b.x, a.y+b.y, a.z+b.z );
  }

  public static Vector3 sub( Vector3 a, Vector3 b )
  {
    return new Vector3( a.x-b.x, a.y-b.y, a.z-b.z );
  } 

  public static Vector3 mul( Vector3 a, Vector3 b )
  {
    return new Vector3( a.x*b.x, a.y*b.y, a.z*b.z );
  }

  public static float dot( Vector3 v1, Vector3 v2 )
  {
    return ( v1.x*v2.x + v1.y*v2.y + v1.z*v2.z );
  } 

  public static Vector3 cross( Vector3 a, Vector3 b )
  {
     float crossX = a.y * b.z - b.y * a.z;
     float crossY = a.z * b.x - b.z * a.x;
     float crossZ = a.x * b.y - b.x * a.y;
     return( new Vector3(crossX, crossY, crossZ) );
  }

  public static float distance( Vector3 v1, Vector3 v2 )
  {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float)Math.sqrt(dx*dx + dy*dy + dz*dz);
  }

  public static float angleBetween( Vector3 v1, Vector3 v2 ) 
  {
    float dot = v1.dot( v2 );
    float theta = (float) Math.acos(dot / (v1.length() * v2.length()));
    return theta;
  }
  
  public static Vector3 ZERO()
  {
    return new Vector3( 0, 0, 0 );
  }

  void debug()
  {  
    System.out.println( x + ", " + y + ", " + z );
  }    
  
  float x, y, z;
};
