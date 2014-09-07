import processing.*;
import java.nio.*; 

class Matrix
{
  Matrix()
  {
    _M = new float[16];
    identity();
  };

  Matrix( Matrix m )
  {
    copy( m );
  };

  public void copy( Matrix m )
  {
      _M[0] = m._M[0]; _M[4] = m._M[4]; _M[8] = m._M[8]; _M[12] = m._M[12];
      _M[1] = m._M[1]; _M[5] = m._M[5]; _M[9] = m._M[9]; _M[13] = m._M[13];
      _M[2] = m._M[2]; _M[6] = m._M[6]; _M[10] = m._M[10]; _M[14] = m._M[14];
      _M[3] = m._M[3]; _M[7] = m._M[7]; _M[11] = m._M[11]; _M[15] = m._M[15];
  }
  
  public Matrix copy()
  {
      Matrix m = new Matrix();
      m.copy( this );
      /*_M[0] = m._M[0]; _M[4] = m._M[4]; _M[8] = m._M[8]; _M[12] = m._M[12];
      _M[1] = m._M[1]; _M[5] = m._M[5]; _M[9] = m._M[9]; _M[13] = m._M[13];
      _M[2] = m._M[2]; _M[6] = m._M[6]; _M[10] = m._M[10]; _M[14] = m._M[14];
      _M[3] = m._M[3]; _M[7] = m._M[7]; _M[11] = m._M[11]; _M[15] = m._M[15];*/
      
      return m;
  }
  
  public FloatBuffer getFloatBuffer()
  {
    FloatBuffer fb = FloatBuffer.wrap( _M );
    return fb;
  }
  
  public void identity()
  {
      _M[0] = 1; _M[4] = 0; _M[8] = 0; _M[12] = 0;
      _M[1] = 0; _M[5] = 1; _M[9] = 0; _M[13] = 0;
      _M[2] = 0; _M[6] = 0; _M[10] = 1; _M[14] = 0;
      _M[3] = 0; _M[7] = 0; _M[11] = 0; _M[15] = 1;
  }

  public void scale( float s )
  {
      _M[0] *= s; _M[4] = 0; _M[8] = 0;   _M[12] = 0;
      _M[1] = 0; _M[5] *= s; _M[9] = 0;   _M[13] = 0;
      _M[2] = 0; _M[6] = 0;  _M[10] *= s; _M[14] = 0;
      _M[3] = 0; _M[7] = 0;  _M[11] = 0;  _M[15] = 1;
  }

  /*Matrix translate( float X, float Y, float Z )
  {
    Matrix m = new Matrix();
    m.identity();
    m._M[12] = X;
    m._M[13] = Y;
    m._M[14] = Z;
    return m;
  }*/

  void translate( float X, float Y, float Z )
  {
    _M[12] = X;
    _M[13] = Y;
    _M[14] = Z;
    _M[15] = 1.0f;
  }


  public void rotateX( float a )
  {
      // Takes radians for angles

      //identity();
      
      float ca = (float)Math.cos( a );
      float sa = (float)Math.sin( a );
      
      _M[0] = 1; _M[4] = 0;   _M[8] = 0;   _M[12] = 0;
      _M[1] = 0; _M[5] = ca;  _M[9] = sa;  _M[13] = 0;
      _M[2] = 0; _M[6] = -sa; _M[10] = ca; _M[14] = 0;
      _M[3] = 0; _M[7] = 0;   _M[11] = 0;  _M[15] = 1;
  }

  public void rotateY( float a )
  {
      // Takes radians for angles

      //identity();
      
      float ca = (float)Math.cos( a );
      float sa = (float)Math.sin( a );
      
      _M[0] = ca; _M[4] = 0; _M[8] = sa; _M[12] = 0;
      _M[1] = 0;  _M[5] = 1; _M[9] = 0;   _M[13] = 0;
      _M[2] = -sa; _M[6] = 0; _M[10] = ca; _M[14] = 0;
      _M[3] = 0;  _M[7] = 0; _M[11] = 0;  _M[15] = 1;
  }

  public void rotateZ( float a )
  {
      // Takes radians for angles
      
      //identity();
      
      float ca = (float)Math.cos( a );
      float sa = (float)Math.sin( a );
      
      _M[0] = ca;  _M[4] = -sa; _M[8] = 0;  _M[12] = 0;
      _M[1] = sa;  _M[5] = ca;  _M[9] = 0;  _M[13] = 0;
      _M[2] = 0;   _M[6] = 0;   _M[10] = 0; _M[14] = 0;
      _M[3] = 0;   _M[7] = 0;   _M[11] = 0; _M[15] = 1;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////
  // compute matrix based on 3 axis angles
  //////////////////////////////////////////////////////////////////////////////////////////////
  Matrix rotate( float Yaw, float Pitch, float Roll )
  {
      // Takes radians for angles
    
      Matrix m = new Matrix();
      float sinY, cosY, sinP, cosP, sinR, cosR;
      float ux, uy, uz, vx, vy, vz, nx, ny, nz;
  
      sinY = (float)Math.sin(Yaw);
      cosY = (float)Math.cos(Yaw);

      sinP = (float)Math.sin(Pitch);
      cosP = (float)Math.cos(Pitch);

      sinR = (float)Math.sin(Roll);
      cosR = (float)Math.cos(Roll);

      ux = cosY * cosR + sinY * sinP * sinR;
      uy = sinR * cosP;
      uz = cosY * sinP * sinR - sinY * cosR;

      vx = sinY * sinP * cosR - cosY * sinR;
      vy = cosR * cosP;
      vz = sinR * sinY + cosR * cosY * sinP;

      nx = cosP * sinY;
      ny = -sinP;
      nz = cosP * cosY;

      m._M[0] =   ux; m._M[1] =   uy; m._M[2] =   uz; m._M[3] = 0.0f; 
      m._M[4] =   vx; m._M[5] =   vy; m._M[6] =   vz; m._M[7] = 0.0f; 
      m._M[8] =   nx; m._M[9] =   ny; m._M[10] =  nz; m._M[11] = 0.0f; 
      m._M[12] = 0.0f; m._M[13] = 0.0f; m._M[14] = 0.0f; m._M[15] = 1.0f; 

      return m;
  }
  
  public void add( Matrix m )
  {
      _M[0] += m._M[0]; _M[4] += m._M[1]; _M[8] += m._M[2]; _M[12] += m._M[3];
      _M[1] += m._M[4]; _M[5] += m._M[5]; _M[9] += m._M[6]; _M[13] += m._M[7];
      _M[2] += m._M[8]; _M[6] += m._M[9]; _M[10] += m._M[10]; _M[14] += m._M[11];
      _M[3] += m._M[12]; _M[7] += m._M[13]; _M[11] += m._M[14]; _M[15] += m._M[15];
  }


  //////////////////////////////////////////////////////////////////////////////////////////////
  // row for column concatenation
  //////////////////////////////////////////////////////////////////////////////////////////////
  Matrix mul( Matrix m )
  {
    Matrix mat = new Matrix();

    mat._M[0] = _M[0] * m._M[0] + _M[4] * m._M[1] + _M[8] * m._M[2] +  _M[12] * m._M[3];
    mat._M[1] = _M[0] * m._M[4] + _M[4] * m._M[5] + _M[8] * m._M[6] +  _M[12] * m._M[7];
    mat._M[2] = _M[0] * m._M[8] + _M[4] * m._M[9] + _M[8] * m._M[10] + _M[12] * m._M[11];
    mat._M[3] = _M[0] * m._M[12] + _M[4] * m._M[13] + _M[8] * m._M[15] + _M[12] * m._M[15];

    mat._M[4] = _M[1] * m._M[0] + _M[5] * m._M[1] + _M[9] * m._M[2] +  _M[13] * m._M[3];
    mat._M[5] = _M[1] * m._M[4] + _M[5] * m._M[5] + _M[9] * m._M[6] +  _M[13] * m._M[7];
    mat._M[6] = _M[1] * m._M[8] + _M[5] * m._M[9] + _M[9] * m._M[10] + _M[13] * m._M[11];
    mat._M[7] = _M[1] * m._M[12] + _M[5] * m._M[13] + _M[9] * m._M[15] + _M[13] * m._M[15];

    mat._M[8] = _M[2] * m._M[0] + _M[6] * m._M[1] + _M[10] * m._M[2] +  _M[14] * m._M[3];
    mat._M[9] = _M[2] * m._M[4] + _M[6] * m._M[5] + _M[10] * m._M[6] +  _M[14] * m._M[7];
    mat._M[10] = _M[2] * m._M[8] + _M[6] * m._M[9] + _M[10] * m._M[10] + _M[14] * m._M[11];
    mat._M[11] = _M[2] * m._M[12] + _M[6] * m._M[13] + _M[10] * m._M[15] + _M[14] * m._M[15];

    mat._M[12] = _M[3] * m._M[0] + _M[7] * m._M[1] + _M[11] * m._M[2] +  _M[15] * m._M[3];
    mat._M[13] = _M[3] * m._M[4] + _M[7] * m._M[5] + _M[11] * m._M[6] +  _M[15] * m._M[7];
    mat._M[14] = _M[3] * m._M[8] + _M[7] * m._M[9] + _M[11] * m._M[10] + _M[15] * m._M[11];
    mat._M[15] = _M[3] * m._M[12] + _M[7] * m._M[13] + _M[11] * m._M[15] + _M[15] * m._M[15];

/*
    mat._M[0] = _M[0] * m._M[0] + _M[4] * m._M[1] + _M[8] * m._M[2] +  _M[12] * m._M[3];
    mat._M[4] = _M[0] * m._M[4] + _M[4] * m._M[5] + _M[8] * m._M[6] +  _M[12] * m._M[7];
    mat._M[8] = _M[0] * m._M[8] + _M[4] * m._M[9] + _M[8] * m._M[10] + _M[12] * m._M[11];
    mat._M[12] = _M[0] * m._M[12] + _M[4] * m._M[13] + _M[8] * m._M[15] + _M[12] * m._M[15];

    mat._M[1] = _M[1] * m._M[0] + _M[5] * m._M[1] + _M[9] * m._M[2] +  _M[13] * m._M[3];
    mat._M[5] = _M[1] * m._M[4] + _M[5] * m._M[5] + _M[9] * m._M[6] +  _M[13] * m._M[7];
    mat._M[9] = _M[1] * m._M[8] + _M[5] * m._M[9] + _M[9] * m._M[10] + _M[13] * m._M[11];
    mat._M[13] = _M[1] * m._M[12] + _M[5] * m._M[13] + _M[9] * m._M[15] + _M[13] * m._M[15];

    mat._M[2] = _M[2] * m._M[0] + _M[6] * m._M[1] + _M[10] * m._M[2] +  _M[14] * m._M[3];
    mat._M[6] = _M[2] * m._M[4] + _M[6] * m._M[5] + _M[10] * m._M[6] +  _M[14] * m._M[7];
    mat._M[10] = _M[2] * m._M[8] + _M[6] * m._M[9] + _M[10] * m._M[10] + _M[14] * m._M[11];
    mat._M[14] = _M[2] * m._M[12] + _M[6] * m._M[13] + _M[10] * m._M[15] + _M[14] * m._M[15];

    mat._M[3] = _M[3] * m._M[0] + _M[7] * m._M[1] + _M[11] * m._M[2] +  _M[15] * m._M[3];
    mat._M[7] = _M[3] * m._M[4] + _M[7] * m._M[5] + _M[11] * m._M[6] +  _M[15] * m._M[7];
    mat._M[11] = _M[3] * m._M[8] + _M[7] * m._M[9] + _M[11] * m._M[10] + _M[15] * m._M[11];
    mat._M[15] = _M[3] * m._M[12] + _M[7] * m._M[13] + _M[11] * m._M[15] + _M[15] * m._M[15];
*/
    return mat;
  }


  //////////////////////////////////////////////////////////////////////////////////////////////
  // column for row concatenation
  //////////////////////////////////////////////////////////////////////////////////////////////
  Matrix mul2( Matrix m )
  {
    Matrix mat = new Matrix();
    
    mat._M[0] = _M[0] * m._M[0] + _M[1] * m._M[4] + _M[2] * m._M[8] +  _M[3] * m._M[12];
    mat._M[1] = _M[0] * m._M[1] + _M[1] * m._M[5] + _M[2] * m._M[9] +  _M[3] * m._M[13];
    mat._M[2] = _M[0] * m._M[2] + _M[1] * m._M[6] + _M[2] * m._M[10] + _M[3] * m._M[14];
    mat._M[3] = _M[0] * m._M[3] + _M[1] * m._M[7] + _M[2] * m._M[11] + _M[3] * m._M[15];

    mat._M[4] = _M[4] * m._M[0] + _M[5] * m._M[4] + _M[6] * m._M[8] +  _M[7] * m._M[12];
    mat._M[5] = _M[4] * m._M[1] + _M[5] * m._M[5] + _M[6] * m._M[9] +  _M[7] * m._M[13];
    mat._M[6] = _M[4] * m._M[2] + _M[5] * m._M[6] + _M[6] * m._M[10] + _M[7] * m._M[14];
    mat._M[7] = _M[4] * m._M[3] + _M[5] * m._M[7] + _M[6] * m._M[11] + _M[7] * m._M[15];

    mat._M[8 ] = _M[8] * m._M[0] + _M[9] * m._M[4] + _M[10] * m._M[8] +  _M[11] * m._M[12];
    mat._M[9 ] = _M[8] * m._M[1] + _M[9] * m._M[5] + _M[10] * m._M[9] +  _M[11] * m._M[13];
    mat._M[10] = _M[8] * m._M[2] + _M[9] * m._M[6] + _M[10] * m._M[10] + _M[11] * m._M[14];
    mat._M[11] = _M[8] * m._M[3] + _M[9] * m._M[7] + _M[10] * m._M[11] + _M[11] * m._M[15];

    mat._M[12] = _M[12] * m._M[0] + _M[13] * m._M[4] + _M[14] * m._M[8] +  _M[15] * m._M[12];
    mat._M[13] = _M[12] * m._M[1] + _M[13] * m._M[5] + _M[14] * m._M[9] +  _M[15] * m._M[13];
    mat._M[14] = _M[12] * m._M[2] + _M[13] * m._M[6] + _M[14] * m._M[10] + _M[15] * m._M[14];
    mat._M[15] = _M[12] * m._M[3] + _M[13] * m._M[7] + _M[14] * m._M[11] + _M[15] * m._M[15];
    
    return mat;
  }

  public void mul( float s )
  {
      _M[0] *= s; _M[4] *= s; _M[8] *= s;  _M[12] *= s;
      _M[1] *= s; _M[5] *= s; _M[9] *= s;  _M[13] *= s;
      _M[2] *= s; _M[6] *= s; _M[10] *= s; _M[14] *= s;
      _M[3] *= s; _M[7] *= s; _M[11] *= s; _M[15] *= s;
  }


  public void transpose()
  {
      Matrix m = new Matrix();
      m.copy( this );
      _M[0] = m._M[0]; _M[4] = m._M[1]; _M[8] = m._M[2]; _M[12] = m._M[3];
      _M[1] = m._M[4]; _M[5] = m._M[5]; _M[9] = m._M[6]; _M[13] = m._M[7];
      _M[2] = m._M[8]; _M[6] = m._M[9]; _M[10] = m._M[10]; _M[14] = m._M[11];
      _M[3] = m._M[12]; _M[7] = m._M[13]; _M[11] = m._M[14]; _M[15] = m._M[15];
  }

  /* Build a row-major (C-style) 4x4 matrix transform based on the
     parameters for gluLookAt. */
  void buildViewMatrix( float eyex, float eyey, float eyez,
                          float centerx, float centery, float centerz,
                          float upx, float upy, float upz )
  {
    Vector3 x, y, z;
    float mag;
    
    x = new Vector3();
    y = new Vector3();
    z = new Vector3();
    
    Vector3 eye = new Vector3( eyex, eyey, eyez );
    Vector3 target = new Vector3( centerx, centery, centerz );
  
    /* Difference eye and center vectors to make Z vector. */
    z = Vector3.sub( target, eye );
    z.normalize();
      
    /* Up vector makes Y vector. */
    y.set( upx, upy, upz );
  
    /* X vector = Y cross Z. */
    x = Vector3.cross( z, y );
  
    /* Recompute Y = Z cross X. */
    y = Vector3.cross( z, x );
  
    x.normalize();
    y.normalize();  
  
    /* Build resulting view matrix. */
    _M[0*4+0] = x.x;  
    _M[0*4+1] = x.y;
    _M[0*4+2] = x.z;  
    _M[0*4+3] = -x.x*eyex + -x.y*eyey + -x.z*eyez;
  
    _M[1*4+0] = y.x;
    _M[1*4+1] = y.y;
    _M[1*4+2] = y.z;
    _M[1*4+3] = -y.x*eyex + -y.y*eyey + -y.z*eyez;
  
    _M[2*4+0] = z.x;
    _M[2*4+1] = z.y;
    _M[2*4+2] = z.z;
    _M[2*4+3] = -z.x*eyex + -z.y*eyey + -z.z*eyez;
  
    _M[3*4+0] = 0.0f;
    _M[3*4+1] = 0.0f;  
    _M[3*4+2] = 0.0f;  
    _M[3*4+3] = 1.0f;
  }

  void buildPerspectiveMatrix( float fieldOfView, float aspectRatio, float zNear, float zFar )
  {
    float sine, cotangent, deltaZ;
    float radians = fieldOfView / 2 * (float)(Math.PI / 180.0f);
    
    deltaZ = zFar - zNear;
    sine = (float)Math.sin(radians);
    /* Should be non-zero to avoid division by zero. */
//    assert(deltaZ);
//    assert(sine);
//    assert(aspectRatio);
    cotangent = (float)Math.cos(radians) / sine;
  
    /* First row */
    _M[0*4+0] = (float) (cotangent / aspectRatio);
    _M[0*4+1] = 0.0f;
    _M[0*4+2] = 0.0f;
    _M[0*4+3] = 0.0f;
    
    /* Second row */
    _M[1*4+0] = 0.0f;
    _M[1*4+1] = (float) cotangent;
    _M[1*4+2] = 0.0f;
    _M[1*4+3] = 0.0f;
    
    /* Third row */
    _M[2*4+0] = 0.0f;
    _M[2*4+1] = 0.0f;
    _M[2*4+2] = (float) (-(zFar + zNear) / deltaZ);
    _M[2*4+3] = (float) (-2 * zNear * zFar / deltaZ);
    
    /* Fourth row */
    _M[3*4+0] = 0.0f;
    _M[3*4+1] = 0.0f;
    _M[3*4+2] = -1.0f;
    _M[3*4+3] = 0.0f;
  }

  void buildRotateMatrix(float angle, float ax, float ay, float az )
  {
    // Row-major rotation matrix
    float radians, sine, cosine, ab, bc, ca, tx, ty, tz;
    float mag;

    Vector3 axis = new Vector3( ax, ay, az );
    axis.normalize();
  
    radians = angle * (float)Math.PI / 180.0f;
    sine = (float)Math.sin(radians);
    cosine = (float)Math.cos(radians);
    ab = axis.x * axis.y * (1 - cosine);
    bc = axis.y * axis.z * (1 - cosine);
    ca = axis.z * axis.x * (1 - cosine);
    tx = axis.x * axis.x;
    ty = axis.y * axis.y;
    tz = axis.z * axis.z;
  
    _M[0]  = tx + cosine * (1 - tx);
    _M[1]  = ab + axis.z * sine;
    _M[2]  = ca - axis.y * sine;
    _M[3]  = 0.0f;
    _M[4]  = ab - axis.z * sine;
    _M[5]  = ty + cosine * (1 - ty);
    _M[6]  = bc + axis.x * sine;
    _M[7]  = 0.0f;
    _M[8]  = ca + axis.y * sine;
    _M[9]  = bc - axis.x * sine;
    _M[10] = tz + cosine * (1 - tz);
    _M[11] = 0;
    _M[12] = 0;
    _M[13] = 0;
    _M[14] = 0;
    _M[15] = 1;
  }


  public Vector3 transform( Vector3 v )
  {
      float xx = ( v.x*_M[0] + v.y*_M[4] + v.z*_M[8] + _M[12] );
      float yy = ( v.x*_M[1] + v.y*_M[5] + v.z*_M[9] + _M[13] );
      float zz = ( v.x*_M[2] + v.y*_M[6] + v.z*_M[10] + _M[14] );

      return new Vector3( xx, yy, zz );
  }

  public void debug()
  {
    System.out.println( "[0] = " + _M[ 0] + ", " + _M[ 1] + ", " + _M[ 2] + ", " + _M[ 3] );
    System.out.println( "[1] = " + _M[ 4] + ", " + _M[ 5] + ", " + _M[ 6] + ", " + _M[ 7] );
    System.out.println( "[2] = " + _M[ 8] + ", " + _M[ 9] + ", " + _M[10] + ", " + _M[11] );
    System.out.println( "[3] = " + _M[12] + ", " + _M[13] + ", " + _M[14] + ", " + _M[15] );
  }
  
  public static Vector3 transform( Vector3 v, float[] m )
  {
      float xx = ( v.x*m[0] + v.y*m[4] + v.z*m[8] + m[12] );
      float yy = ( v.x*m[1] + v.y*m[5] + v.z*m[9] + m[13] );
      float zz = ( v.x*m[2] + v.y*m[6] + v.z*m[10] + m[14] );
        
      return new Vector3( xx, yy, zz );
  }


  public static Matrix transpose( Matrix m )
  {
      Matrix rm = new Matrix();
      //Matrix m = new Matrix();
      //m.copy( this );
      rm._M[0] = m._M[0];  rm._M[4] = m._M[1];  rm._M[8] = m._M[2];   rm._M[12] = m._M[3];
      rm._M[1] = m._M[4];  rm._M[5] = m._M[5];  rm._M[9] = m._M[6];   rm._M[13] = m._M[7];
      rm._M[2] = m._M[8];  rm._M[6] = m._M[9];  rm._M[10] = m._M[10]; rm._M[14] = m._M[11];
      rm._M[3] = m._M[12]; rm._M[7] = m._M[13]; rm._M[11] = m._M[14]; rm._M[15] = m._M[15];
      
      return rm;
  }
  
  
  public static Matrix mul( Matrix m1, Matrix m2 )
  {
    Matrix tmp = new Matrix();
    int i, j;

    for (i=0; i<4; i++) 
    {
      for (j=0; j<4; j++) 
      {
        tmp._M[i*4+j] = m1._M[i*4+0] * m2._M[0*4+j] +
                       m1._M[i*4+1] * m2._M[1*4+j] +
                       m1._M[i*4+2] * m2._M[2*4+j] +
                       m1._M[i*4+3] * m2._M[3*4+j];
      }
    }
    
    return tmp;
  }


  float[] _M;
};
