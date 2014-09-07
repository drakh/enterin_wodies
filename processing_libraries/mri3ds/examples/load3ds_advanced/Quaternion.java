/***
	Quaternion class
	created by victor martins __ pixelnerve

	http://vic.pixelnerve.com
*/

class Quaternion
{
  Quaternion()
  {
    x = y = z = 0;
    w = 1;
    //setIdentity();
  };

  Quaternion( float a, float xx, float yy, float zz )
  {
    w = a;
    x = xx;
    y = yy;
    z = zz;
  };

  Quaternion( float a, Vector3 v )
  {
    w = a;
    x = v.x;
    y = v.y;
    z = v.z;
  };

  void reset()
  {
    w = 0.0f;
    x = 0.0f;
    y = 0.0f;
    z = 0.0f;
  }

  void setIdentity()
  {
    w = 1.0f;
    x = 0.0f;
    y = 0.0f;
    z = 0.0f;
  }
  
  void set( Quaternion q )
  {
    w = q.w;
    x = q.x;
    y = q.y;
    z = q.z;
  } 

  void set( float w, Vector3 v )
  {
    w = w;
    x = v.x;
    y = v.y;
    z = v.z;
  } 

  Quaternion add( Quaternion q )
  {
    Quaternion tmp = new Quaternion();
    tmp.w = w+q.w;
    tmp.x = x+q.x;
    tmp.y = y+q.y;
    tmp.z = z+q.z;
    return tmp;
  }

  Quaternion sub( Quaternion q )
  {
    Quaternion tmp = new Quaternion();
    tmp.w = w-q.w;
    tmp.x = x-q.x;
    tmp.y = y-q.y;
    tmp.z = z-q.z;
    return tmp;
  }


  Quaternion mul( float s )
  {
    Quaternion tmp = new Quaternion();
    tmp.w = w*s;
    tmp.x = x*s;
    tmp.y = y*s;
    tmp.z = z*s;
    return tmp;
  }

  
  void normalize()
  {
    float ilen = 1.0f / length();
    w *= ilen;
    x *= ilen;
    y *= ilen;
    z *= ilen;
  }

  float length()
  {
    return (float)Math.sqrt( (w*w) + (x*x) + (y*y) + (z*z) );
  }

  void conjugate()
  {
    x = -x;
    y = -y;
    z = -z;  
  } 
  
/*  void eulerToQuat( float roll, float pitch, float yaw )
  {
	float cr, cp, cy, sr, sp, sy, cpcy, spsy;

  // calculate trig identities
  cr = cos(roll/2);

	cp = cos(pitch/2);
	cy = cos(yaw/2);


	sr = sin(roll/2);
	sp = sin(pitch/2);
	sy = sin(yaw/2);
	
	cpcy = cp * cy;
	spsy = sp * sy;


	quat->w = cr * cpcy + sr * spsy;
	quat->x = sr * cpcy - cr * spsy;
	quat->y = cr * sp * cy + sr * cp * sy;
	quat->z = cr * cp * sy - sr * sp * cy;
  }  */

  void rotateAxis( Vector3 axis, float angle )
  {
    // Axis is a unit vector
    float halfAngle = angle * 0.5f;
    float sina = (float)Math.sin( halfAngle );
    w  = (float)Math.cos( halfAngle );
    x = axis.x * sina;
    y = axis.y * sina;
    z = axis.z * sina;
  }

  /*Matrix toRotationMatrix()
  {
    Matrix m = new Matrix();
    m.identity();

    //m._M[ 0] = (w*w) + (x*x) - (y*y) - (z*z);
    m._M[ 0] = 1 - (2*y*y) - (2*z*z);
    m._M[ 1] = (2*x*y) + (2*w*z);
    m._M[ 2] = (2*x*z) - (2*w*y);
    m._M[ 3] = 0;

    m._M[ 4] = (2*x*y) - (2*w*z);
    //m._M[ 5] = (w*w) - (x*x) + (y*y) - (z*z);
    m._M[ 5] = 1 - (2*x*x) - (2*z*z);
    m._M[ 6] = (2*y*z)+(2*w*x);
    m._M[ 7] = 0;

    m._M[ 8] = (2*x*z)+(2*w*y);
    m._M[ 9] = (2*y*z)-(2*w*x);
    //m._M[10] = (w*w) - (x*x) - (y*y) + (z*z);
    m._M[10] = 1 - (2*x*x) - (2*y*y);
    m._M[11] = 0;

    m._M[12] = 0;
    m._M[13] = 0;
    m._M[14] = 0;
    m._M[15] = 1;

    return m;
  }*/

  Matrix toRotationMatrix()
  {
	float wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2; 
        Matrix m = new Matrix();
        m.identity();
        
	x2 = x + x; 
	y2 = y + y; 
	z2 = z + z;
	
	xx = x * x2; xy = x * y2; xz = x * z2;
	yy = y * y2; yz = y * z2; zz = z * z2;
	wx = w * x2; wy = w * y2; wz = w * z2;

	m._M[0] = 1.0f - (yy + zz); 
	m._M[1] = xy + wz; 
	m._M[2] = xz - wy; 
	m._M[3] = 0;

	m._M[4] = xy - wz;
	m._M[5] = 1.0f - (xx + zz);
	m._M[6] = yz + wx;
	m._M[7] = 0;

	m._M[8] = xz + wy; 
	m._M[9] = yz - wx; 
	m._M[10] = 1.0f - (xx + yy); 
	m._M[11] = 0;

	m._M[12] = 0;
	m._M[13] = 0;
	m._M[14] = 0;
	m._M[15] = 1;

        return m;
  }
  
  public Vector3 mul( Vector3 v )
  {
    // nVidia SDK implementation
    Vector3 uv = new Vector3();
    Vector3 uuv = new Vector3();
    Vector3 qvec = new Vector3( x, y, z );
    uv = qvec.cross( v );
    uuv = qvec.cross( uv );
    uv.mul( 2.0f * w );
    uuv.mul( 2.0f );

    Vector3 result = v.copy();
    result.add( uv );
    result.add( uuv );
    
    return result;
  }
  
  
  public static float dot( Quaternion q1, Quaternion q2 )
  {
    return q1.w*q2.w + q1.x*q2.x + q1.y*q2.y + q1.z*q2.z;
  } 


  //
  // Quaternion multiplication
  //
  public static Quaternion mul( Quaternion q1, Quaternion q2 )
  {
    Quaternion q = new Quaternion();
    q.w = q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z;
    q.x = q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y;
    q.y = q1.w*q2.y - q1.x*q2.z + q1.y*q2.w + q1.z*q2.x;
    q.z = q1.w*q2.z + q1.x*q2.y - q1.y*q2.x + q1.z*q2.w;
    return q;
  }
/*  static Quaternion mul( Quaternion q1, Quaternion q2 )
  {
    Quaternion res = new Quaternion();
    res.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    res.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    res.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
    res.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
    return res;
  }*/
  
  public static Quaternion mul( Quaternion q, float s )
  {
    Quaternion tq = new Quaternion();
    tq.w = q.w * s;
    tq.x = q.x * s;
    tq.y = q.y * s;
    tq.z = q.z * s;
    return tq;
  }
    
  
  public static Vector3 transformVector( Quaternion q, Vector3 v, float angle )
  {
	Matrix m = q.toRotationMatrix();
	Vector3 vt = v.copy();
	vt.transform( m );

	return vt;
  }
  
  
  public static Quaternion lerp( Quaternion from, Quaternion to, float t )
  {
    Quaternion q = new Quaternion();
    float onet = 1.0f - t;

    //Quaternion tq1 = Quaternion.mul( from, onet );
    //Quaternion tq2 = Quaternion.mul( to, t );
    //q = tq1.add( tq2 );
    q.w = onet * from.w + t * to.w;    
    q.x = onet * from.x + t * to.x;
    q.y = onet * from.y + t * to.y;
    q.z = onet * from.z + t * to.z;
    
    return q;
  }
  
  public static Quaternion slerp( Quaternion from, Quaternion to, float t )
  {
    Quaternion q = new Quaternion();
    Quaternion to2 = new Quaternion();
    float omega, cosom, sinom;
    float scale0=1, scale1=0;
    
    float dot = from.x*to.x + from.y*to.y + from.z*to.z + from.w*to.w;
    if( dot < 0.0f )
    {
      dot = -dot;
      to2.w = -to.w;
      to2.x = -to.x;
      to2.y = -to.y;
      to2.z = -to.z;
    }
    else
    {
      to2.w = to.w;
      to2.x = to.x;
      to2.y = to.y;
      to2.z = to.z;
    }
      
    float DELTA = 0.0000001f;
    if ( (1.0-dot) > DELTA ) 
    {
      // standard case (slerp)
      omega = (float)Math.acos(dot);
      sinom = (float)Math.sin(omega);
      float isinom = 1.0f / sinom;
      scale0 = (float)Math.sin((1.0f - t) * omega) * isinom;
      scale1 = (float)Math.sin(t * omega) * isinom;
    } 
    else 
    {
      // "from" and "to" quaternions are very close 
      //  ... so we can do a linear interpolation
      scale0 = 1.0f - t;
      scale1 = t;
    }
    
    // calculate final values
    q.w = scale0 * from.w + scale1 * to2.w;    
    q.x = scale0 * from.x + scale1 * to2.x;
    q.y = scale0 * from.y + scale1 * to2.y;
    q.z = scale0 * from.z + scale1 * to2.z;
    
    return q;
  }
  
  float[] getValue()
  {
    // transforming this quat into an angle and an axis vector...

    float[] res = new float[4];

    float sa = (float) Math.sqrt(1.0f - w * w);
    if (sa < 0.000001f)
    {
      sa = 1.0f;
    }

    res[0] = (float) Math.acos(w) * 2.0f;
    res[1] = x / sa;
    res[2] = y / sa;
    res[3] = z / sa;

    return res;
  }


  void debug()
  {  
    System.out.println( x + ", " + y + ", " + z + ", " + w );
  }    


  //
  // Members
  //
  float x, y, z, w;
};

