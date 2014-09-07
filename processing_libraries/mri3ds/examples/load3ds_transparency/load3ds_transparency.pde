/*
	Mri3ds v1.2 Example
  
	Loads a .3ds scene using V3dsScene object from the library itself.
	For beginners this is the way to go, if you're more into expert mode, then check out the other examples and use the data structures as you please.
  
	model is the free Sponza Atrium by Marko Dabrovic:
	http://hdri.cgtechniques.com/~sponza/
	Downloads: http://hdri.cgtechniques.com/~sponza/files/  
*/

import javax.media.opengl.*;
import processing.opengl.*;
import mri.*;

V3dsScene vscene;


void setup()
{
  size( 800, 600, OPENGL);

  hint( ENABLE_OPENGL_4X_SMOOTH );
  smooth();
  
  frameRate( 60 );

  vscene = new V3dsScene( this, "test.3ds" );

  V3dsScene.Camera cam = vscene.getCamera( 0 );
  println( cam.getPosition().toString() );
  println( cam.getTarget().toString() );

  V3dsScene.Light light = vscene.getLight( 0 );
  println( light.getPosition().toString() );
  println( light.getTarget().toString() );
  light = vscene.getLight( 1 );
  println( light.getPosition().toString() );
  println( light.getTarget().toString() );
  
  // use this one in case you want to pass a custom GL object 
  //GL gl = ((PGraphicsOpenGL)g).beginGL();
  //((PGraphicsOpenGL)g).endGL();
  //vscene = new V3dsScene( gl, dataPath("sponza.3ds") );
}



void draw()
{
  float time = millis() * 0.001;
  
  background( 13 );
  perspective( PI*0.25, 4.0/3.0, 1, 5000 );
//  camera( 0, -200, 600, 0, 0, 0, 0, 1, 0 );//cam_pos.x, cam_pos.y, cam_pos.z, cam_tar.x, cam_tar.y, cam_tar.z, cam_up.x, cam_up.y, cam_up.z );
  camera( 0, 50, 116, 0, -3*sin(time)*2, -8, 0, 1, 0 );//cam_pos.x, cam_pos.y, cam_pos.z, cam_tar.x, cam_tar.y, cam_tar.z, cam_up.x, cam_up.y, cam_up.z );
//  scale( 1, -1, 1 );

  // setup light. to do correct lighting you need to set it before any world transformations
  GL _gl = ((PGraphicsOpenGL)g).beginGL();
  setupLight( _gl, new float[]{0, 5, 200}, 1 );

  // in case you want to use a custom GL object (usually for eclipse projects)
  //_gl.glRotatef( 10*time, 0, 1, 0 );
  //vscene.draw( _gl );

  ((PGraphicsOpenGL)g).endGL();


  rotateY( radians(10*time) );
  vscene.draw();
}




// val is 0 or 1. 0 = directional light, 1 = point light
void setupLight( GL g, float[] pos, float val )
{
  float[] light_emissive = { 0.0f, 0.0f, 0.0f, 1 };
  float[] light_ambient = { 0.0f, 0.0f, 0.0f, 1 };
  float[] light_diffuse = { 1.0f, 1.0f, 1.0f, 1.0f };
  float[] light_specular = { 1.0f, 1.0f, 1.0f, 1.0f };  
  float[] light_position = { pos[0], pos[1], pos[2], val };  

  g.glLightfv ( GL.GL_LIGHT1, GL.GL_AMBIENT, light_ambient, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_DIFFUSE, light_diffuse, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_SPECULAR, light_specular, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_POSITION, light_position, 0 );  
  g.glEnable( GL.GL_LIGHT1 );
  g.glEnable( GL.GL_LIGHTING );
  
//  g.glEnable( GL.GL_COLOR_MATERIAL );
}  

