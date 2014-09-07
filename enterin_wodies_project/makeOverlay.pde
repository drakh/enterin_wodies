GLModel makeOverlay()
{
  GLModel m=new GLModel(this, 4, GLModel.QUADS, GLModel.STATIC);
  m.beginUpdateVertices();
  m.updateVertex(0, -width, -height, cam_z+50);
  m.updateVertex(1, width, -height, cam_z+50);
  m.updateVertex(2, width, height, cam_z+50);
  m.updateVertex(3, -width, height, cam_z+50);    
  m.endUpdateVertices();
  m.initColors();
  m.setColors(0, 0, 0, 50);
  m.setBlendMode(BLEND);
  return m;
}

