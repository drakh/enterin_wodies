class V3DSScene
{
  static final boolean FLIPV = true;
  static final boolean FLIPYZ = false;
  
  
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
  

  boolean _useMaterial;
  
  Scene3ds _scene;  // from mri lib
  ArrayList _materials;
  ArrayList _textures;
  Mesh[] _meshes;

 
 
  V3DSScene( String filename )
  {
    // Load scene
    TextDecode3ds decode = new TextDecode3ds();
    int level = Scene3ds.DECODE_ALL; //, DECODE_USED_PARAMS, DECODE_USED_PARAMS_AND_CHUNKS
    //int level = Scene3ds.DECODE_USED_PARAMS_AND_CHUNKS;
    try 
    {
      File f = new File( dataPath(filename) );
      _scene = new Scene3ds( f, decode, level );
    }
    catch( Exception3ds e )
    {
      println( "failed to load 3ds: " + e );
      // Something went wrong!
      exit();
    }
    
    // Init stuff needed
    // TODO! Everything should be init here. not in computeNormals. computeNormals should do what the name says. nothing else
    init();
  
    // Compute normals for our scene
    computeNormals();
    
    // Alloc for materials+textures
    _textures = new ArrayList();
    _materials = new ArrayList();
    int texIndex=0; //the order of texture file in array list textures.
  
	    Material matPrev = null;
	    for( int m=0; m<_scene.materials(); m++ )
	    {
	    	Material3ds mat = _scene.material( m );
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
  
  void draw()
  {
    for( int mi=0; mi<_scene.meshes(); mi++ )
    {
      Mesh3ds m = _scene.mesh( mi );

  
      XTexture tex;
      Material mat;
      FaceMat3ds fmat;
      FloatBuffer fb;
      
      for( int fm=0; fm<m.faceMats(); fm++ )
      {
        Face3ds[] faces = m.faceArray();    // list of all faces in mesh
        fmat = m.faceMat( fm );  // get current material's face
	    		try {
		    		mat = (Material)_materials.get( fmat.material() );
	    			//mat = (Material)_materials.get( fmat.material()+1 );
	    		} catch( IndexOutOfBoundsException e )
	    		{
	    			mat = null;
	    		}

        if( _useMaterial )
        {
          // Enable color material
  	if( mat != null )
  	{        
          vgl.gl().glEnable( GL.GL_COLOR_MATERIAL );
          fb = FloatBuffer.wrap( new float[]{mat.ambient.x, mat.ambient.y, mat.ambient.z, mat.ambient.w} );
          vgl.gl().glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, fb );
          fb = FloatBuffer.wrap( new float[]{mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w} );
          vgl.gl().glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, fb );
          fb = FloatBuffer.wrap( new float[]{32} );
          vgl.gl().glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, fb );
          fb = FloatBuffer.wrap( new float[]{mat.specular.x, mat.specular.y, mat.specular.z, mat.specular.w} );
          vgl.gl().glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, fb );
  	}
          
          vgl.fill( 1 );
          
          if( mat != null && mat.texId >= 0 )
          {
            tex = (XTexture)_textures.get( mat.texId );
            tex.enable();
          }
          else
          {
            vgl.enableTexture( false );
            tex = null;
          }
        }
        else
        {
          vgl.gl().glEnable( GL.GL_COLOR_MATERIAL );
          vgl.enableTexture( false );
        }
        
        
        Vector3 uv0 = new Vector3();
        Vector3 uv1 = new Vector3();
        Vector3 uv2 = new Vector3();
    
        vgl.gl().glBegin( GL.GL_TRIANGLES );
        for( int fi=0; fi<fmat.faces(); fi++ )
        {
          int idx = fmat.face( fi );
          Face3ds f = m.face( idx );
          Vector3 n0 = _meshes[mi].vertexNormals[f.P0];
          Vector3 n1 = _meshes[mi].vertexNormals[f.P1];
          Vector3 n2 = _meshes[mi].vertexNormals[f.P2];
          Vector3 v0 = _meshes[mi].vertices[f.P0];
          Vector3 v1 = _meshes[mi].vertices[f.P1];
          Vector3 v2 = _meshes[mi].vertices[f.P2];
          if( m.texCoords() > 0 )
          {
            uv0 = _meshes[mi].texCoords[f.P0];
            uv1 = _meshes[mi].texCoords[f.P1];
            uv2 = _meshes[mi].texCoords[f.P2];
          }
  
          if( mat != null ) vgl.gl().glColor4f( mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w );
	  else  vgl.gl().glColor4f( 1, 1, 1, 1 );
          //vgl.gl().glColor4f( mat.diffuse.x, mat.diffuse.y, mat.diffuse.z, mat.diffuse.w );
          
          vgl.gl().glNormal3f(n0.x, n0.y, n0.z ); 
          if( m.texCoords() > 0 )  vgl.gl().glTexCoord2f(uv0.x, uv0.y);
          vgl.gl().glVertex3f( v0.x, v0.y, v0.z );
  
          vgl.gl().glNormal3f(n1.x, n1.y, n1.z ); 
          if( m.texCoords() > 0 )  vgl.gl().glTexCoord2f( uv1.x, uv1.y);
          vgl.gl().glVertex3f( v1.x, v1.y, v1.z );
  
          vgl.gl().glNormal3f(n2.x, n2.y, n2.z ); 
          if( m.texCoords() > 0 )  vgl.gl().glTexCoord2f( uv2.x, uv2.y );
          vgl.gl().glVertex3f( v2.x, v2.y, v2.z );
        }
        vgl.gl().glEnd();
      }
    }
  }


  void init()
  {
    _meshes = new Mesh[ _scene.meshes() ];
  }
  

  //
  // Compute scene vertex normals
  //
  void computeNormals()
  {
    Vector3 vcenter=new Vector3();
    float vcounter=0.0;
    for( int i=0; i<_scene.meshes(); i++ )
    {
      Mesh3ds m = _scene.mesh( i );
      // Alloc memory
      _meshes[i] = new Mesh();
      _meshes[i].faceNormals = new Vector3[ m.faces() ];
      _meshes[i].faceMiddlePoint = new Vector3[ m.faces() ];
      _meshes[i].vertices = new Vector3[ m.vertices() ];
      _meshes[i].vertexNormals = new Vector3[ m.vertices() ];
      _meshes[i]._numTexCoords = 0;
      _meshes[i].texCoords = new Vector3[ m.vertices() ];
      
      Vector3[] tmpFaceNormals = new Vector3[ m.faces() ];
      
      // Compute face normals
      for( int fi=0; fi<m.faces(); fi++ )
      {
        Face3ds f = m.face( fi );
        Vertex3ds p0 = m.vertex(f.P0);
        Vertex3ds p1 = m.vertex(f.P1);
        Vertex3ds p2 = m.vertex(f.P2);
        
        // Compute face middle point
        _meshes[i].faceMiddlePoint[fi] = new Vector3();
        _meshes[i].faceMiddlePoint[fi].x = (p0.X+p1.X+p2.X) / 3.0;
        _meshes[i].faceMiddlePoint[fi].y = (p0.Y + p1.Y + p2.Y) / 3.0;
        _meshes[i].faceMiddlePoint[fi].z = (p0.Z + p1.Z + p2.Z) / 3.0;
  
        Vector3 v0 = new Vector3(p0.X, p0.Y, p0.Z);
        Vector3 v1 = new Vector3(p1.X, p1.Y, p1.Z);
        Vector3 v2 = new Vector3(p2.X, p2.Y, p2.Z);
  
        Vector3 e0 = Vector3.sub( v1, v0 );
        Vector3 e1 = Vector3.sub( v2, v0 );
  
        _meshes[i].faceNormals[fi] = Vector3.cross( e1, e0 );
        
        // save a copy of the unnormalized face normal. used for average vertex normals
        tmpFaceNormals[fi] = _meshes[i].faceNormals[fi].copy();
        
        // normalize face normal
        _meshes[i].faceNormals[fi].normalize();
      }
      
      //
      // Compute vertex normals.Take average from adjacent face normals.find coplanar faces or get weighted normals.
      // One could also use the smooth groups from 3ds to compute normals, we'll see about that. 
      //
      Vector3 v = new Vector3();
      Vector3 n = new Vector3();
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
        if( num > 0 ) n.mul( 1.0/(float)num );
        n.normalize();
        _meshes[i].vertexNormals[vi] = n.copy();
        
        if( FLIPYZ )
        {
          float tmp = _meshes[i].vertexNormals[vi].y;
          _meshes[i].vertexNormals[vi].y = -_meshes[i].vertexNormals[vi].z;
          _meshes[i].vertexNormals[vi].z = tmp;
        }
        // Save vertex data      
        if( FLIPYZ ) _meshes[i].vertices[vi] = new Vector3( p.X, -p.Z, p.Y );
        else _meshes[i].vertices[vi] = new Vector3(p.X, p.Y, p.Z );
        
        // Save texcoord data
        _meshes[i]._numTexCoords = m.texCoords();
        if( m.texCoords() > 0 )
        {
          if( FLIPV ) _meshes[i].texCoords[vi] = new Vector3( tc.U, 1.0-tc.V, 0 );
          else _meshes[i].texCoords[vi] = new Vector3(tc.U, tc.V, 0 );
        }
      }
      
      tmpFaceNormals = null;
      
    }
    if(vcounter>0.0)  vcenter.div(vcounter);
  }

}
