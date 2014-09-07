import java.nio.*; 
import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;  
import com.sun.opengl.cg.*; 
import com.sun.opengl.util.*; 

class CG 
{ 
  GL _gl; 
  
  String _name;  // name for this shader
  
  boolean vertexShaderSupported;  
  boolean fragmentShaderSupported; 
  boolean vertexShaderEnabled; 
  boolean fragmentShaderEnabled; 
  CGcontext context; 
  CGprogram vertexProgram;  
  CGprogram fragmentProgram; 
  
  boolean _useEffect;
  CGeffect effect;
  CGtechnique technique;
  CGpass pass;

  int vertexProfile; 
  int fragmentProfile; 


  CGparameter DecalTexture;
  CGparameter WorldViewProj;
  CGparameter WorldIT;
  CGparameter LightPos;
  CGparameter CameraPos;

  CG()
  { 
    _name = null;
    
    _gl = vgl.gl();
    String extensions = _gl.glGetString(GL.GL_EXTENSIONS); 
    vertexShaderSupported = extensions.indexOf("GL_ARB_vertex_shader") != -1; 
    fragmentShaderSupported = extensions.indexOf("GL_ARB_fragment_shader") != -1;     

    context = CgGL.cgCreateContext(); 
    CgGL.cgGLRegisterStates( context );
    CgGL.cgGLSetManageTextureParameters( context, true );

    //CgGL.cgGLSetOptimalOptions( CgGL.CG_PROFILE_ARBVP1 );
    //CgGL.cgGLSetOptimalOptions( CgGL.CG_PROFILE_ARBFP1 );

    vertexProgram = null; 
    fragmentProgram = null; 
    
    _useEffect = false;
    
    effect = null;
    technique = null;
    pass = null;
  }
    
  void checkErrors( String situation )
  {
    int[] error = { 0 };
    
    String string = CgGL.cgGetLastErrorString( error, 0 );
  
    if( error[0] != CgGL.CG_NO_ERROR ) 
    {
      println( _name + ", " + situation + ", " +  string );
      if( error[0] == CgGL.CG_COMPILER_ERROR ) 
      {
        println( CgGL.cgGetLastListing(context) );
      }
    }
  }

  void checkProfiles()
  {
    // VERTEX PROFILES
    if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_ARBVP1) )
    {
      vertexProfile = CgGL.CG_PROFILE_ARBVP1;
      println( "CG_PROFILE_ARBVP1 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_VP40) )
    {
      vertexProfile = CgGL.CG_PROFILE_VP40;
      println( "CG_PROFILE_VP40 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_VP30) )
    {
      vertexProfile = CgGL.CG_PROFILE_VP30;
      println( "CG_PROFILE_VP30 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_VP20) )
    {
      vertexProfile = CgGL.CG_PROFILE_VP20;
      println( "CG_PROFILE_VP20 supported" );
    }
    
    // FRAGMENT PROFILES
    if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_ARBFP1) )
    {
      fragmentProfile = CgGL.CG_PROFILE_ARBFP1;
      println( "CG_PROFILE_ARBFP1 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_FP40) )
    {
      fragmentProfile = CgGL.CG_PROFILE_FP40;
      println( "CG_PROFILE_FP40 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_FP30) )
    {
      fragmentProfile = CgGL.CG_PROFILE_FP30;
      println( "CG_PROFILE_FP30 supported" );
    }
    else if( CgGL.cgGLIsProfileSupported(CgGL.CG_PROFILE_FP20) )
    {
      fragmentProfile = CgGL.CG_PROFILE_FP20;
      println( "CG_PROFILE_FP20 supported" );
    }
  }    

  void loadFXFromFile( String file )
  { 
    int error = 0;

    //checkProfiles();

//    loadFragmentShader( file ); 
    _name = file;

    println( "\nLoading FX: " + file );
    String str;
    
    effect = CgGL.cgCreateEffectFromFile( context, dataPath(file), null ); 
//    String shaderSource = join(loadStrings(file), "\n");         
//    effect = CgGL.cgCreateEffect( context, shaderSource, null ); 
//    error = CgGL.cgGetError(); 
//    println( CgGL.cgGetErrorString(error) ); 
//    println( CgGL.cgGetLastListing(context) ); 
    
    if( effect == null )
    {
      //str = CgGL.cgGetLastListing( context );
      //println( str );
      println( "Cg error(s) in " + file ); 
      error = CgGL.cgGetError(); 
      println( CgGL.cgGetErrorString(error) ); 
      println( CgGL.cgGetLastListing(context) ); 

      println( "fx file not loaded correctly" );
      exit();
    }

    technique = CgGL.cgGetFirstTechnique( effect );
    while( technique != null )
    {
      //if( CgGL.cgValidateTechnique(technique) == false )
        //println( "Technique %s did not validate. Skipping.\n" + CgGL.cgGetTechniqueName(technique) );
      println( "technique '" + CgGL.cgGetTechniqueName(technique) + "' " +  "validate: " + CgGL.cgValidateTechnique(technique) ); //CgGL.cgIsTechniqueValidated(technique) );
      technique = CgGL.cgGetNextTechnique( technique );
    }

    
    // Set parameters    
    WorldViewProj = CgGL.cgGetNamedEffectParameter( effect, "worldViewProj" );
    WorldIT = CgGL.cgGetNamedEffectParameter( effect, "matWorld" );
    LightPos = CgGL.cgGetNamedEffectParameter( effect, "lightPos" );
    CameraPos = CgGL.cgGetNamedEffectParameter( effect, "cameraPos" );
    DecalTexture = CgGL.cgGetNamedEffectParameter( effect, "ColorSampler" );
    
    _useEffect = true;
  } 

  void createProgramFromEffect( int profile, String entry )
  {
    if( profile == 0 )
    {
      vertexProgram = CgGL.cgCreateProgramFromEffect( effect, vertexProfile, entry, null );
      if( vertexProgram == null )  println( "vertexprogram is null" );
    }
    else
    {
      fragmentProgram = CgGL.cgCreateProgramFromEffect( effect, fragmentProfile, entry, null );
      if( fragmentProgram == null )  println( "fragmentprogram is null" );
    }
  }
  
/*  void updateProgramParameters()
  {
    CgGL.cgUpdateProgramParameters( vertexProgram );
    CgGL.cgUpdateProgramParameters( fragmentProgram );
  }*/
  
  void enableFragmentProfile()
  {
    CgGL.cgGLEnableProfile( fragmentProfile );
  }
  
  void getTechnique( String name )
  {
    technique = CgGL.cgGetNamedTechnique( effect, name );    
  }

  void getFirstTechnique()
  {
    technique = CgGL.cgGetFirstTechnique( effect );    
  }

  CGpass getTechniqueFirstPass( String name )
  {
    technique = CgGL.cgGetNamedTechnique( effect, name );    
    if( technique == null ) println( "technique '" + name + "' is null" );

    return CgGL.cgGetFirstPass( technique );
  }

  void startPass()
  {    
    //CGpass pass = CgGL.cgGetFirstPass( technique );
    CgGL.cgSetPassState( pass );
  }

  void endPass()
  {
    CgGL.cgResetPassState( pass );
    //_gl.glDisable( GL.GL_FRAGMENT_PROGRAM_ARB );
    //_gl.glDisable( GL.GL_VERTEX_PROGRAM_ARB );
  }


  void loadVertexShader(String file) 
  {
    _useEffect = false;
    
    vertexProfile = CgGL.cgGLGetLatestProfile( CgGL.CG_GL_VERTEX );
    if (vertexProfile == CgGL.CG_PROFILE_UNKNOWN) println("Vertex profile could not be created"); 
    else CgGL.cgGLSetOptimalOptions( vertexProfile );

    String shaderSource = join(loadStrings(file), "\n");    
    vertexProgram = CgGL.cgCreateProgram(context, CgGL.CG_SOURCE, shaderSource, vertexProfile, null, null); 
    checkErrorInfo(file, vertexProgram); 
    vertexShaderEnabled = (vertexProgram != null) && (vertexProfile != CgGL.CG_PROFILE_UNKNOWN); 
  }


  void loadFragmentShader(String file) 
  { 
    _useEffect = false;
    
    fragmentProfile = CgGL.cgGLGetLatestProfile( CgGL.CG_GL_FRAGMENT ); 
    if (fragmentProfile == CgGL.CG_PROFILE_UNKNOWN) println("Fragment profile could not be created"); 
    else CgGL.cgGLSetOptimalOptions( fragmentProfile ); 
    
    String shaderSource = join(loadStrings(file), "\n"); 
    fragmentProgram = CgGL.cgCreateProgram(context, CgGL.CG_SOURCE, shaderSource, fragmentProfile, null, null); 
    checkErrorInfo(file, fragmentProgram); 
    fragmentShaderEnabled = (fragmentProgram != null) && (fragmentProfile != CgGL.CG_PROFILE_UNKNOWN); 
  } 

  void enableTextureParameter( String paramName )
  {
    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) CgGL.cgGLEnableTextureParameter( param );
    else println( "Cant find texture parameter" );
  }

  void disableTextureParameter( String paramName )
  {
    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) CgGL.cgGLDisableTextureParameter( param );
    else println( "Cant find texture parameter" );
  }

  void setTextureParameter( String paramName, int val )
  {
    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) CgGL.cgGLSetTextureParameter( param, val );
    else println( "Cant find texture parameter" );

    CgGL.cgSetSamplerState( param );
    //CgGL.cgGLEnableTextureParameter( param );
  }
  
  void setParameter1f( String paramName, float val )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) 
      CgGL.cgGLSetParameter1f( param, val );
    else println( "param1f is null" ); 
    
  }

  void setParameter2f( String paramName, float x, float y )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) 
      CgGL.cgGLSetParameter2f( param, x, y );
    else println( "param2f is null" ); 
  }
  
  void setParameter3f( String paramName, float x, float y, float z )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) 
      CgGL.cgGLSetParameter3f( param, x, y, z );
    else println( "param3f is null" ); 
  }
  
  void setParameter3f( String paramName, Vector3 v )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) 
      CgGL.cgGLSetParameter3f( param, v.x, v.y, v.z );
    else println( "param3f is null" ); 
  }

  void setParameter4f( String paramName, float x, float y, float z, float w )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    //if( !CgGL.cgIsParameter(param) ) println( "param4f is not valid" );
    if( param != null ) 
      CgGL.cgGLSetParameter4f( param, x, y, z, w );
    else println( "param4f is null" ); 
  }

  void setParameter4f( String paramName, Vector4 v )
  {    
    CGparameter param = null;
    param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    if( param != null ) 
      CgGL.cgGLSetParameter4f( param, v.x, v.y, v.z, v.w );
    else println( "param4f is null" );     
  }

  void setParameter4x4fBySemantic( String semanticName, int matrix, int matrixType )
  {
    CGparameter param = CgGL.cgGetEffectParameterBySemantic( effect, semanticName );
    if( param != null ) 
      CgGL.cgGLSetStateMatrixParameter( param, matrix, matrixType );
    else println( "matrix semantic param is null" );
  }

  void setParameter4x4f( String paramName, int matrix, int matrixType )
  {
    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    //if( !CgGL.cgIsParameter(param) ) println( "matrix4x4f param is not valid" );
    if( param != null ) 
      CgGL.cgGLSetStateMatrixParameter( param, matrix, matrixType );
    else println( "matrix param is null" );
  }

  void setParameter4x4f( String paramName, Matrix m )
  {
    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    //if( !CgGL.cgIsParameter(param) ) println( "matrix4x4f param is not valid" );
    if( param != null )
      //CgGL.cgGLSetParameterArray4f( param, 0, 16, m.getFloatBuffer() );
      CgGL.cgGLSetMatrixParameterfr( param, m._M, 0 );//m.getFloatBuffer() );
    else println( "matrix param is null" );
  }

  Matrix getParameter4x4f( String paramName )
  {
    Matrix m = new Matrix();

    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    //if( !CgGL.cgIsParameter(param) ) println( "get matrix4x4f param is not valid" );
    if( param != null ) 
      CgGL.cgGLGetMatrixParameterfr( param, m.getFloatBuffer() );
    else println( "matrix param is null" );
    
    return m;
  }

  Vector4 getParameter4f( String paramName )
  {
    float[] vt = new float[4];

    CGparameter param = CgGL.cgGetNamedEffectParameter( effect, paramName );
    //if( !CgGL.cgIsParameter(param) ) println( "get matrix4x4f param is not valid" );
    if( param != null ) 
      CgGL.cgGLGetParameter4f( param, vt, 0 );
    else println( "matrix param is null" );
    
    return new Vector4( vt[0], vt[1], vt[2], vt[3] );
  }

  void setMatrices()
  {
    setWorldViewProj();
    setWorldIT();
  }
  
  void setWorldViewProj()
  {
    CgGL.cgGLSetStateMatrixParameter( WorldViewProj, CgGL.CG_GL_MODELVIEW_PROJECTION_MATRIX, CgGL.CG_GL_MATRIX_IDENTITY );
  }

  void setWorldIT()
  {
    CgGL.cgGLSetStateMatrixParameter( WorldIT, CgGL.CG_GL_MODELVIEW_MATRIX, CgGL.CG_GL_MATRIX_INVERSE_TRANSPOSE );
  }

  void setLightPos( float x, float y, float z, float w )
  {
    CgGL.cgGLSetParameter4f( LightPos, x, y, z, w );
  }

  void setCameraPos( float x, float y, float z )
  {
    CgGL.cgGLSetParameter3f( CameraPos, x, y, z );
  }

  void setDecalTexture( int id )
  {
    CgGL.cgGLSetTextureParameter( DecalTexture, id );
  }



  void checkErrorInfo( String fn, CGprogram program ) 
  { 
    if (program == null) 
    { 
      int error = CgGL.cgGetError(); 
      println("Cg error(s) in " + fn); 
      println(CgGL.cgGetErrorString(error)); 
      println(CgGL.cgGetLastListing(context)); 
    } 
  } 
  
  void release()
  {
    CgGL.cgDestroyEffect( effect );
    CgGL.cgDestroyContext( context );
  }
}  
