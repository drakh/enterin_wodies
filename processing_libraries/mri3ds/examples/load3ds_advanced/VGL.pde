import processing.opengl.*;
import java.nio.*; 
import java.util.*;
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import com.sun.opengl.util.texture.*;  


VGL vgl;
/*GL getGL()
{
  return vgl._gl;
}*/

///////////////////////////////
// VGL class
///////////////////////////////

class VGL
{
  VGL( PApplet parent )
  {
    _parent = parent;
    
    _pgl = (PGraphicsOpenGL) g;
    _gl = _pgl.gl;
    _glu = (((PGraphicsOpenGL) g).glu);
    
    _uScale = 1;
    _vScale = 1;
    
    _uOffset = 0;
    _vOffset = 0; 
    
    _r = 1;
    _g = 1;
    _b = 1;
    _a = 1;
  }
  
  GL gl()
  {
    return _gl;
  }

  void begin()
  {
    _glu = (((PGraphicsOpenGL) g).glu);
    _gl = ((PGraphicsOpenGL)g).beginGL();
  }

  void end()
  {
    ((PGraphicsOpenGL)g).endGL(); 
  }

  void background( float c )
  {
    _gl.glClearColor( c, c, c, 1 );
    _gl.glClear( GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT );// | GL.GL_ACCUM_BUFFER_BIT );
  }

  void background( float r, float g, float b, float a )
  {
    _gl.glClearColor( r, g, b, a );
    _gl.glClear( GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT );
  }

  void ortho( float left, float right, float top, float bottom, float near, float far )
  {
    _gl.glMatrixMode( GL.GL_PROJECTION );
    _gl.glLoadIdentity();    
    _gl.glOrtho( left, right, bottom, top, near, far );
    _gl.glMatrixMode( GL.GL_MODELVIEW );
    _gl.glLoadIdentity();    
  }

  // create ortho mode.
  // ranges from [-1..1]
  void ortho()
  {
    _gl.glMatrixMode( GL.GL_PROJECTION );
    _gl.glLoadIdentity();    
    _gl.glOrtho( -1, 1, -1, 1, -1, 1 );
    _gl.glMatrixMode( GL.GL_MODELVIEW );
    _gl.glLoadIdentity();    
  }
  
  void perspective( float fovy, float aspect, float nearZ, float farZ )
  {
    _gl.glMatrixMode( GL.GL_PROJECTION );
    _gl.glLoadIdentity();
    _glu.gluPerspective( fovy, aspect, nearZ, farZ );  
  }

  void camera( float ex, float ey, float ez, float tx, float ty, float tz, float ux, float uy, float uz )
  {
    _gl.glMatrixMode( GL.GL_MODELVIEW );
    _gl.glLoadIdentity();
    _glu.gluLookAt( ex, ey, ez, tx, ty, tz, ux, uy, uz );
  }

  void camera( Vector3 e, Vector3 t, Vector3 u )
  {
    _gl.glMatrixMode( GL.GL_MODELVIEW );
    _gl.glLoadIdentity();
    _glu.gluLookAt( e.x, e.y, e.z, t.x, t.y, t.z, u.x, u.y, u.z );
  }
  void setViewport( int x1, int y1, int x2, int y2 )
  {
    _gl.glViewport( x1, y1, x2, y2 );
  }
  
  
  void identity()
  {
    _gl.glMatrixMode( GL.GL_MODELVIEW );
    _gl.glLoadIdentity();
  }
  
  void setMatrixMode( int mode )
  {
    switch( mode )
    {
      case 0:
        _gl.glMatrixMode( GL.GL_PROJECTION );
//        _gl.glLoadIdentity();
        break;
      case 1:
        _gl.glMatrixMode( GL.GL_MODELVIEW );
//        _gl.glLoadIdentity();
        break;
      default:
        _gl.glMatrixMode( GL.GL_MODELVIEW );
//        _gl.glLoadIdentity();
    }
  }


  Matrix getMatrix( int type )
  {
    Matrix m = new Matrix();
    m.identity();
    
    _gl.glGetFloatv( type, m.getFloatBuffer() );
      
    return m;
  }

  Matrix getProjMatrix()
  {
    Matrix m = new Matrix();
    _gl.glGetFloatv( GL.GL_PROJECTION_MATRIX, m.getFloatBuffer() );
    //println( "proj matrix" );
    //m.debug();
    return m;
  }

  Matrix getViewMatrix()
  {
    Matrix m = new Matrix();
    _gl.glGetFloatv( GL.GL_MODELVIEW_MATRIX, m.getFloatBuffer() );
    //println( "view matrix" );
    //m.debug();
    return m;
  }

  Matrix getTextureMatrix()
  {
    Matrix m = new Matrix();
    _gl.glGetFloatv( GL.GL_TEXTURE_MATRIX, m.getFloatBuffer() );
    //println( "texture matrix" );
    //m.debug();
    return m;
  }
  
/*  Matrix getMatrix( int type )
  {
    Matrix m = new Matrix();
    m.identity();
    
    if( type == 0 )
    {
      _gl.glGetFloatv( GL.GL_PROJECTION_MATRIX, m.getFloatBuffer() );
    }
    else if( type == 1 )
    {
      _gl.glGetFloatv( GL.GL_MODELVIEW_MATRIX, m.getFloatBuffer() );
    }
    else if( type == 2 )
    {
      _gl.glGetFloatv( GL.GL_TEXTURE_MATRIX, m.getFloatBuffer() );
    }
    else 
      return null;
      
    return m;
  }*/
  
  void translate( float x, float y, float z )
  {
    _gl.glTranslatef( x, y, z );
  }  

  void translate( Vector3 v )
  {
    _gl.glTranslatef( v.x, v.y, v.z );
  }  


  void rotate( float a, float x, float y, float z )
  {
    _gl.glRotatef( a, x, y, z );
  }

  void rotate( float a, Vector3 v )
  {
    _gl.glRotatef( a, v.x, v.y, v.z );
  }

  void rotateX( float a )
  {
    _gl.glRotatef( a, 1, 0, 0 );
  }

  void rotateY( float a )
  {
    _gl.glRotatef( a, 0, 1, 0 );
  }

  void rotateZ( float a )
  {
    _gl.glRotatef( a, 0, 0, 1 );
  }

  void scale( float sx, float sy, float sz )
  {
    _gl.glScalef( sx, sy, sz );
  }

  void scale( float s )
  {
    _gl.glScalef( s, s, s );
  }

  /**********************************************************************
  // matrix stack methods
  ***********************************************************************/

  void loadMatrix( FloatBuffer m )
  {
    _gl.glLoadMatrixf( m );
  }

  void multMatrix( FloatBuffer m )
  {
    _gl.glMultMatrixf( m );
  }

  void multMatrix( Matrix m )
  {
    FloatBuffer fb = FloatBuffer.wrap( m._M );
    _gl.glMultMatrixf( fb );
  }
    

  void pushMatrix()
  {
    _gl.glPushMatrix();
  }

  void popMatrix()
  {
    _gl.glPopMatrix();
  }


  /**********************************************************************
  // blending methods
  ***********************************************************************/
  
  void enableBlend()
  {
    _gl.glEnable( GL.GL_BLEND );
  }

  void disableBlend()
  {
    _gl.glDisable( GL.GL_BLEND );
  }
  
  void setBlend( boolean f )
  {
    if( f ) _gl.glEnable( GL.GL_BLEND );
    else _gl.glDisable( GL.GL_BLEND );
  }

  void setAlphaBlend()
  {
    _gl.glBlendFunc( GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA );    
  }

  void setAdditiveBlend()
  {
    _gl.glBlendFunc( GL.GL_SRC_ALPHA, GL.GL_ONE );
  }

  void setOneBlend()
  {
    _gl.glBlendFunc( GL.GL_ONE, GL.GL_ONE );
  }


  /**********************************************************************
  // render methods
  ***********************************************************************/

  void enableLighting( boolean f )
  {
    if( f ) _gl.glEnable( GL.GL_LIGHTING );
    else _gl.glDisable( GL.GL_LIGHTING );
  }
  
  void enableTexture( boolean f )
  {
    if( f ) _gl.glEnable( GL.GL_TEXTURE_2D );
    else _gl.glDisable( GL.GL_TEXTURE_2D );
  }

  void setDepthWrite( boolean f )
  {
    if( f ) _gl.glEnable( GL.GL_DEPTH_TEST );
    else _gl.glDisable( GL.GL_DEPTH_TEST );
  }

  void setDepthMask( boolean f )
  {
    _gl.glDepthMask( f );
  }

  /**********************************************************************
  // rendering methods
  **********************************************************************/

  void fill( float c )
  {
    _r = c;
    _g = c;
    _b = c;
    _a = 1;
  }

  void fill( float c, float a )
  {
    _r = c;
    _g = c;
    _b = c;
    _a = a;
  }

  void fill( float r, float g, float b )
  {
    _r = r;
    _g = g;
    _b = b;
    _a = 1;
  }

  void fill( float r, float g, float b, float a )
  {
    _r = r;
    _g = g;
    _b = b;
    _a = a;
  }

  void quad( float posx, float posy, float z, float s )
  {
    _gl.glBegin( GL.GL_QUADS );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f );
    _gl.glTexCoord2f(0*_uScale, 0*_vScale);
    _gl.glVertex3f( posx+(-1*s), posy+(1*s), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f );
    _gl.glTexCoord2f(1*_uScale, 0*_vScale );
    _gl.glVertex3f( posx+(1*s), posy+(1*s), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f );
    _gl.glTexCoord2f(1*_uScale, 1*_vScale );
    _gl.glVertex3f( posx+(1*s), posy+(-1*s), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f );
    _gl.glTexCoord2f(0*_uScale, 1*_vScale );
    _gl.glVertex3f( posx+(-1*s), posy+(-1*s), z );
    _gl.glEnd();   
  }

  // renders a quad at origin.
  // useful when you use want to manually translate
  void quad( float s )
  {  
    quad( 0, 0, 0, s );
  }

  void rect( float posx, float posy, float z, float sx, float sy )
  {  
    _gl.glBegin( GL.GL_QUADS );

    _gl.glColor4f( _r, _g, _b, _a );    
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    _gl.glTexCoord2f( 0*_uScale+_uOffset, 0*_vScale+_vOffset ); 
    _gl.glVertex3f( posx+(-1*sx), posy+(-1*sy), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    _gl.glTexCoord2f(1*_uScale+_uOffset, 0*_vScale+_vOffset ); 
    _gl.glVertex3f( posx+(1*sx), posy+(-1*sy), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    _gl.glTexCoord2f(1*_uScale+_uOffset, 1*_vScale+_vOffset ); 
    _gl.glVertex3f( posx+(1*sx), posy+(1*sy), z );

    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 
    _gl.glTexCoord2f(0*_uScale+_uOffset, 1*_vScale+_vOffset); 
    _gl.glVertex3f( posx+(-1*sx), posy+(1*sy), z );

    _gl.glEnd();   
  } 
  
  void rect( float posx, float posy, float sx, float sy )
  {  
    //_gl.glTranslatef( posx, posy, 0 );
    _gl.glBegin( GL.GL_QUADS );
    _gl.glNormal3f( 0.0f, 0.0f, 1.0f ); 

    _gl.glColor4f( _r, _g, _b, _a );    
    _gl.glTexCoord2f( 0*_uScale, 0*_vScale ); 
    _gl.glVertex3f( posx+0*sx, posy+0*sy, 0 );
    
    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glTexCoord2f(1*_uScale, 0*_vScale ); 
    _gl.glVertex3f( posx+1*sx, posy+0*sy, 0 );
    
    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glTexCoord2f(1*_uScale, 1*_vScale ); 
    _gl.glVertex3f( posx+1*sx, posy+1*sy, 0 );
    
    _gl.glColor4f( _r, _g, _b, _a );
    _gl.glTexCoord2f(0*_uScale, 1*_vScale); 
    _gl.glVertex3f( posx+0*sx, posy+1*sy, 0 );
    
    _gl.glEnd();   
  } 
  
  void rect( float sx, float sy )
  {  
    this.rect( 0, 0, 0, sx, sy );
  }
  
  void drawGrid( float x, float y, float z, float wid, float hei, int xCells, int yCells )
  {
    Vector3 p1 = new Vector3();
    Vector3 p2 = new Vector3();

    float xstep = wid / (float)xCells;
    float ystep = hei / (float)yCells;

    float invXCells = 1.0 / (float)xCells;
    float invYCells = 1.0 / (float)yCells;
    
    // render grid
    for( int j=0; j<yCells-1; j++ )
    {
      vgl._gl.glBegin( GL.GL_QUAD_STRIP );
      for( int i=0; i<xCells; i++ )
      {
        p1.set( (x+i*xstep)-wid*0.5, (y+j*ystep)-hei*0.5, z );
        p2.set( (x+i*xstep)-wid*0.5, (y+(j+1)*ystep)-hei*0.5, z );

        float u = i * invXCells * vgl._uScale + vgl._uOffset;
        float v1 = j * invYCells * vgl._vScale + vgl._vOffset;
        float v2 = (j+1) * invYCells * vgl._vScale + vgl._vOffset;

        vgl._gl.glColor4f( 1, 1, 1, 1 );
        vgl._gl.glNormal3f( 0, 0, 1 );
        vgl._gl.glTexCoord2f( u, v1 );
        vgl._gl.glVertex3f( p1.x, p1.y, p1.z );

        vgl._gl.glColor4f( 1, 1, 1, 1 );
        vgl._gl.glNormal3f( 0, 0, 1 );
        vgl._gl.glTexCoord2f( u, v2 );
        vgl._gl.glVertex3f( p2.x, p2.y, p2.z );
      }  
      vgl._gl.glEnd();
    }  
  }  
  
  void texCoordScale( float uScale, float vScale )
  {
     _uScale = uScale;
     _vScale = vScale;
  }

  void texCoordOffset( float uo, float vo )
  {
    _uOffset = uo;
    _vOffset = vo;
  } 
  
  void line( Vector3 p1, Vector3 p2 )
  {  
    _gl.glBegin( GL.GL_LINES );
    _gl.glColor4f( _r, _g, _b, _a );    

    _gl.glVertex3f( p1.x, p1.y, p1.z );
    _gl.glVertex3f( p2.x, p2.y, p2.z );

    _gl.glEnd();
  }

  void line( Vector3 p1, Vector3 p2, float i1, float i2 )
  {  
    _gl.glBegin( GL.GL_LINES );
    _gl.glColor4f( i1, i1, i1, i1 );
    _gl.glVertex3f( p1.x, p1.y, p1.z );
    _gl.glColor4f( i2, i2, i2, i2 );
    _gl.glVertex3f( p2.x, p2.y, p2.z );

    _gl.glEnd();
  }

  void line( Vector3 p1, Vector3 p2, float r1, float g1, float b1, float a1, float r2, float g2, float b2, float a2 )
  {  
    _gl.glBegin( GL.GL_LINES );
    _gl.glColor4f( r1, g1, b1, a1 );
    _gl.glVertex3f( p1.x, p1.y, p1.z );
    _gl.glColor4f( r2, g2, b2, a2 );
    _gl.glVertex3f( p2.x, p2.y, p2.z );

    _gl.glEnd();
  }

  void line( Vector3 p1, Vector3 p2, Vector4 col1, Vector4 col2 )
  {  
    _gl.glBegin( GL.GL_LINES );
    _gl.glColor4f( col1.x, col1.y, col1.z, col1.w );
    _gl.glVertex3f( p1.x, p1.y, p1.z );
    _gl.glColor4f( col2.x, col2.y, col2.z, col2.w );
    _gl.glVertex3f( p2.x, p2.y, p2.z );

    _gl.glEnd();
  }

  void beginShape()
  {  
    _gl.glBegin( GL.GL_LINES );
  }
  
  void endShape()
  {
    _gl.glEnd();
  }
  
  void vertex( float x, float y, float z )
  {
    _gl.glVertex3f( x, y, z );    
  }

  void vertex( Vector3 v )
  {
    _gl.glVertex3f( v.x, v.y, v.z );    
  }
  
  
  //
  // Shader specific code
  //
  CG addShader( String filename )
  {
    if( _cgShaders == null )
      _cgShaders = new HashMap();
    
    CG shader = new CG();
    shader.loadFXFromFile( filename );
    
    _cgShaders.put( filename, shader );
    
    return shader;
  }
  
  void activateShader( CG cg )
  {
    _activeShader = cg;
  }
 
  boolean activateShader( String filename )
  {
    // Make an iterator to look at all the things in the HashMap
    Iterator i = _cgShaders.values().iterator();

    while( i.hasNext() )
    {
      CG tmp = (CG)i.next();
      if( tmp._name.equals( filename ) )
        _activeShader = tmp;
        return true;
    }
    
    return false;
  }
  
  
  //
  // Shaders parameter setting
  //
  void setTextureParameter( String param, int val )
  {
    _activeShader.setTextureParameter( param, val );
  }
  
  void setParameter1f( String param, float val )
  {
    _activeShader.setParameter1f( param, val );
  }
  
  void setParameter2f( String param, float x, float y )
  {
    _activeShader.setParameter2f( param, x, y );
  }
  
  void setParameter3f( String param, float x, float y, float z )
  {
    _activeShader.setParameter3f( param, x, y, z );
  }
  
  void setParameter3f( String param, Vector3 v )
  {
    _activeShader.setParameter3f( param, v.x, v.y, v.z );
  }
  
  void setParameter4f( String param, float x, float y, float z, float w )
  {
    _activeShader.setParameter4f( param, x, y, z, w );
  }
  
  void setParameter4f( String param, Vector4 v )
  {
    _activeShader.setParameter4f( param, v.x, v.y, v.z, v.w );
  }

  void setParameter4x4f( String param, int matrix, int matrixType )
  {
    _activeShader.setParameter4x4f( param, matrix, matrixType );
  }
  
  void setParameter4x4f( String param, Matrix m )
  {
    _activeShader.setParameter4x4f( param, m );
  }
  
    
  
  /**********************************************************************
  // Members
  **********************************************************************/
  PGraphicsOpenGL _pgl;
  GL _gl;
  GLU _glu;
  
  
  PApplet _parent;
  
  // global color for our render faces
  float _r, _g, _b, _a;


  // used to scale tex coordinates  
  float _uScale, _vScale;
  
  // used to offset tex coordinates  
  float _uOffset, _vOffset;   
  
  // Shader specific
  CG _activeShader;
  int _numShaders;
  Map _cgShaders;
  
  Matrix _view;
  Matrix _proj;
};


