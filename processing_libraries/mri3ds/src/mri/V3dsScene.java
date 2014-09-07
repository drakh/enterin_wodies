package mri;


import com.sun.opengl.util.texture.Texture;
import com.sun.opengl.util.texture.TextureIO;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.media.opengl.GL;

import mri.v3ds.Exception3ds;
import mri.v3ds.Face3ds;
import mri.v3ds.FaceMat3ds;
import mri.v3ds.Material3ds;
import mri.v3ds.Mesh3ds;
import mri.v3ds.Scene3ds;
import mri.v3ds.TexCoord3ds;
import mri.v3ds.TextDecode3ds;
import mri.v3ds.Vertex3ds;

import processing.core.*;
//import processing.core.PImage;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;



public class V3dsScene
{
  static final boolean FLIPV = true;
  static final boolean FLIPYZ = false;
  
  
  // Simple class to hold materials data from 3ds
  public class Material
  {
    String name;
    float[] ambient;
    float[] diffuse;
    float[] specular;
    String textureName;
    int texId;
  };
  
  // Simple data structure to hold own data.
  // For testing purposes only! TODO! include loader into the 3d framework
  public class Mesh
  {
    PVector[] faceNormals;
    PVector[] faceMiddlePoint;
    PVector[] vertices;
    PVector[] vertexNormals;
  
    int _numTexCoords;
    PVector[] texCoords;
  };



  public class Camera
  {
	  public String _name;

	  public PVector _position;
	  public PVector _target;
	  public PVector _up;

	  public float _roll;
	  

	  public String getName()
	  {
		  return _name;
	  }
	  
	  public PVector getPosition()
	  {
		  return _position;
	  }

	  public PVector getTarget()
	  {
		  return _target;
	  }
	  
  };
  

  public class Light
  {
	  public String _name;
	  
	  public String _type;	// omni, directional

	  public PVector _position;
	  public PVector _target;
	  
	  public PVector _color;
	  
	  
	  public String getName()
	  {
		  return _name;
	  }
	  
	  public PVector getPosition()
	  {
		  return _position;
	  }

	  public PVector getTarget()
	  {
		  return _target;
	  }

	  public PVector getColor()
	  {
		  return _color;
	  }

	  public int getIntColor()
	  {
		  //int rr = (int)(_color.x * 255.0);
		  //int gg = (int)(_color.y * 255.0);
		  //int bb = (int)(_color.z * 255.0);
		  //return color( rr, gg, bb);
		  
		  return 1;
	  }

  };



  boolean _useMaterials;
  float _r, _g, _b, _a;

  boolean _isLoaded;
  Scene3ds _scene;  // from mri lib
  ArrayList<Material> _materials;
  ArrayList<Texture> _textures;
  Mesh[] _meshes;
  Camera[] _cameras;
  Light[] _lights;

  
  	PApplet _parent;
  	GL _gl;
 
 
  	int _callListID;
	boolean _callListCompiled;   
  
  
	public V3dsScene( PApplet p, String filename )
	{
		_parent = p;

		_gl = ((PGraphicsOpenGL)_parent.g).beginGL();

	  	_callListID = 0;
	    _callListCompiled = false; 

        _callListID = _gl.glGenLists( 1 );

    	((PGraphicsOpenGL)_parent.g).endGL();

    	_useMaterials = true;

    	_r = 1.0f;
    	_g = 1.0f;
    	_b = 1.0f;
    	_a = 1.0f;

    	_isLoaded = false;

    	loadScene( filename );
	}



	public V3dsScene( GL gl, String filename )
	{
		_parent = null;
	  
		_gl = gl;
	  
	  	_callListID = 0;
	    _callListCompiled = false; 
		
        _callListID = _gl.glGenLists( 1 );
        
        _useMaterials = true;
        
        _isLoaded = false;

    	loadScene( filename );
	}

	
	
	
	public void loadScene( String filename )
	{
		if( _isLoaded )
		{
			System.err.println( "(V3dsScene)  A scene has already been loaded using this object." );
			return;
		}
		
	    // Load scene
	    TextDecode3ds decode = new TextDecode3ds();
	    int level = Scene3ds.DECODE_ALL; //, DECODE_USED_PARAMS, DECODE_USED_PARAMS_AND_CHUNKS
	    //int level = Scene3ds.DECODE_USED_PARAMS_AND_CHUNKS;
	    try 
	    {
	    	File f = null;
	    	if( _parent != null )
	    	{
	    		f = new File( _parent.dataPath(filename) );
	    	}
	    	else
	    		f = new File( dataPath(filename) );
	    	
	    	_scene = new Scene3ds( f, decode, level );
	    	//System.out.println( decode.text() );
	    }
	    catch( Exception3ds e )
	    {
	      System.err.println( "(V3dsScene)  Failed to load 3ds file:  " + e );
	      // Something went wrong!
	      //System.exit( 0 );
	      return;
	    }
    
	    // Init stuff needed
	    // TODO! Everything should be init here. not in computeNormals. computeNormals should do what the name says. nothing else
	    init();
	  
	    // Compute normals for our scene
	    computeNormals();
	    
	    // Alloc for materials+textures
	    _textures = new ArrayList<Texture>();
	    _materials = new ArrayList<Material>();
	    int texIndex=0; //the order of texture file in array list textures.
	  
	    
	    /*
	     * 3ds files create a new material for a texture. So if you set a material with a texture, in practice
	     * it will return 2 materials. one with material color and the next one with the mapname.
	     * What we do here is check if the current material has a texture. it if does, we load it and then save the texture
	     * on the previous material on the list, where it belongs. 
	     */
	    Material matPrev = null;
	    for( int m=0; m<_scene.materials(); m++ )
	    {
	    	Material3ds mat = _scene.material( m );
	    	Material mmat = new Material();
	    	mmat.texId = -1;
	    	mmat.name = mat.name();
	    	mmat.ambient = new float[]{ mat.ambient().red(), mat.ambient().green(), mat.ambient().blue(), 1 };
	    	mmat.diffuse = new float[]{ mat.diffuse().red(), mat.diffuse().green(), mat.diffuse().blue(), mat.transparency() };
	    	mmat.specular = new float[]{ mat.specular().red(), mat.specular().green(), mat.specular().blue(), 1 };
	    	mmat.textureName = mat.mapName();
	      
	      //System.out.println( "name: " + mat.name() + " -- " + mat.ambient().red() + ", " + mat.ambient().green() + ", " + mat.ambient().blue() + ",  transparency: " + mat.transparency() );
	      //System.out.println( mat.diffuse().red() + ", " + mat.diffuse().green() + ", " + mat.diffuse().blue() );
	      //System.out.println( mat.specular().red() + ", " + mat.specular().green() + ", " + mat.specular().blue() );
	      //System.out.println( "map: " + mat.mapName() );

	      
	      // Load textures to texture pool is available
	      if( mat.mapName().length() > 0  )
	      {
	    	  Texture _tex = null;

	    	  // Load texture.
	    	  try
	    	  { 
	    		  if( _parent != null )
	    			  _tex = TextureIO.newTexture( new File(_parent.dataPath(mat.mapName())), true );
	    		  else
	    			  _tex = TextureIO.newTexture( new File(dataPath(mat.mapName())), true );
	    			  
	    	      _tex.setTexParameteri( GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT );
	    	      _tex.setTexParameteri( GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT ); 
	    	  }
		      catch( IOException e )
		      {
		    	  System.err.println( "(V3dsScene) Failed loading texture '" + mat.mapName() + "' with error: " + e );
		      }

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
		      _textures.add( _tex );      
	      }
	      //else
	    	  //System.out.println( "no material texture was loaded!" );
	      
	      
	      matPrev = mmat;
	      _materials.add( mmat );
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
  
	

  	public void draw()
  	{
  		if( _parent == null ) System.err.println( "PApplet reference is null. abort!" );
  		
  		_gl = ((PGraphicsOpenGL)_parent.g).beginGL();

	    // If the list is compiled and everything is ok, render
	    if( _callListID > 0 && _callListCompiled )
	    {
	    	_gl.glCallList( _callListID );
	    	
	    	// end gl here before return
	  		((PGraphicsOpenGL)_parent.g).endGL();
	    	
	    	return;
	    } 

	    if( _callListID > 0 && !_callListCompiled )
	    {
	        //_callListID = _gl.glGenLists( 1 ); 
	        _gl.glNewList( _callListID, GL.GL_COMPILE );  
	    }

	    
	    for( int mi=0; mi<_scene.meshes(); mi++ )
	    {
	    	Mesh3ds m = _scene.mesh( mi );


	    	Material mat;
	    	FaceMat3ds fmat;

	    	for( int fm=0; fm<m.faceMats(); fm++ )
	    	{
	    		//Face3ds[] faces = m.faceArray();    // list of all faces in mesh
	    		fmat = m.faceMat( fm );  // get current material's face
	    		try {
		    		mat = (Material)_materials.get( fmat.material() );
	    			//mat = (Material)_materials.get( fmat.material()+1 );
	    		} catch( IndexOutOfBoundsException e )
	    		{
	    			mat = null;
	    		}

	    		
	    		if( _useMaterials )
	    		{
		    		// Enable color material
		    		if( mat != null )
		    		{
		    			_gl.glEnable( GL.GL_COLOR_MATERIAL );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, mat.ambient, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, mat.diffuse, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, new float[]{32}, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, mat.specular, 0 );
		    		}
	
			        if( mat != null && mat.texId >= 0 )
			        {
				        _gl.glEnable( GL.GL_TEXTURE_2D );
				        _gl.glBindTexture( GL.GL_TEXTURE_2D, _textures.get( mat.texId ).getTextureObject() );
			        }
			        else
			        {
				        _gl.glBindTexture( GL.GL_TEXTURE_2D, 0 );
				        _gl.glDisable( GL.GL_TEXTURE_2D );
			        }
	    		}
	    		else
	    		{
	    			_gl.glEnable( GL.GL_COLOR_MATERIAL );
	    			//_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, mat.ambient, 0 );
	    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[]{_r, _g, _b, _a}, 0 );
	    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, new float[]{32}, 0 );
	    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, new float[]{1, 1, 1, 1}, 0 );
			        _gl.glBindTexture( GL.GL_TEXTURE_2D, 0 );
			        _gl.glDisable( GL.GL_TEXTURE_2D );
	    		}

		        PVector uv0 = new PVector();
		        PVector uv1 = new PVector();
		        PVector uv2 = new PVector();

		        _gl.glBegin( GL.GL_TRIANGLES );
		        for( int fi=0; fi<fmat.faces(); fi++ )
		        {
		          int idx = fmat.face( fi );
		          Face3ds f = m.face( idx );
		          PVector n0 = _meshes[mi].vertexNormals[f.P0];
		          PVector n1 = _meshes[mi].vertexNormals[f.P1];
		          PVector n2 = _meshes[mi].vertexNormals[f.P2];
		          PVector v0 = _meshes[mi].vertices[f.P0];
		          PVector v1 = _meshes[mi].vertices[f.P1];
		          PVector v2 = _meshes[mi].vertices[f.P2];
		          if( m.texCoords() > 0 )
		          {
		            uv0 = _meshes[mi].texCoords[f.P0];
		            uv1 = _meshes[mi].texCoords[f.P1];
		            uv2 = _meshes[mi].texCoords[f.P2];
		          }
		
		          if( mat != null ) _gl.glColor4f( mat.diffuse[0], mat.diffuse[1], mat.diffuse[2], mat.diffuse[3] );
		          else  _gl.glColor4f( _r, _g, _b, _a ); //1, 1, 1, 1 );
		          
		          _gl.glNormal3f( n0.x, n0.y, n0.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f(uv0.x, uv0.y);
		          _gl.glVertex3f( v0.x, v0.y, v0.z );
		  
		          _gl.glNormal3f( n1.x, n1.y, n1.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f( uv1.x, uv1.y);
		          _gl.glVertex3f( v1.x, v1.y, v1.z );
		  
		          _gl.glNormal3f( n2.x, n2.y, n2.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f( uv2.x, uv2.y );
		          _gl.glVertex3f( v2.x, v2.y, v2.z );
		        }
		        _gl.glEnd();
		      }
		    }

    
		if( _callListID > 0 && !_callListCompiled )
		{
		  _gl.glEndList();
		  _callListCompiled = true;
		}     

		((PGraphicsOpenGL)_parent.g).endGL();
  	}

  	

 
  	public void draw( GL gl )
  	{
	    // If the list is compiled and everything is ok, render
	    if( _callListID > 0 && _callListCompiled )
	    {
	    	_gl.glCallList( _callListID );
	    	
	    	return;
	    } 

	    if( _callListID > 0 && !_callListCompiled )
	    {
	        //_callListID = _gl.glGenLists( 1 ); 
	        _gl.glNewList( _callListID, GL.GL_COMPILE );  
	    }

	    
	    for( int mi=0; mi<_scene.meshes(); mi++ )
	    {
	    	Mesh3ds m = _scene.mesh( mi );


	    	Material mat;
	    	FaceMat3ds fmat;

	    	for( int fm=0; fm<m.faceMats(); fm++ )
	    	{
	    		//Face3ds[] faces = m.faceArray();    // list of all faces in mesh
	    		fmat = m.faceMat( fm );  // get current material's face
	    		try {
		    		mat = (Material)_materials.get( fmat.material() );
	    			//mat = (Material)_materials.get( fmat.material()+1 );
	    		} catch( IndexOutOfBoundsException e )
	    		{
	    			mat = null;
	    		}

	    
	    		if( _useMaterials )
	    		{
		    		// Enable color material
		    		if( mat != null )
		    		{
		    			_gl.glEnable( GL.GL_COLOR_MATERIAL );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, mat.ambient, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, mat.diffuse, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, new float[]{32}, 0 );
		    			_gl.glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, mat.specular, 0 );
		    		}
	
			        if( mat != null && mat.texId >= 0 )
			        {
				        _gl.glEnable( GL.GL_TEXTURE_2D );
				        _gl.glBindTexture( GL.GL_TEXTURE_2D, _textures.get( mat.texId ).getTextureObject() );
			        }
			        else
			        {
				        _gl.glBindTexture( GL.GL_TEXTURE_2D, 0 );
				        _gl.glDisable( GL.GL_TEXTURE_2D );
			        }
	    		}
	    		else
	    		{
	    			_gl.glEnable( GL.GL_COLOR_MATERIAL );	    			
			        _gl.glBindTexture( GL.GL_TEXTURE_2D, 0 );
			        _gl.glDisable( GL.GL_TEXTURE_2D );
	    		}
	    		
	    		
		        PVector uv0 = new PVector();
		        PVector uv1 = new PVector();
		        PVector uv2 = new PVector();

		        _gl.glBegin( GL.GL_TRIANGLES );
		        for( int fi=0; fi<fmat.faces(); fi++ )
		        {
		          int idx = fmat.face( fi );
		          Face3ds f = m.face( idx );
		          PVector n0 = _meshes[mi].vertexNormals[f.P0];
		          PVector n1 = _meshes[mi].vertexNormals[f.P1];
		          PVector n2 = _meshes[mi].vertexNormals[f.P2];
		          PVector v0 = _meshes[mi].vertices[f.P0];
		          PVector v1 = _meshes[mi].vertices[f.P1];
		          PVector v2 = _meshes[mi].vertices[f.P2];
		          if( m.texCoords() > 0 )
		          {
		            uv0 = _meshes[mi].texCoords[f.P0];
		            uv1 = _meshes[mi].texCoords[f.P1];
		            uv2 = _meshes[mi].texCoords[f.P2];
		          }
		
		          if( mat != null ) _gl.glColor4f( mat.diffuse[0], mat.diffuse[1], mat.diffuse[2], mat.diffuse[3] );
		          else  _gl.glColor4f( _r, _g, _b, _a ); //1, 1, 1, 1 );
		          
		          _gl.glNormal3f( n0.x, n0.y, n0.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f(uv0.x, uv0.y);
		          _gl.glVertex3f( v0.x, v0.y, v0.z );
		  
		          _gl.glNormal3f( n1.x, n1.y, n1.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f( uv1.x, uv1.y);
		          _gl.glVertex3f( v1.x, v1.y, v1.z );
		  
		          _gl.glNormal3f( n2.x, n2.y, n2.z ); 
		          if( m.texCoords() > 0 )  _gl.glTexCoord2f( uv2.x, uv2.y );
		          _gl.glVertex3f( v2.x, v2.y, v2.z );
		        }
		        _gl.glEnd();
		      }
		    }

    
		if( _callListID > 0 && !_callListCompiled )
		{
		  _gl.glEndList();
		  _callListCompiled = true;
		}     
  	}



  	public void init()
  	{
  		_meshes = new Mesh[ _scene.meshes() ];
  		
  		
  		System.out.println( "Cameras: " + _scene.cameras() );
  		if( _scene.cameras() > 0 )
  		{
	  		_cameras = new Camera[ _scene.cameras() ];
	  		
	  		//
	  		// Load cameras
	  		//
	  		for( int i=0; i<_scene.cameras(); i++ )
	  		{
	  			_cameras[i] = new Camera();
	  			_cameras[i]._name = _scene.camera(i).name();
	  			
	  			_cameras[i]._roll = _scene.camera(i).fixedRoll(); 
	  			
	  			_cameras[i]._up = new PVector( 0, 1, 0 );
	  			
	  			_cameras[i]._position = new PVector();
	  			_cameras[i]._position.x = _scene.camera(i).fixedPosition().X;
	  			_cameras[i]._position.y = _scene.camera(i).fixedPosition().Y;
	  			_cameras[i]._position.z = _scene.camera(i).fixedPosition().Z;
	  			
	  			_cameras[i]._target = new PVector();
	  			_cameras[i]._target.x = _scene.camera( i ).fixedTarget().X;
	  			_cameras[i]._target.y = _scene.camera( i ).fixedTarget().Y;
	  			_cameras[i]._target.z = _scene.camera( i ).fixedTarget().Z;  			
	  		}
  		}
  		
  		
  		System.out.println( "Lights: " + _scene.lights() );
  		if( _scene.lights() > 0 )
  		{
	  		_lights = new Light[ _scene.lights() ];

	  		//
	  		// Load lights
	  		//
	  		for( int i=0; i<_scene.lights(); i++ )
	  		{
	  			_lights[i] = new Light();
	  			_lights[i]._name = _scene.light(i).name();
	  			
	  			_lights[i]._position = new PVector();
	  			_lights[i]._position.x = _scene.light(i).fixedPosition().X;
	  			_lights[i]._position.y = _scene.light(i).fixedPosition().Y;
	  			_lights[i]._position.z = _scene.light(i).fixedPosition().Z;
	  			
	  			_lights[i]._target = new PVector();
	  			_lights[i]._target.x = _scene.light(i).fixedTarget().X;
	  			_lights[i]._target.y = _scene.light(i).fixedTarget().Y;
	  			_lights[i]._target.z = _scene.light(i).fixedTarget().Z;
	  			
	  			_lights[i]._color = new PVector();
	  			_lights[i]._color.x = _scene.light( i ).color().red();
	  			_lights[i]._color.y = _scene.light( i ).color().green();
	  			_lights[i]._color.z = _scene.light( i ).color().blue();  			
	  			
	  		}
  		}

  	}
  

  	//
  	// Compute scene vertex normals
  	//
  	public void computeNormals()
  	{
	  PVector vcenter = new PVector();
	  float vcounter = 0.0f;
	  for( int i=0; i<_scene.meshes(); i++ )
	  {
	      Mesh3ds m = _scene.mesh( i );
	      // Alloc memory
	      _meshes[i] = new Mesh();
	      _meshes[i].faceNormals = new PVector[ m.faces() ];
	      _meshes[i].faceMiddlePoint = new PVector[ m.faces() ];
	      _meshes[i].vertices = new PVector[ m.vertices() ];
	      _meshes[i].vertexNormals = new PVector[ m.vertices() ];
	      _meshes[i]._numTexCoords = 0;
	      _meshes[i].texCoords = new PVector[ m.vertices() ];
	      
	      PVector[] tmpFaceNormals = new PVector[ m.faces() ];
	      
	      // Compute face normals
	      for( int fi=0; fi<m.faces(); fi++ )
	      {
	        Face3ds f = m.face( fi );
	        Vertex3ds p0 = m.vertex(f.P0);
	        Vertex3ds p1 = m.vertex(f.P1);
	        Vertex3ds p2 = m.vertex(f.P2);
	        
	        // Compute face middle point
	        _meshes[i].faceMiddlePoint[fi] = new PVector();
	        _meshes[i].faceMiddlePoint[fi].x = (p0.X+p1.X+p2.X) / 3.0f;
	        _meshes[i].faceMiddlePoint[fi].y = (p0.Y + p1.Y + p2.Y) / 3.0f;
	        _meshes[i].faceMiddlePoint[fi].z = (p0.Z + p1.Z + p2.Z) / 3.0f;
	  
	        PVector v0 = new PVector(p0.X, p0.Y, p0.Z);
	        PVector v1 = new PVector(p1.X, p1.Y, p1.Z);
	        PVector v2 = new PVector(p2.X, p2.Y, p2.Z);
	  
	        PVector e0 = PVector.sub( v1, v0 );
	        PVector e1 = PVector.sub( v2, v0 );
	  
	        _meshes[i].faceNormals[fi] = e1.cross( e0 );
	        
	        // save a copy of the unnormalized face normal. used for average vertex normals
	        tmpFaceNormals[fi] = _meshes[i].faceNormals[fi].get();
	        
	        // normalize face normal
	        _meshes[i].faceNormals[fi].normalize();
	      }
	      
	      //
	      // Compute vertex normals.Take average from adjacent face normals.find coplanar faces or get weighted normals.
	      // One could also use the smooth groups from 3ds to compute normals, we'll see about that. 
	      //
	      //PVector v = new PVector();
	      PVector n = new PVector();
	      TexCoord3ds tc = new TexCoord3ds(0, 0);
	      for( int vi=0; vi<m.vertices(); vi++ )
	      {
	        Vertex3ds p = m.vertex( vi );
	        vcenter.add(p.X,p.Y,p.Z);
	        vcounter++;
	        if( m.texCoords() > 0 ) tc = m.texCoord( vi );
	        n.set( 0, 0, 0 );
	        float num = 0;
	        for( int fi=0; fi<m.faces(); fi++ )
	        {
	          Face3ds f = m.face( fi );
	          //        Vertex3ds p0 = m.vertex(f.P0);
	          //        Vertex3ds p1 = m.vertex(f.P1);
	          //        Vertex3ds p2 = m.vertex(f.P2);
	          if( vi == f.P0 || vi == f.P1 || vi == f.P2 )
	          {
	            num++;
	            n.add( tmpFaceNormals[fi] ); //_meshes[i].faceNormals[fi] );
	          }
	        }
	        if( num > 0 ) n.mult( 1.0f/(float)num );
	        n.normalize();
	        _meshes[i].vertexNormals[vi] = n.get();
	        
	        if( FLIPYZ )
	        {
	          float tmp = _meshes[i].vertexNormals[vi].y;
	          _meshes[i].vertexNormals[vi].y = -_meshes[i].vertexNormals[vi].z;
	          _meshes[i].vertexNormals[vi].z = tmp;
	        }
	        // Save vertex data      
	        if( FLIPYZ ) _meshes[i].vertices[vi] = new PVector( p.X, -p.Z, p.Y );
	        else _meshes[i].vertices[vi] = new PVector(p.X, p.Y, p.Z );
	        
	        // Save texcoord data
	        _meshes[i]._numTexCoords = m.texCoords();
	        if( m.texCoords() > 0 )
	        {
	          if( FLIPV ) _meshes[i].texCoords[vi] = new PVector( tc.U, 1.0f-tc.V, 0 );
	          else _meshes[i].texCoords[vi] = new PVector(tc.U, tc.V, 0 );
	        }
	      }
	      
	      tmpFaceNormals = null;
      
	  }
	  
	  if(vcounter>0.0)  vcenter.div(vcounter);
  	}
  	
  	
  	
  	public Camera[] getCameras()
  	{
  		if( _cameras.length == 0 )
  		{
  			System.err.println( "Cameras are not available on this scene" );
  			return null;
  		}
  		
  		return _cameras;
  	}
  	
  	
  	
  	public Camera getCamera( int idx )
  	{
  		if( _cameras.length == 0 )
  		{
  			System.err.println( "Cameras are not available on this scene" );
  			return null;
  		}

  		if( idx >= 0 && idx < _cameras.length )
  			return _cameras[idx];
  		
  		System.err.println( "Index for camera array is not valid" );
  		return null;
  	}

  	public Camera getCameraByName( String name )
  	{
  		if( _cameras.length == 0 )
  		{
  			System.err.println( "Cameras are not available on this scene" );
  			return null;
  		}

  		for( int i=0; i<_cameras.length; i++ )
  		{
  			if( _cameras[i]._name.equals(name) )
  				return _cameras[i];
  		}
  		
  		return null;
  	}


  	
  	public Light[] getLights()
  	{
  		if( _lights.length == 0 )
  		{
  			System.err.println( "Cameras are not available on this scene" );
  			return null;
  		}
  		
  		return _lights;
  	}
  	
  	
  	
  	public Light getLight( int idx )
  	{
  		if( _lights.length == 0 )
  		{
  			System.err.println( "Lights are not available on this scene" );
  			return null;
  		}

  		if( idx >= 0 && idx < _lights.length )
  			return _lights[idx];
  		
  		System.err.println( "Index for light array is not valid" );
  		return null;
  	}

  	
  	public Light getLightByName( String name )
  	{
  		if( _lights.length == 0 )
  		{
  			System.err.println( "Lights are not available on this scene" );
  			return null;
  		}

  		for( int i=0; i<_lights.length; i++ )
  		{
  			if( _lights[i]._name.equals(name) )
  				return _lights[i];
  		}
  		
  		return null;
  	}

  	
  	

  	public void useMaterial( boolean f )
  	{
  		_useMaterials = f;
  	}

  	
  	public void setGlobalColor( float r, float g, float b, float a )
  	{
  		_r = r;
  		_g = g;
  		_b = b;
  		_a = a;
  	}

  
  	public static String sketchPath()
  	{
	  try 
	  {
		  return System.getProperty( "user.dir" );
	  } 
	  catch (Exception e) { }  // may be a security problem

	  return null;
  	}


  	String dataPath( String where )
  	{
	  if (new File(where).isAbsolute()) return where;
	  return sketchPath() + File.separator + "data" + File.separator + where;
  	}

}
