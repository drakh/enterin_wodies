import ddf.minim.*;
import SimpleOpenNI.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;
import mri.*;
import mri.v3ds.*;

Minim minim;
BgPlayer pl;

float p=0;//timer for shader
PApplet app = this;

float cam_z=1000;
float rad=1000;//inside radius of interaction
//float rad=5000;//inside radius of interaction
float stoprad=1800;//if tracked user is outside this radius we will stop skeleton tracking
//float stoprad=5000;//if tracked user is outside this radius we will stop skeleton tracking

float track_rad=500;//inside this radius we will begin to track skeleton

Cam cam;
closeArea cA;
GLModel oL;
int trackUser=0;

GLSLShader shader;
GLGraphics renderer;
GL gl;

Boolean dopsi=false;
int startTUser=0;
int actUser=0;

int shot;
Boolean[] stages= {
  false, false, false, false, false, false, false
};

boolean ppos=false;
boolean prevall=false;
boolean KinectEnabled=false;
textRenderer tR;
bodyPicture bpic;//body picture
psiRender ppic;
touchDetect tD;

SimpleOpenNI context;
Boolean detecting_pose=false;

int sw=640;
int sh=480;

//int sw=1024;
//int sh=768;

PVector p_area;//person area

int cm=0;
float paint_t;
Scene3ds scene;
bodyParts body;

public void init() {
  // to make a frame not displayable, you can
  // use frame.removeNotify()

  frame.removeNotify();
  frame.setUndecorated(true);

  // addNotify, here i am not sure if you have 
  // to add notify again.  
  frame.addNotify();
  super.init();
}

void setup()
{
  frame.setLocation(2000, 0);
   //frame.setLocation(160, 0);
  size(sw, sh, GLConstants.GLGRAPHICS);
  minim = new Minim(this);
  pl=new BgPlayer();

  frameRate(30);
  renderer = (GLGraphics)g;
  renderer.beginGL();
  gl = renderer.gl;
  renderer.endGL();

  /*<load bodies from 3ds>*/
  TextDecode3ds decode = new TextDecode3ds();
  int level = Scene3ds.DECODE_ALL;
  try 
  {
    File f = new File( dataPath("model/body.3ds") );
    scene = new Scene3ds( f, decode, level );
  }
  catch( Exception3ds e )
  {
    println( "failed to load 3ds: " + e );
    exit();
  }
  body=new bodyParts(scene);
  /*</load bodies from 3ds>*/


  shader = new GLSLShader(this, "glsl/vert.glsl", "glsl/frag.glsl");
  tR=new textRenderer(sw, sh);
  bpic=new bodyPicture();
  ppic=new psiRender();
  tD=new touchDetect();
  cA=new closeArea();
  bpic.setTexture(0);
  oL=makeOverlay();

  p_area=new PVector(0, 0, 2600);
  paint_t=(p_area.z-300);


  /*<setting up the kinect>*/
  context = new SimpleOpenNI(this);
  context.setMirror(true);
  KinectEnabled=context.enableDepth();
  if (KinectEnabled)
  {
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  }

  //context.enableScene();
  //context.update();
  /*</setting up the kinect>*/

  background(0);
  cam=new Cam(0, 0, cam_z, 0, 0, cam_z+1000);
  pl.fadeIn(0);
}


void draw()
{
  if (KinectEnabled)
  {
    context.update();
  }
  float d;
  float  confidence;


  PVector lhp=new PVector();//left hand position
  PVector rhp=new PVector();//right hand position
  PVector trp=new PVector();//torso position

  boolean cpos=false;
  boolean call=true;
  for (int i=0;i<stages.length;i++)
  {
    if (stages[i]==false) call=false;
  }

  renderer.beginGL();
  gl.glShadeModel(GL.GL_SMOOTH);
  gl.glAlphaFunc(GL.GL_ALWAYS, 1.0);
  gl.glDepthFunc(GL.GL_ALWAYS);
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
  gl.glEnable(GL.GL_BLEND);
  gl.glEnable(GL.GL_DEPTH_TEST);
  gl.glDisable(gl.GL_LIGHTING);
  gl.glDisable(gl.GL_CULL_FACE);
  int[] userList={};
  if (KinectEnabled)
  {
    userList = context.getUsers();
  }
  int usersInside=0;
  for (int iu=0;iu<userList.length;iu++)
  {
    if (context.isTrackingSkeleton(userList[iu]))//active tracked users
    {
      context.getJointPositionSkeleton(userList[iu], SimpleOpenNI.SKEL_TORSO, trp);
      d=p_area.dist(trp);
      if (d<rad) 
      {
        usersInside++;
        cpos=true;//inside interaction area

        confidence = context.getJointPositionSkeleton(userList[iu], SimpleOpenNI.SKEL_LEFT_HAND, lhp);//left hand
        confidence = context.getJointPositionSkeleton(userList[iu], SimpleOpenNI.SKEL_RIGHT_HAND, rhp);//right hand
        int lr=255;
        int lg=255;
        int lb=127;
        int rr=255;
        int rg=255;
        int rb=127;
        if (ppos==false && cpos==true)//previous position was spread
        {
          rst();
          body.assemble();
          tR.loadText(0);
          tR.state=1;
        }
        else if (ppos==true && cpos==true)
        {
          if (body.state==2)
          {
            if (tR.state==0)//idem detekovat dotyk
            {
              if (call==false)
              {
                touchReturn f_t=new touchReturn();
                touchReturn t_l=tD.detect(lhp, cm);
                touchReturn t_r=tD.detect(rhp, cm);
                if (t_l.p!=null || t_r.p!=null)
                {
                  if (t_l.p!=null && t_r.p!=null)
                  {
                    if (t_l.d<t_r.d) f_t=t_l;
                    else f_t=t_r;
                  }
                  else if (t_l.p!=null) f_t=t_l;
                  else if (t_r.p!=null) f_t=t_r;
                }
                if (f_t.p!=null && f_t.d<=150)
                {
                  if (f_t.d<=75)//touched
                  {
                    stages[f_t.a]=true;
                    tR.loadText((f_t.a+1));
                    bpic.setTexture(f_t.a);
                    tR.state=1;
                    pl.fadeOut(pl.c);
                    pl.c=(f_t.a+1);
                    pl.fadeIn(pl.c);
                  }
                }
              }
              else if (call==true && tR.cur_text!=8)
              {
                tR.loadText(8);
                tR.state=1;
              }
            }
            else if (tR.state==1)//idem sa hrat s textom
            {
              boolean cAr=cA.detect(rhp, lhp);
              if (cAr==false)
              {
                if (tR.cur_text>0 && tR.cur_text<8)
                {
                  if (lhp.z<paint_t) 
                  { 
                    lg=50;
                    lb=50;
                    tR.drawMask(lhp);
                  }
                  if (rhp.z<paint_t)
                  { 
                    rg=50;
                    rb=50;
                    tR.drawMask(rhp);
                  }
                }
              }
              else
              {
                tR.state=0;
                if (tR.cur_text==8)
                {
                  pl.fadeOut(pl.c);
                  pl.c=0;
                  pl.fadeIn(pl.c);
                  body.spread();
                }
              }
            }
          }        
          //drawing hands
          drawLimb(lhp, lr, lg, lb);//lava ruka
          drawLimb(rhp, rr, rg, rb);//prava ruka
        }

        if (d>stoprad)//outside tracking area
        {
          //endTrck(userList[iu]);//stop tracking user
        }
      }
    }
  }
  if (ppos==true && cpos==false)
  {
    tR.reset();
    rst();
  }

  shader.start();
  shader.setFloatUniform("tmx", p);
  int br=body.render(cm);
  shader.stop();

  if (body.state==2)
  {
    if (tR.state!=0)
    {
      cA.render();
      tR.render();
      if (tR.cur_text>0 && tR.cur_text<8)
      {
        bpic.render();
      }
    }
    else
    {
      tD.render(cm);
    }
  }
  prevall=call;
  ppos=cpos;
  oL.render();
  renderer.endGL();
  p+=0.005;
}
void rst()
{
  for (int i=0;i<stages.length;i++)
  {
    stages[i]=false;
  }
  pl.fadeOut(pl.c);
  pl.c=0;
  pl.fadeIn(pl.c);
  body.spread();
}


void endTrck(int userId)
{
  println("end tracking skeleton:"+actUser);
  //context.stopTrackingSkeleton(userId);
}

void onNewUser(int userId)
{
  println("new user: "+userId);
  context.requestCalibrationSkeleton(userId, true);
}

void onLostUser(int userId)
{
  println("lost user:"+userId);
}

void onStartCalibration(int userId)
{
  println("calibrating"+userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  }
  else
  {
    println("failed calibration");
    context.requestCalibrationSkeleton(userId, true);
  }
}

void onStartPose(String pose, int userId)
{
  //context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
}

void drawLimb(PVector pos, int r, int g, int b)
{
  float pts=20;
  ArrayList dp=new ArrayList();
  dp.add(new PVector(pos.x-pts, pos.y-pts, pos.z));
  dp.add(new PVector(pos.x+pts, pos.y-pts, pos.z));
  dp.add(new PVector(pos.x+pts, pos.y+pts, pos.z));
  dp.add(new PVector(pos.x-pts, pos.y+pts, pos.z));
  GLModel debugPoint=new GLModel(this, dp.size(), GLModel.QUADS, GLModel.STATIC);
  debugPoint.updateVertices(dp);  
  debugPoint.initColors();
  debugPoint.setColors(r, g, b, 42);
  debugPoint.setBlendMode(ADD);
  debugPoint.render();
}

void keyPressed() {
  //dbug=-1*dbug;
  if ((key == 'p')) 
  {
    println("skusim sejvnut");
    save("shot"+shot+".png");
    shot++;
  }
}

