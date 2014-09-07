import javax.media.opengl.*; 
import java.nio.*; 

/*
void quad( GL gl, float s, float z, float a )
{  
  gl.glBegin( GL.GL_QUADS );
  gl.glNormal3f( 0.0f, 0.0f, 1.0f );
  gl.glColor4f( 1, 1, 1, a );
  gl.glTexCoord2f(0, 0);
  gl.glVertex3f( -1*s,  1*s, z );
  gl.glTexCoord2f(1, 0);
  gl.glVertex3f(  1*s,  1*s, z );
  gl.glTexCoord2f(1, 1);
  gl.glVertex3f(  1*s, -1*s, z );
  gl.glTexCoord2f(0, 1);
  gl.glVertex3f( -1*s, -1*s, z );
  gl.glEnd();   
}

void quad( GL gl, float s, float z, float ts, float a )
{  
  gl.glBegin( GL.GL_QUADS );
  gl.glNormal3f( 0.0f, 0.0f, 1.0f );
  gl.glColor4f( 1, 1, 1, a );
  gl.glTexCoord2f(0*ts, 0*ts);
  gl.glVertex3f( -1*s,  1*s, z );
  gl.glTexCoord2f(1*ts, 0*ts);
  gl.glVertex3f(  1*s,  1*s, z );
  gl.glTexCoord2f(1*ts, 1*ts);
  gl.glVertex3f(  1*s, -1*s, z );
  gl.glTexCoord2f(0*ts, 1*ts);
  gl.glVertex3f( -1*s, -1*s, z );
  gl.glEnd();   
}


void rect( GL gl, float sx, float sy, float z )
{  
  gl.glBegin( GL.GL_QUADS );
  gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
  gl.glColor4f( 1, 1, 1, 1 );
  gl.glTexCoord2f(0, 0); 
  gl.glVertex3f( -1*sx, -1*sy, z );
  gl.glTexCoord2f(1, 0); 
  gl.glVertex3f(  1*sx, -1*sy, z );
  gl.glTexCoord2f(1, 1); 
  gl.glVertex3f(  1*sx,  1*sy, z );
  gl.glTexCoord2f(0, 1); 
  gl.glVertex3f( -1*sx,  1*sy, z );
  gl.glEnd();   
}
*/

void box( float w, float h, float d )
{
   Vector3 pmin = new Vector3( -w,-h,-d );
   Vector3 pmax = new Vector3(  w, h, d );

   //xvvgl._gl.glColor4f(1.0, 1.0, 1.0, 0.75 );
   
   vgl._gl.glBegin( GL.GL_LINE_STRIP );
   vgl._gl.glVertex3f( pmin.x, pmin.y, pmin.z );
   vgl._gl.glVertex3f( pmax.x, pmin.y, pmin.z );
   vgl._gl.glVertex3f( pmax.x, pmin.y, pmax.z );
   vgl._gl.glVertex3f( pmin.x, pmin.y, pmax.z );
   vgl._gl.glVertex3f( pmin.x, pmin.y, pmin.z );
   vgl._gl.glVertex3f( pmin.x, pmax.y, pmin.z );
   vgl._gl.glVertex3f( pmax.x, pmax.y, pmin.z );
   vgl._gl.glVertex3f( pmax.x, pmax.y, pmax.z );
   vgl._gl.glVertex3f( pmin.x, pmax.y, pmax.z );
   vgl._gl.glVertex3f( pmin.x, pmax.y, pmin.z );
   vgl._gl.glEnd();
   vgl._gl.glBegin( GL.GL_LINES);
   vgl._gl.glVertex3f(pmax.x,pmin.y,pmin.z); vgl._gl.glVertex3f(pmax.x,pmax.y,pmin.z);
   vgl._gl.glEnd();
   vgl._gl.glBegin( GL.GL_LINES);
   vgl._gl.glVertex3f(pmax.x,pmin.y,pmax.z); vgl._gl.glVertex3f(pmax.x,pmax.y,pmax.z);
   vgl._gl.glEnd();
   vgl._gl.glBegin( GL.GL_LINES);
   vgl._gl.glVertex3f(pmin.x,pmin.y,pmax.z); vgl._gl.glVertex3f(pmin.x,pmax.y,pmax.z);
   vgl._gl.glEnd();
}


int sphereStacks = 120;
int sphereSlices = 120;
Vector3[] sphereSurface;
int[] sphereIndices;
Vector3[] sphereSurfaceUV;
Vector3[] sphereSurfaceNormal;
//Vector3[] sphereSurface2;
//Vector3[] sphereSurfaceNormal2;
void buildSphere( int stacks, int slices, float rad )
{
  Vector3 c = new Vector3( 0, 0, 0 );

  sphereStacks = stacks;
  sphereSlices = slices;
  
  int i, j;
  float radius = rad;
   
  Vector3 e = new Vector3();
  Vector3 p = new Vector3();

  int wid = slices;
  int len = (stacks+1)*(slices);
  sphereSurface = new Vector3[len];
  sphereSurfaceNormal = new Vector3[len];
  sphereSurfaceUV = new Vector3[len];
  
  for (j=0;j<len;j++)
  {
    sphereSurface[j] = new Vector3();
    sphereSurfaceNormal[j] = new Vector3();
    sphereSurfaceUV[j] = new Vector3();
  }


 //
 // compute sphere surface points
 //
 for( j=0; j<stacks+1; j++ )
 {
      for( i=0; i<slices; i++ )
      {
        float theta = j * PI / stacks;
	float phi = i * 2 * PI / slices;
	float sinTheta = sin(theta);
	float sinPhi = sin(phi);
	float cosTheta = cos(theta);
	float cosPhi = cos(phi);        

         float tmpi = (i) / float(slices);
         float tmpj = (j) / float(stacks);

         e.x = cosPhi * sinTheta;
         e.y = cosTheta;
         e.z = sinPhi * sinTheta;
         p.x = c.x + radius * e.x;
         p.y = c.y + radius * e.y;
         p.z = c.z + radius * e.z;

        int idx = j * wid + i;
        sphereSurface[idx].x = p.x;
        sphereSurface[idx].y = p.y;
        sphereSurface[idx].z = p.z;
        sphereSurfaceNormal[idx].x = e.x;
        sphereSurfaceNormal[idx].y = e.y;
        sphereSurfaceNormal[idx].z = e.z;
        sphereSurfaceUV[idx].x = tmpi; //4*(i/(float)n);
        sphereSurfaceUV[idx].y = tmpj; //4*2*((j+1)/(float)n);
      }
  }

  for( i=0; i<stacks+1; i++ )
  {
    sphereSurface[(i)*slices+slices-1].x = sphereSurface[(i)*slices+0].x;
    sphereSurface[(i)*slices+slices-1].y = sphereSurface[(i)*slices+0].y;
    sphereSurface[(i)*slices+slices-1].z = sphereSurface[(i)*slices+0].z;
  }
  
  sphereIndices = new int[len*2];
  int index = 0;
  for( j=0; j<stacks; j++ )
  {
    for( i=0; i<slices; i++ )
    {
      sphereIndices[index+0] = j*slices + (i%slices);
      sphereIndices[index+0] = (j+1)*slices + (i%slices);
    }
  }
}

void drawSphere( float x, float y, float z )
{
  int idx = 0;
  int idx2 = 0;
  for( int j=0; j<sphereStacks; j++ )
  {
    idx = j * (sphereSlices);
    idx2 = (j+1) * (sphereSlices);

    vgl._gl.glBegin( GL.GL_TRIANGLE_STRIP );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    for( int i=0; i<sphereSlices; i++ )
    {
      float x1 = sphereSurface[idx+i].x;// * r;
      float y1 = sphereSurface[idx+i].y;// * r;
      float z1 = sphereSurface[idx+i].z;// * r;
      float x2 = sphereSurface[idx2+i].x;// * r;
      float y2 = sphereSurface[idx2+i].y;// * r;
      float z2 = sphereSurface[idx2+i].z;// * r;

      float nx1 = sphereSurfaceNormal[idx+i].x;
      float ny1 = sphereSurfaceNormal[idx+i].y;
      float nz1 = sphereSurfaceNormal[idx+i].z;
      float nx2 = sphereSurfaceNormal[idx2+i].x;
      float ny2 = sphereSurfaceNormal[idx2+i].y;
      float nz2 = sphereSurfaceNormal[idx2+i].z;

      //      vgl._gl.glColor4f( x1*0.01, y1*0.01, z1*0.01, 1 ); //0.1*abs(sin(i+time*3)) );
//      vgl._gl.glColor4f( z2*0.01, z2*0.01, z2*0.01, freq2*100 ); //0.1*abs(sin(i+time*3)) );
      vgl._gl.glNormal3f( nx1, ny1, nz1 );
      vgl._gl.glVertex3f( x1, y1, z1 );

      //      vgl._gl.glColor4f( z2*0.01, z2*0.01, z2*0.01, 1 ); //0.1*abs(sin(i+time*3)) );
//      vgl._gl.glColor4f( x2*0.01, y2*0.01, z2*0.01, freq2*100 ); //0.1*abs(sin(i+time*3)) );
      vgl._gl.glNormal3f( nx2, ny2, nz2 );
      vgl._gl.glVertex3f( x2, y2, z2 );
    }
    vgl._gl.glEnd();
  }
}


void drawSphereTextured( float x, float y, float z )
{
  int idx = 0;
  int idx2 = 0;
  for( int j=0; j<sphereStacks; j++ )
  {
    idx = j * (sphereSlices);
    idx2 = (j+1) * (sphereSlices);

    vgl._gl.glBegin( GL.GL_TRIANGLE_STRIP );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    for( int i=0; i<sphereSlices; i++ )
    {
      float x1 = sphereSurface[idx+i].x;
      float y1 = sphereSurface[idx+i].y;
      float z1 = sphereSurface[idx+i].z;
      float x2 = sphereSurface[idx2+i].x;
      float y2 = sphereSurface[idx2+i].y;
      float z2 = sphereSurface[idx2+i].z;

      float nx1 = sphereSurfaceNormal[idx+i].x;
      float ny1 = sphereSurfaceNormal[idx+i].y;
      float nz1 = sphereSurfaceNormal[idx+i].z;
      float nx2 = sphereSurfaceNormal[idx2+i].x;
      float ny2 = sphereSurfaceNormal[idx2+i].y;
      float nz2 = sphereSurfaceNormal[idx2+i].z;

      //      vvgl._gl.glColor4f( x1*0.01, y1*0.01, z1*0.01, 1 ); //0.1*abs(sin(i+time*3)) );
//      vvgl._gl.glColor4f( z2*0.01, z2*0.01, z2*0.01, freq2*100 ); //0.1*abs(sin(i+time*3)) );
      vgl._gl.glNormal3f( nx1, ny1, nz1 );
      vgl._gl.glTexCoord2f( sphereSurfaceUV[idx+i].x, sphereSurfaceUV[idx+i].y );
      vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
      vgl._gl.glVertex3f( x1, y1, z1 );

      //      vvgl._gl.glColor4f( z2*0.01, z2*0.01, z2*0.01, 1 ); //0.1*abs(sin(i+time*3)) );
//      vgl._gl.glColor4f( x2*0.01, y2*0.01, z2*0.01, freq2*100 ); //0.1*abs(sin(i+time*3)) );
      vgl._gl.glNormal3f( nx2, ny2, nz2 );
      vgl._gl.glTexCoord2f( sphereSurfaceUV[idx2+i].x, sphereSurfaceUV[idx2+i].y );
      vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
      vgl._gl.glVertex3f( x2, y2, z2 );
    }
    vgl._gl.glEnd();
  }
}


/*void buildSphere( float rad )
{
  int i, j;
  int n = sphere_detail;
  float in = 1.0f / (float)n; 
  double t1, t2, t3;
  float r = rad;
   
  float PI = 3.141592653589793238462643;
  float PID2 = 1.570796326794896619231322;
   
  Vector3 e = new Vector3();
  Vector3 p = new Vector3();
  Vector3 c = new Vector3();

  int wid = n;
  int len = (n/2)*(n+1)*2;
  sphereSurface = new Vector3[len];
  sphereSurfaceNormal = new Vector3[len];
  sphereSurfaceUV = new Vector3[len];
  for (j=0;j<len;j++)
  {
    sphereSurface[j] = new Vector3();
    sphereSurfaceNormal[j] = new Vector3();
    sphereSurfaceUV[j] = new Vector3();
  }


  //
  // compute sphere surface points
  //
  for( j=0; j<n/2; j++ )
  {
//      t1 = -PID2 + j * PI * (in*0.5f); // / (n/2);
//      t2 = -PID2 + (j + 1) * PI * (in*0.5f); // / (n/2);
      t1 = j * 2 * PI / n - PID2;
      t2 = (j+1) * 2 * PI / n - PID2;

      for( i=0; i<n+1; i++ )
      {
         t3 = (i * 2 * PI) / n; //* in; // / n;

         float tmpi = (i) / float(n); //* in; // / n;
         float tmpj = (j) / float(n); //* in; // / n;
         float tmpj1 = (j+1) / float(n); //* in; // / n;
         println( tmpj );

         e.x = (float)Math.cos(t1) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t1);
         e.z = (float)Math.cos(t1) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
//         vvgl._gl.glNormal3f(e.x,e.y,e.z);
//         vvgl._gl.glTexCoord2f( 2*i*in, 2*j*in );
//         vvgl._gl.glVertex3f(p.x,p.y,p.z);
        sphereSurface[j*wid+i].x = p.x;
        sphereSurface[j*wid+i].y = p.y;
        sphereSurface[j*wid+i].z = p.z;
        sphereSurfaceNormal[j*wid+i].x = e.x;
        sphereSurfaceNormal[j*wid+i].y = e.y;
        sphereSurfaceNormal[j*wid+i].z = e.z;
        sphereSurfaceUV[j*wid+i].x = 4*(i/(float)n);//*in;
        sphereSurfaceUV[j*wid+i].y = 4*2*((j+1)/(float)n);//*in;

         e.x = (float)Math.cos(t2) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t2);
         e.z = (float)Math.cos(t2) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
//         vvgl._gl.glNormal3f(e.x,e.y,e.z);
//         vvgl._gl.glTexCoord2f( 2*i*in, 2*(j+1)*in );
//         vvgl._gl.glVertex3f(p.x,p.y,p.z);
        sphereSurface[j*wid+i].x = p.x;
        sphereSurface[j*wid+i].y = p.y;
        sphereSurface[j*wid+i].z = p.z;
        sphereSurfaceNormal[j*wid+i].x = e.x;
        sphereSurfaceNormal[j*wid+i].y = e.y;
        sphereSurfaceNormal[j*wid+i].z = e.z;
        sphereSurfaceUV[j*wid+i].x = 4*(i/(float)n);//*in;
        sphereSurfaceUV[j*wid+i].y = 4*2*(j/(float)n);//*in;
      }
   }
}*/

void sphere( float rad, int detail, boolean doFill )
{
  int i, j;
  int n = detail;
  float in = 1.0f / (float)n; 
  double t1, t2, t3;
  float r = rad;
   
  float PI = 3.141592653589793238462643;
  float PID2 = 1.570796326794896619231322;
   
  Vector3 e = new Vector3();
  Vector3 p = new Vector3();
  Vector3 c = new Vector3();

  if( !doFill )
    vgl._gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_LINE );
    
  for (j=0;j<n*2;j++) 
  {
      t1 = -PID2 + j * PI * (in*0.5f); // / (n/2);
      t2 = -PID2 + (j + 1) * PI * (in*0.5f); // / (n/2);

      vgl._gl.glBegin( GL.GL_QUAD_STRIP);
      vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
      for (i=0;i<=n;i++) 
      {
         t3 = i * PI *  2 * in; // / n;

         e.x = (float)Math.cos(t1) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t1);
         e.z = (float)Math.cos(t1) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
         vgl._gl.glNormal3f(e.x,e.y,e.z);
         vgl._gl.glVertex3f(p.x,p.y,p.z);

         e.x = (float)Math.cos(t2) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t2);
         e.z = (float)Math.cos(t2) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
         vgl._gl.glNormal3f(e.x,e.y,e.z);
         vgl._gl.glVertex3f(p.x,p.y,p.z);

      }
      vgl._gl.glEnd();
   }
  if( !doFill )
   vgl._gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
}

void sphereTextured( float rad, int detail, boolean doFill )
{
  int i, j;
  int n = detail;
  float in = 1.0f / (float)n; 
  double t1, t2, t3;
  float r = rad;
   
  float PI = 3.141592653589793238462643;
  float PID2 = 1.570796326794896619231322;
   
  Vector3 e = new Vector3();
  Vector3 p = new Vector3();
  Vector3 c = new Vector3();

  if( !doFill )
    vgl._gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_LINE );
    
  for (j=0;j<n*2;j++) 
  {
      t1 = -PID2 + j * PI * (in*0.5f); // / (n/2);
      t2 = -PID2 + (j + 1) * PI * (in*0.5f); // / (n/2);

      vgl._gl.glBegin( GL.GL_QUAD_STRIP);
      vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
      for (i=0;i<=n;i++) 
      {
         t3 = i * PI *  2 * in; // / n;

         e.x = (float)Math.cos(t1) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t1);
         e.z = (float)Math.cos(t1) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
         vgl._gl.glNormal3f(e.x,e.y,e.z);
         vgl._gl.glTexCoord2f( 4*i*in, 4*j*in );
         vgl._gl.glVertex3f(p.x,p.y,p.z);

         e.x = (float)Math.cos(t2) * (float)Math.cos(t3);
         e.y = (float)Math.sin(t2);
         e.z = (float)Math.cos(t2) * (float)Math.sin(t3);
         p.x = c.x + r * e.x;
         p.y = c.y + r * e.y;
         p.z = c.z + r * e.z;
         vgl._gl.glNormal3f(e.x,e.y,e.z);
         vgl._gl.glTexCoord2f( 4*i*in, 4*(j+1)*in );
         vgl._gl.glVertex3f(p.x,p.y,p.z);

      }
      vgl._gl.glEnd();
   }
  if( !doFill )
   vgl._gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
}


//
// Setup a simple light
// creds to objloader dude
//
void setupPointLight( Vector3 pos )
{
  GL g = vgl._gl;

  float[] light_emissive = { 0.0f, 0.0f, 0.0f, 1 };
  float[] light_ambient = { 0.01f, 0.01f, 0.01f, 0 };
  float[] light_diffuse = { 1.0f, 1.0f, 1.0f, 1.0f };
  float[] light_specular = { 1.0f, 1.0f, 1.0f, 1.0f };  
  float[] mat_shininess = { 32 };

  float[] light_position = { pos.x, pos.y, pos.z, 1.0f };  

  FloatBuffer fb;

  fb = FloatBuffer.wrap( light_ambient );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_AMBIENT, fb );
  fb = FloatBuffer.wrap( light_diffuse );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_DIFFUSE, fb );
  fb = FloatBuffer.wrap( light_specular );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_SPECULAR, fb );
//  fb = FloatBuffer.wrap( mat_shininess );
//  g.glLightfv( GL.GL_LIGHT1, GL.GL_SHININESS, fb );

  fb = FloatBuffer.wrap( light_position );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_POSITION, fb );  

  g.glEnable( GL.GL_LIGHT1 );
  g.glEnable( GL.GL_LIGHTING );


  g.glEnable( GL.GL_COLOR_MATERIAL );
  fb = FloatBuffer.wrap( light_emissive );
  g.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, fb );
  fb = FloatBuffer.wrap( light_diffuse );
  g.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, fb );
  fb = FloatBuffer.wrap( mat_shininess );
  g.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, fb );
  fb = FloatBuffer.wrap( light_specular );
  g.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, fb );
  
}  



//
// Build a cube. FIXME!
//
Cubic cube;
void buildCube( float size )
{
  cube = new Cubic();
  cube.resize( size );
}

class Cubic
{
  Cubic()
  {
          _V = new Vector3[8];
          
          _V[0] = new Vector3( -1.0, 1.0, 1.0 );
          _V[1] = new Vector3(  1.0, 1.0, 1.0 );
          _V[2] = new Vector3(  1.0, -1.0, 1.0 );
          _V[3] = new Vector3(  -1.0, -1.0, 1.0 );
          _V[4] = new Vector3( -1.0, 1.0, -1.0 );
          _V[5] = new Vector3(  1.0, 1.0, -1.0 );
          _V[6] = new Vector3(  1.0, -1.0, -1.0 );
          _V[7] = new Vector3(  -1.0, -1.0, -1.0 );
  }

  void draw()
  {
    // front
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[0].x, _V[0].y, _V[0].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[1].x, _V[1].y, _V[1].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[2].x, _V[2].y, _V[2].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[3].x, _V[3].y, _V[3].z );
    vgl._gl.glEnd();
    
    // back
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( 0.0f, 0.0f, -1.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[4].x, _V[4].y, _V[4].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, -1.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[5].x, _V[5].y, _V[5].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, -1.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[6].x, _V[6].y, _V[6].z );
    vgl._gl.glNormal3f( 0.0f, 0.0f, -1.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[7].x, _V[7].y, _V[7].z );
    vgl._gl.glEnd();
  
  
    // right
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( 1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[4].x, _V[4].y, _V[4].z );
    vgl._gl.glNormal3f( 1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[0].x, _V[0].y, _V[0].z );
    vgl._gl.glNormal3f( 1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[3].x, _V[3].y, _V[3].z );
    vgl._gl.glNormal3f( 1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[7].x, _V[7].y, _V[7].z );
    vgl._gl.glEnd();
/*  
    // left
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( -1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[1].x, _V[1].y, _V[1].z );
    vgl._gl.glNormal3f( -1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[5].x, _V[5].y, _V[4].z );
    vgl._gl.glNormal3f( -1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[6].x, _V[6].y, _V[6].z );
    vgl._gl.glNormal3f( -1.0f, 0.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[2].x, _V[2].y, _V[2].z );
    vgl._gl.glEnd();
  	
    // top
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( 0.0f, -1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[0].x, _V[0].y, _V[0].z );
    vgl._gl.glNormal3f( 0.0f, -1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[1].x, _V[1].y, _V[1].z );
    vgl._gl.glNormal3f( 0.0f, -1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[5].x, _V[5].y, _V[5].z );
    vgl._gl.glNormal3f( 0.0f, -1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[4].x, _V[4].y, _V[4].z );
    vgl._gl.glEnd();
  
    // top
    vgl._gl.glBegin( GL.GL_QUADS );
    vgl._gl.glColor4f( vgl._r, vgl._g, vgl._b, vgl._a );
    vgl._gl.glNormal3f( 0.0f, 1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 0); vgl._gl.glVertex3f( _V[7].x, _V[7].y, _V[7].z );
    vgl._gl.glNormal3f( 0.0f, 1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 0); vgl._gl.glVertex3f( _V[6].x, _V[6].y, _V[6].z );
    vgl._gl.glNormal3f( 0.0f, 1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(1, 1); vgl._gl.glVertex3f( _V[2].x, _V[2].y, _V[2].z );
    vgl._gl.glNormal3f( 0.0f, 1.0f, 0.0f ); 
    vgl._gl.glTexCoord2f(0, 1); vgl._gl.glVertex3f( _V[3].x, _V[3].y, _V[3].z );
    vgl._gl.glEnd();*/
  }
        
  void resize( float s )
  {
    for( int i=0; i<_V.length; i++ )
    {
      _V[i].mul( s * -1 );
    }
  }

  void offset( float x, float y, float z )
  {
    for( int i=0; i<_V.length; i++ )
    {
      _V[i].add( x, y, z );
    }
  }       
        
  Vector3[]  _V;
  Vector3 _Pos;
};

