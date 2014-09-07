class Vector4
{
  Vector4()
  {
	x = y = z = w = 0;
  };

  Vector4( float xx, float yy, float zz, float ww )
  {
	x = xx;
	y = yy;
	z = zz;
	w = ww;
  };

  Vector4( Vector4 v )
  {
	x = v.x;
	y = v.y;
	z = v.z;
	w = v.w;
  };

  void set( float xx, float yy, float zz, float ww )
  {
	x = xx;
	y = yy;
	z = zz;
	w = ww;
  };

  void reset()
  {
	x = 0;
	y = 0;
	z = 0;
	w = 0;
  };

  Vector4 copy()
  {
	return new Vector4( x, y, z, w );
  };

  void add( Vector4 v )
  {
    x += v.x;
    y += v.y;
    z += v.z;
    w += v.w;
  }

  void sub( Vector4 v )
  {
    x -= v.x;
    y -= v.y;
    z -= v.z;
    w *= v.w;
  }

  void mul( Vector4 v )
  {
    x *= v.x;
    y *= v.y;
    z *= v.z;
    w *= v.w;
  }

  void div( Vector4 v )
  {
    x /= v.x;
    y /= v.y;
    z /= v.z;
    w /= v.w;
  }

  //
  // Scalar
  //
  void mul( float s )
  {
    x *= s;
    y *= s;
    z *= s;
    w *= s;
  }

  void div( float s )
  {
    float inv = 1.0f / s;
    x *= inv;
    y *= inv;
    z *= inv;
    w *= inv;
  }

  float dot( Vector4 v )
  {
    return ( x*v.x + y*v.y + z*v.z + w*v.w );
  } 

  public Vector3 cross( Vector4 v )
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

  public void normalize() 
  {
     float m = length();
     if (m > 0) 
     {
        div(m);
     }
  }

  Vector4 lerp( Vector4 V1, float s )
  {
      return new Vector4( x + s * (V1.x - x), y + s * (V1.y - y), z + s * (V1.z - z), w + s * (V1.w - w) );
  }

  boolean SetBaryCentric( Vector4 V1, Vector4 V2, Vector4 V3,  float f, float g )
  {
    x = V1.x + f * (V2.x - V1.x) + g * (V3.x - V1.x);
    y = V1.y + f * (V2.y - V1.y) + g * (V3.y - V1.y);
    z = V1.z + f * (V2.z - V1.z) + g * (V3.z - V1.z);
    
    return true;
  }

  Vector4 transform( Matrix m )
  {
      float xx = ( x*m._M[0] + y*m._M[4] + z*m._M[8] + m._M[12] );
      float yy = ( x*m._M[1] + y*m._M[5] + z*m._M[9] + m._M[13] );
      float zz = ( x*m._M[2] + y*m._M[6] + z*m._M[10] + m._M[14] );
      float ww = 0;
        
      return new Vector4( xx, yy, zz, ww );
  }

  /**********************************************************************
  // Static methods
  **********************************************************************/
  public static Vector4 add( Vector4 a, Vector4 b )
  {
    return new Vector4( a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w );
  }

  public static Vector4 sub( Vector4 a, Vector4 b )
  {
    return new Vector4( a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w );
  } 

  public static Vector4 mul( Vector4 a, Vector4 b )
  {
    return new Vector4( a.x*b.x, a.y*b.y, a.z*b.z, a.w*b.w );
  }

  public static Vector3 cross( Vector3 a, Vector3 b )
  {
     float crossX = a.y * b.z - b.y * a.z;
     float crossY = a.z * b.x - b.z * a.x;
     float crossZ = a.x * b.y - b.x * a.y;
     return( new Vector3(crossX, crossY, crossZ) );
  }

  public static float distance( Vector4 v1, Vector4 v2 )
  {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float)Math.sqrt(dx*dx + dy*dy + dz*dz);
  }

  public static float angleBetween( Vector4 v1, Vector4 v2 ) 
  {
    float dot = v1.dot( v2 );
    float theta = (float) Math.acos(dot / (v1.length() * v2.length()));
    return theta;
  }

  void debug()
  {  
    System.out.println( x + ", " + y + ", " + z + ", " + w );
  }    
  
  
  float x, y, z, w;
};
