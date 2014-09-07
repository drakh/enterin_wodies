/*
  For this example i have wrapped the data structures into a class called V3DSScene.
  For the near future this shall be moved into the library, makes alot more sense that way, meanwhile it is here so users can play/change freely.
  
  Load a scene from a .3ds file  
*/

import javax.media.opengl.*;
import processing.opengl.*;
import mri.v3ds.*;
import vitamin.*;
import vitamin.math.*;

VGL vgl;
V3DSScene vscene;


void setup()
{
  size(800,600, OPENGL);
//  frame.setLocation(0, 0);

  hint( ENABLE_OPENGL_4X_SMOOTH );
  smooth();

  vgl = new VGL( this );
 
  vscene = new V3DSScene( "Beast.3ds" );
  vscene._useMaterial = true;
}


void draw()
{
  float time = millis() * 0.001;
  
  vgl.begin();  
  vgl.background( 0.7 );

  vgl.perspective( 45, 4.0/3.0, 1, 5000 );
  vgl.camera( 0, 200, 500+mouseY, 0, 0, 0, 0, 1, 0 ); //0, 100+mouseY, (mouseX-width*0.5), 0, 0, 0, 0, 1, 0 );
  
  // setup light. to do correct lighting you need to set it before any world transformations
  setupLight( new Vector3(10, 510, 400), 1 );  
  
  vgl.rotateY( mouseX );
  
  // render scene
//  vgl.fill( 1, 0, 0 );
  vgl.gl().glMaterialfv( GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[]{1, 0, 0, 1}, 0 );
  
  vscene.draw();

  vgl.end();
}


public void stop()
{
  super.stop();
}





// val is 0 or 1. 0 = directional light, 1 = point light
void setupLight( Vector3 pos, float val )
{
  GL g = vgl.gl();

  float[] light_emissive = { 0.0f, 0.0f, 0.0f, 1 };
  float[] light_ambient = { 0.10f, 0.10f, 0.10f, 1 };
  float[] light_diffuse = { 1.0f, 1.0f, 1.0f, 1.0f };
  float[] light_specular = { 1.0f, 1.0f, 1.0f, 1.0f };  
  float[] light_position = { pos.x, pos.y, pos.z, val };  

  g.glLightfv ( GL.GL_LIGHT1, GL.GL_AMBIENT, light_ambient, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_DIFFUSE, light_diffuse, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_SPECULAR, light_specular, 0 );
  g.glLightfv ( GL.GL_LIGHT1, GL.GL_POSITION, light_position, 0 );  
  g.glEnable( GL.GL_LIGHT1 );
  g.glEnable( GL.GL_LIGHTING );
  g.glEnable( GL.GL_COLOR_MATERIAL );
}  

