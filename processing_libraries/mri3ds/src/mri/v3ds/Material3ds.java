package mri.v3ds;

/**
 * Material definition. Only the material name is loaded from the
 * 3ds-file.
 */
public class Material3ds
{
  // Material name
  String mName    = "";

  // Material Filename
  String mMapName = "";

  // Material diffuse color
  Color3ds mDiffuse = new Color3ds();

  // Material ambient color
  Color3ds mAmbient = new Color3ds();

  // Material specular color
  Color3ds mSpecular = new Color3ds();
  
  float _shininess = 0;
  
  float _transparency = 1.0f;

  /**
   * Get material name.
   *
   * @return material name
   */
  public String name() {
    return mName;
  }

  /**
   * Get material filename.
   *
   * @return material filename
   */
  public String mapName() {
    return mMapName;
  }

  /**
   * Get diffuse color.
   *
   * @return material diffuse color
   */
  public Color3ds diffuse() {
    return mDiffuse;
  }

  /**
   * Get ambient color.
   *
   * @return material ambient color
   */
  public Color3ds ambient() {
    return mAmbient;
  }

  /**
   * Get specular color.
   *
   * @return material specular color
   */
  public Color3ds specular() {
    return mSpecular;
  }

  public float transparency()
  {
	  return _transparency;
  }
}