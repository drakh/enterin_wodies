// ****************************
// class ArcBall
// ****************************

//assuming IEEE-754(GLfloat), which i believe has max precision of 7 bits
static float Epsilon = 1.0e-5; 

class ArcBall
{
  ArcBall()
  {
    circlePointStart = new Vector3();
    circlePointEnd   = new Vector3();
    spherePointStart = new Vector3();
    spherePointEnd   = new Vector3();
    clickQuat        = new Quaternion();
    dragQuat         = new Quaternion();
    orientation      = new Quaternion();

    matrix           = new Matrix();
    matrix.identity();
  }
  
  Vector3 getPointSphere( float mx, float my )
  {
        Vector3 result = new Vector3();
        float radius = min(width - 100, height - 100) / 2.0f;
        Vector3 center = new Vector3( width / 2.0f, height / 2.0f, 0 );
        result.x = (mx - center.x) / radius;
        result.y = (my - center.y) / radius;

        float mag = result.x*result.x + result.y*result.y;
	if( mag > 1.0f )
	{
            println( "outside" );
            float isr = 1.0f / (float)Math.sqrt(mag);
	    result.x *= isr;
	    result.y *= isr;
	    result.z = 0.0f;
	}
	else
        {
            println( "inside" );
	    result.z = (float)Math.sqrt( 1.0f-mag);
        }

    //return (axis == -1) ? result : constrain_vector(v, axisSet[axis]);        
    return result;
  }
  
  Vector3 getPointSphere( Vector3 P )
  {
        // P ranges from [-1..1]
	float len = P.x*P.x + P.y*P.y;
        Vector3 result = new Vector3();

        result.x = P.x;
        result.y = P.y;
        result.z = P.z;

/*	if( len >= 1.0f )
	{	
            println( "outside" );
                float isr = 1.0f / (float)Math.sqrt(len);
		result.x *= isr;
		result.y *= isr;	
		result.z = 0.0f;
	}
	else*/
        {
//            println( "inside" );
		result.x = P.x;
		result.y = P.y;
		result.z = (float)Math.sqrt( 1.0f-len);  
        }

    return result;
  }

  Quaternion getQuat( Vector3 pStartPoint, Vector3 pEndPoint )
  {
      Quaternion  result = new Quaternion();
      Vector3     crossResult;
      float       dotResult;

	crossResult = Vector3.cross( pStartPoint, pEndPoint );
        float len = crossResult.length();
        if( len > Epsilon )
        {
          dotResult   = Vector3.dot( pStartPoint, pEndPoint ); //pStartPoint.x*pEndPoint.x + pStartPoint.y*pEndPoint.y + pStartPoint.z*pEndPoint.z;
  	  result.set( dotResult, crossResult );
        } 
        else
  	  result.set( 0, new Vector3(0, 0, 0) );
      
      return result;
  }

  void mousePressed()
  {
    // get startpoint in [-1..1] interval
    circlePointStart.x = (mouseX - 0.5*width) / (0.5*width);
    circlePointStart.y = -(mouseY - 0.5*height) / (0.5*height);
    spherePointStart = getPointSphere( circlePointStart );
    //spherePointStart = getPointSphere( mouseX, mouseY );
    clickQuat.set( orientation );
    dragQuat.setIdentity();
  }

  void mouseDragged()
  {
    // get endpoint in [-1..1] interval
    circlePointEnd.x = (mouseX - 0.5*width) / (0.5*width);
    circlePointEnd.y = -(mouseY - 0.5*height) / (0.5*height);
    spherePointEnd = getPointSphere( circlePointEnd );
    //spherePointEnd = getPointSphere( mouseX, mouseY );
    //dragQuat.set( Vector3.dot(spherePointStart, spherePointEnd), Vector3.cross(spherePointStart, spherePointEnd) );
    dragQuat = getQuat( spherePointStart, spherePointEnd );
  }
 
  void run()
  {
      orientation = Quaternion.mul( dragQuat, clickQuat );
      orientation.normalize();
      matrix = orientation.toRotationMatrix();
      //println( "x: " + orientation.x + " y: " + orientation.y + " z: " + orientation.z + " w: " + orientation.w );
  }
 

  //
  // Members
  //
  Vector3 circlePointStart, circlePointEnd;
  Vector3 spherePointStart, spherePointEnd;
  Quaternion clickQuat;
  Quaternion dragQuat;
  Quaternion orientation;
  Matrix matrix;
}
