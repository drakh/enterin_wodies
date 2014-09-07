/*
  3ds loader for java from MRI.  
 sample: http://www.multi.fi/~mbc/v3ds/Decode3dsApplet.html
 http://games.swizel-studios.com/libraries.html (support for materials and updated classes)
 documentation: http://www.multi.fi/~mbc/v3ds/mri-v3ds-doc/index.html
 
 processing example by v.
 uses vtools v2.1 for rendering.
 vic@pixelnerve.com
 www.pixelnerve.com/v
 
 NEWS:
 Intuitive mouse rotation.
 Rendering by material.
 Camera control
 etc.
 library is up-to-date as the documentation. it supports material chunks now!
 
 
 KEYS:
 w - enable/disable wireframe
 v - enable/disable vertex normal render
 f - enable/disable face normal render
 q/a - lift camera
 up/down arrows - zoom camera in/out 
 left/right arrows - strafe camera
 */

import processing.opengl.*;
import mri.v3ds.*;


boolean FLIPV = true;
boolean FLIPYZ = false;



// Simple class to hold materials data from 3ds
class Material
{
  String name;
  Vector4 ambient;
  Vector4 diffuse;
  Vector4 specular;
  String textureName;
  int texId;
};

// Simple data structure to hold own data.
// For testing purposes only! TODO! include loader into the 3d framework
class Mesh
{
  Vector3[] faceNormals;
  Vector3[] faceMiddlePoint;
  Vector3[] vertices;
  Vector3[] vertexNormals;

  int _numTexCoords;
  Vector3[] texCoords;
};


ArrayList materials;
ArrayList textures;
Mesh[] meshes;
Scene3ds scene;
Vcamera cam;
ArcBall arcball; 

boolean drawFaceNormals = false;
boolean drawVertexNormals = false;
boolean drawWireFrame = false;


CG diffuseSpecularCG;
CG diffuseSpecularNoTextureCG;


void setup()
{
  size( 800, 600, OPENGL );

  // if enabled the screen will clear
  hint( ENABLE_OPENGL_4X_SMOOTH );
  smooth(); 

  vgl = new VGL( this );


  diffuseSpecularCG = vgl.addShader( "diffusespecular.cgfx" );
  diffuseSpecularNoTextureCG = vgl.addShader( "diffusespecular_notexture.cgfx" );


  //
  // Load scene
  //
  TextDecode3ds decode = new TextDecode3ds();
  int level = Scene3ds.DECODE_ALL; //, DECODE_USED_PARAMS, DECODE_USED_PARAMS_AND_CHUNKS
  //int level = Scene3ds.DECODE_USED_PARAMS_AND_CHUNKS;

  try 
  {
    File f = new File( dataPath("croc.3ds") );
    scene = new Scene3ds( f, decode, level );
  }
  catch( Exception3ds e )
  {
    println( "failed to load 3ds: " + e );
    // Something went wrong!
    exit();
  }	
  // debug info
  //println( decode.text() );
  debug3DSScene();


  // Compute normals for our scene
  computeNormals( scene );


  cam = new Vcamera( 0, 100, 100, 0, 0, 0, 0, 1, 0 );
  arcball = new ArcBall(); 


  //
  // Alloc for materials+textures
  //
  textures = new ArrayList();
  materials = new ArrayList();
  int texIndex = 0;
  
	    Material matPrev = null;
	    for( int m=0; m<scene.materials(); m++ )
	    {
	    	Material3ds mat = scene.material( m );
	      Material mmat = new Material();
	      mmat.texId = -1;
	      mmat.name = mat.name();
	      mmat.ambient = new Vector4( mat.ambient().red(), mat.ambient().green(), mat.ambient().blue(), 1 );
	      mmat.diffuse = new Vector4( mat.diffuse().red(), mat.diffuse().green(), mat.diffuse().blue(), 1 );
	      mmat.specular = new Vector4( mat.specular().red(), mat.specular().green(), mat.specular().blue(), 1 );
	      mmat.textureName = mat.mapName();
	      
	      //System.out.println( mat.ambient().red() + ", " + mat.ambient().green() + ", " + mat.ambient().blue() );
	      //System.out.println( mat.diffuse().red() + ", " + mat.diffuse().green() + ", " + mat.diffuse().blue() );
	      //System.out.println( mat.specular().red() + ", " + mat.specular().green() + ", " + mat.specular().blue() );
	      //System.out.println( "map: " + mat.mapName() );

	      
	      // Load textures to texture pool is available
	      if( mat.mapName().length() > 0  )
	      {
	    	  XTexture _tex = null;

	    	  // Load texture.
                  _tex = new XTexture();
                  boolean res = _tex.load( mat.mapName() ); 

		      if( _tex != null )
		      { 
		    	  if( matPrev != null )
		    	  {
		    		  matPrev.texId = texIndex;
		    		  matPrev.textureName = mat.mapName().toString();
		    	  }
		    	  //mmat.texId = texIndex;
				
		    	  texIndex++;
		      }
		      else
		      {
		    	  if( matPrev != null ) matPrev.texId = -1;
		    	  //mmat.texId = -1;
		      }

	        
		      // Add texture to texture's pool
		      textures.add( _tex );      
	      }
	      //else
	    	  //System.out.println( "no material texture was loaded!" );
	      
	      
	      matPrev = mmat;
	      materials.add( mmat );
	    }
	    
	    
	    /*System.out.println( "--------------------------------------" );
	    for( int m=0; m<_materials.size(); m++ )
	    {
	      Material mat = _materials.get( m );
	      
	      System.out.println( mat.ambient[0] + ", " + mat.ambient[1] + ", " + mat.ambient[2] );
	      System.out.println( mat.diffuse[0] + ", " +  mat.diffuse[1] + ", " +  mat.diffuse[2] );
	      System.out.println( mat.specular[0] + ", " +  mat.specular[1] + ", " +  mat.specular[2] );
	      System.out.println( "map: " + mat.textureName );
	    }*/
}

void debug3DSScene()
{
  //
  // Debug info
  //
  println( "Num Cameras: " + scene.cameras() );
  for( int c=0; c<scene.cameras(); c++ )
  {
    Camera3ds cam = scene.camera( c );
    println( "    Camera: " + cam.name() );
  }

  println( "Num Materials: " + scene.materials() );
  for( int m=0; m<scene.materials(); m++ )
  {
    Material3ds mat = scene.material( m );
    println( "  Material: " + mat.name() );
    println( "    texture: " + mat.mapName() );
  }

  println( "Num Meshes: " + scene.meshes() );
  for( int i=0; i<scene.meshes(); i++ )
  {
    Mesh3ds mesh = scene.mesh( i );
    println( "  Mesh Name: " + mesh.name() );

    println( "    Num FaceMats: " + mesh.faceMats() );
    for( int m=0; m<mesh.faceMats(); m++ )
    {
      FaceMat3ds fmat = mesh.faceMat( m );
      println( "FaceMat ID: " + fmat.material() );
      println( "FaceMat indices: " + fmat.faces() );
    }

    println( "    Num Faces: " + mesh.faces() );
    for( int m=0; m<mesh.faces(); m++ )
    {
      Face3ds face = mesh.face( m );
    }
    println( "    Num Vertices: " + mesh.vertices() );
    for( int m=0; m<mesh.vertices(); m++ )
    {
      Vertex3ds vert = mesh.vertex( m );
    }
    println( "    Num SmoothEntries: " + mesh.smoothEntrys() );
    for( int m=0; m<mesh.smoothEntrys(); m++ )
    {
      //Vertex3ds vert = mesh.vertex( m );
    }
  }
}  


void computeNormals( Scene3ds scene )
{
  //
  // Compute face+vertex normals
  //
  meshes = new Mesh[ scene.meshes() ];
  for( int i=0; i<scene.meshes(); i++ )
  {
    Mesh3ds m = scene.mesh( i );

    // Alloc memory
    meshes[i] = new Mesh();
    meshes[i].faceNormals = new Vector3[ m.faces() ];
    meshes[i].faceMiddlePoint = new Vector3[ m.faces() ];
    meshes[i].vertices = new Vector3[ m.vertices() ];
    meshes[i].vertexNormals = new Vector3[ m.vertices() ];
    meshes[i]._numTexCoords = 0;
    meshes[i].texCoords = new Vector3[ m.vertices() ];


    //
    // Compute face normals
    //
    for( int fi=0; fi<m.faces(); fi++ )
    {
      Face3ds f = m.face( fi );
      Vertex3ds p0 = m.vertex(f.P0);
      Vertex3ds p1 = m.vertex(f.P1);
      Vertex3ds p2 = m.vertex(f.P2);

      // Compute face middle point
      meshes[i].faceMiddlePoint[fi] = new Vector3();
      meshes[i].faceMiddlePoint[fi].x = (p0.X + p1.X + p2.X) / 3.0;
      meshes[i].faceMiddlePoint[fi].y = (p0.Y + p1.Y + p2.Y) / 3.0;
      meshes[i].faceMiddlePoint[fi].z = (p0.Z + p1.Z + p2.Z) / 3.0;

      Vector3 v0 = new Vector3(p0.X, p0.Y, p0.Z);
      Vector3 v1 = new Vector3(p1.X, p1.Y, p1.Z);
      Vector3 v2 = new Vector3(p2.X, p2.Y, p2.Z);

      Vector3 e0 = Vector3.sub( v1, v0 );
      Vector3 e1 = Vector3.sub( v2, v0 );

      meshes[i].faceNormals[fi] = Vector3.cross( e1, e0 );
      meshes[i].faceNormals[fi].normalize();
    }

    //
    // Compute vertex normals
    //
    // Take average from adjacent face normals.
    // TODO. find coplanar faces or get weighted normals.
    // One could also use the smooth groups from 3ds to compute normals. we'll see about that. 
    // this will have to work for now.
    //
    Vector3 v = new Vector3();
    Vector3 n = new Vector3();
    TexCoord3ds tc = new TexCoord3ds(0, 0);
    for( int vi=0; vi<m.vertices(); vi++ )
    {
      Vertex3ds p = m.vertex( vi );

      if( m.texCoords() > 0 )
        tc = m.texCoord( vi );

      v.set( p.X, p.Y, p.Z );
      n.set( 0, 0, 0 );
      float num = 0;

      for( int fi=0; fi<m.faces(); fi++ )
      {
        Face3ds f = m.face( fi );
        Vertex3ds p0 = m.vertex(f.P0);
        Vertex3ds p1 = m.vertex(f.P1);
        Vertex3ds p2 = m.vertex(f.P2);

        if( vi == f.P0 || vi == f.P1 || vi == f.P2 )
        {
          num++;
          n.add( meshes[i].faceNormals[fi] );
        }
      }

      if( num > 0 ) n.mul( 1.0/(float)num );
      n.normalize();
      meshes[i].vertexNormals[vi] = n.copy();
      if( FLIPYZ )
      {
        float tmp = meshes[i].vertexNormals[vi].y;
        meshes[i].vertexNormals[vi].y = -meshes[i].vertexNormals[vi].z;
        meshes[i].vertexNormals[vi].z = tmp;
      }

      // Save vertex data      
      if( FLIPYZ )
        meshes[i].vertices[vi] = new Vector3( p.X, -p.Z, p.Y );
      else
        meshes[i].vertices[vi] = new Vector3( p.X, p.Y, p.Z );

      // Save texcoord data
      meshes[i]._numTexCoords = m.texCoords();
      if( m.texCoords() > 0 )
      {
        if( FLIPV )
          meshes[i].texCoords[vi] = new Vector3( tc.U, 1.0-tc.V, 0 );
        else
          meshes[i].texCoords[vi] = new Vector3( tc.U, tc.V, 0 );
      }
    }

    /*    
     compute vertex normals with smoothing group
     
     http://www.gamedev.net/community/forums/topic.asp?topic_id=504353
     for every triangle F
     for every vertex of F, namely V
     triangleListsForVertices[index of V].push_back(index of F)
     
     for every triangle F
     for every vertex of F, namely V
     normal = (0,0,0)
     for every triangle F2 in triangleListsForVertices[index of V]
     if F2 and F SHARE smoothing groups
     normal += Normal of F2
     normal.normalize
     */
  }
}


void draw()
{
  float time = millis()*0.001;

  vgl.begin();
  vgl.background( 0.1 );
  vgl.perspective( 45, 4.0/3.0, 1, 5000 );
  //vgl.camera( 0, 100+mouseY, (mouseX-width*0.5), 0, 0, 0, 0, 1, 0 );
  vgl.camera( cam._pos, cam._target, cam._up );  

  Vector3 lightPos = new Vector3( 60, 100, 400 );
  //setupPointLight( new Vector3(60, 100, 400) );
  //vgl.enableLighting( true );

  arcball.run();

  vgl.pushMatrix();
  vgl.multMatrix( arcball.matrix );    

  // World matrix
  Matrix matWorld = vgl.getViewMatrix();
  matWorld.transpose();

  for( int mi=0; mi<scene.meshes(); mi++ )
  {
    Mesh3ds m = scene.mesh( mi );

    // draw faces
    vgl.fill( 1 );
    vgl.enableTexture( true );

    XTexture tex;
    Material mat;
    FaceMat3ds fmat;
    for( int fm=0; fm<m.faceMats(); fm++ )
    {
      Face3ds[] faces = m.faceArray();    // list of all faces in mesh
      fmat = m.faceMat( fm );  // get current material's face
      mat = (Material)materials.get( fmat.material() );
      if( mat.texId >= 0 )  tex = (XTexture)textures.get( mat.texId ); //fmat.material() );
      else  tex = null;


      Vector3 uv0 = new Vector3();
      Vector3 uv1 = new Vector3();
      Vector3 uv2 = new Vector3();

      CGpass pass;
      CG currShader;

      // Just in case material has no texture. render with color only!
      if( tex != null )
      {
        currShader = diffuseSpecularCG;
      }
      else
      {
        currShader = diffuseSpecularNoTextureCG;
      }

      if( tex != null )  currShader.setTextureParameter( "ColorSampler", tex.getId() );
      currShader.setParameter4f( "lightPos", lightPos.x, lightPos.y, lightPos.z, 1.0 );
      currShader.setParameter3f( "cameraPos", cam._pos );
      currShader.setParameter1f( "kC", 0 );
      currShader.setParameter1f( "kL", 0.005 );
      currShader.setParameter1f( "kQ", 0.0 );   
      currShader.setParameter4x4fBySemantic( "WorldViewProjection", CgGL.CG_GL_MODELVIEW_PROJECTION_MATRIX, CgGL.CG_GL_MATRIX_IDENTITY );
      currShader.setParameter4x4fBySemantic( "World", CgGL.CG_GL_MODELVIEW_MATRIX, CgGL.CG_GL_MATRIX_INVERSE_TRANSPOSE );
      currShader.setParameter4x4f( "WorldXf", matWorld );
      pass = currShader.getTechniqueFirstPass( "Technique_DiffuseSpecular" );
      CgGL.cgSetPassState( pass );

      vgl._gl.glBegin( GL.GL_TRIANGLES );
      for( int fi=0; fi<fmat.faces(); fi++ )
      {
        int idx = fmat.face( fi );
        Face3ds f = m.face( idx );

        Vector3 n0 = meshes[mi].vertexNormals[f.P0];
        Vector3 n1 = meshes[mi].vertexNormals[f.P1];
        Vector3 n2 = meshes[mi].vertexNormals[f.P2];
        Vector3 v0 = meshes[mi].vertices[f.P0];
        Vector3 v1 = meshes[mi].vertices[f.P1];
        Vector3 v2 = meshes[mi].vertices[f.P2];
        if( m.texCoords() > 0 )
        {
          uv0 = meshes[mi].texCoords[f.P0];
          uv1 = meshes[mi].texCoords[f.P1];
          uv2 = meshes[mi].texCoords[f.P2];
        }

        vgl._gl.glColor4f( mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w );
        vgl._gl.glNormal3f( n0.x, n0.y, n0.z ); 
        if( m.texCoords() > 0 )  vgl._gl.glTexCoord2f( uv0.x, uv0.y );
        vgl._gl.glVertex3f( v0.x, v0.y, v0.z );

        vgl._gl.glColor4f( mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w );
        vgl._gl.glNormal3f( n1.x, n1.y, n1.z ); 
        if( m.texCoords() > 0 )  vgl._gl.glTexCoord2f( uv1.x, uv1.y );
        vgl._gl.glVertex3f( v1.x, v1.y, v1.z );

        vgl._gl.glColor4f( mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w );
        vgl._gl.glNormal3f( n2.x, n2.y, n2.z ); 
        if( m.texCoords() > 0 )  vgl._gl.glTexCoord2f( uv2.x, uv2.y );
        vgl._gl.glVertex3f( v2.x, v2.y, v2.z );
      }
      vgl._gl.glEnd();

      CgGL.cgResetPassState( pass );

    }
  }


  debugSceneData();

  vgl.popMatrix();

  vgl.end();


  // Get input
  if( keyPressed && keyCode == LEFT )
  {
    cam.strafe( -5 );
  }
  else if( keyPressed && keyCode == RIGHT )
  {
    cam.strafe( 5 );
  }

  if( keyPressed && keyCode == UP )
  {
    cam.move( 5 );
  }
  else if( keyPressed && keyCode == DOWN )
  {
    cam.move( -5 );
  }

  if( keyPressed && key == 'q' )
  {
    cam.lift( -5 );
  }
  else if( keyPressed && key == 'a' )
  {
    cam.lift( 5 );
  }

}


//
// Draw mesh debug info to screen
//
void debugSceneData()
{
  vgl.enableTexture( false );
  vgl.enableLighting( false );
  for( int mi=0; mi<scene.meshes(); mi++ )
  {
    Mesh3ds m = scene.mesh( mi );

    //     // draw vertices
    //     vgl.fill( 1 );
    //     vgl.enableTexture( false );
    //     for( int vi=0; vi<m.vertices(); vi++ )
    //     {
    //       Vertex3ds v = m.vertex( vi );   
    //       vgl.quad( v.X, v.Y, v.Z, 1 );
    //     }

    if( drawWireFrame )
    {     
      // draw wireframe representation of the scene
      vgl.setAdditiveBlend();
      vgl.setDepthMask( false );
      //vgl.setDepthWrite( false );
      vgl.fill( 1, 1, 1, 0.5 );
      for( int fi=0; fi<m.faces(); fi++ )
      {
        Face3ds f = m.face( fi );
        Vector3 v0 = meshes[mi].vertices[f.P0].copy();
        v0.add( meshes[mi].vertexNormals[f.P0] );
        Vector3 v1 = meshes[mi].vertices[f.P1].copy();
        v1.add( meshes[mi].vertexNormals[f.P1] );
        Vector3 v2 = meshes[mi].vertices[f.P2].copy();
        v2.add( meshes[mi].vertexNormals[f.P2] );
        vgl.line( v0, v1 );
        vgl.line( v0, v2 );
        vgl.line( v1, v2 );
      }
      vgl.setDepthWrite( true );
      vgl.setDepthMask( true );
      vgl.setAlphaBlend();
    }

    if( drawFaceNormals )
    {     
      // draw face normals
      vgl.fill( 1, 0, 1, 1 );
      for( int fi=0; fi<m.faces(); fi++ )
      {
        Vector3 v0 = meshes[mi].faceMiddlePoint[fi].copy();
        Vector3 v1 = meshes[mi].faceMiddlePoint[fi].copy();
        Vector3 n = meshes[mi].faceNormals[fi].copy();
        n.mul( 5 );
        v1.add( n );
        vgl.line( v0, v1 );
      }
    }
    if( drawVertexNormals )
    {
      // Draw vertex
      vgl.fill( 0, 1, 1, 1 );
      for( int vi=0; vi<m.vertices(); vi++ )
      {
        Vector3 v0 = meshes[mi].vertices[vi].copy();
        Vector3 v1 = meshes[mi].vertices[vi].copy();
        Vector3 n = meshes[mi].vertexNormals[vi].copy();
        n.mul( 5 );
        v1.add( n );       
        vgl.line( v0, v1 );
      }
    }
  }
}


void keyPressed()
{
  if( key == 'f' )
  {
    drawFaceNormals = !drawFaceNormals;
  }
  if( key == 'v' )
  {
    drawVertexNormals = !drawVertexNormals;
  }
  if( key == 'w' )
  {
    drawWireFrame = !drawWireFrame;
  }  

  if( key == 's' )
  {
    saveFrame( "shot.jpg" );
  }
}

//------------------------------------------------------------
// Control
//------------------------------------------------------------
void mousePressed()
{
  arcball.mousePressed();
}

void mouseDragged()
{
  arcball.mouseDragged();    
} 

void stop()
{
  super.stop();
}


