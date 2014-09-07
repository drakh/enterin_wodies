class Vcamera
{
  Vcamera()
  {
    _rotationAngle = 0;
    _pos = new Vector3();
    _target = new Vector3();
    _up = new Vector3( 0, 1, 0 );
    _strafe = new Vector3();
  }

  Vcamera( float ex, float ey, float ez, float tx, float ty, float tz, float ux, float uy, float uz )
  {
    _rotationAngle = 0;
    _pos = new Vector3( ex, ey, ez );
    _target = new Vector3( tx, ty, tz );
    _up = new Vector3( ux, uy, uz );
    _strafe = new Vector3();
  }
  
  void move( float speed )
  {
    // get normalized direction vector
    Vector3 eyeDirection = Vector3.sub( _target, _pos );
    eyeDirection.normalize();
    
    updateCamera( eyeDirection, speed );
  }

  void lift( float speed )
  {
    Vector3 lift = new Vector3( 0, 1, 0 );
    
    updateCamera( lift, speed );
  }

  void strafe( float speed )
  {
    // compute view vector
    Vector3 view = Vector3.sub( _target, _pos );
    view.normalize();
    
    // get right vector
    _strafe = Vector3.cross( view, _up );
    _strafe.normalize();
    
    updateCamera( _strafe, speed );
  }  


  void updateCamera( Vector3 vdir, float speed )
  {
    // vdir is normalized
    Vector3 tmp = vdir.copy();
    tmp.mul( speed );
     
    _pos.add( tmp );
    _target.add( tmp );
  }


  //
  // Members
  //
  Vector3 _pos;
  Vector3 _target;
  Vector3 _up;
  Vector3 _strafe;
  float _rotationAngle;
}
