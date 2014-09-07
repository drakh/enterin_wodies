# Enter:in' wodies

## interactive literary installation by Zuzana Husárová and Ľubomír Panák.

## attached software

This project is programmed in Processing 1.5 (you can find the windows version in the folder "processing 1.5.1"). this is the 32 bit version of processing.
All needed processing libraries you can find in the folder "processing_libraries".
As the installation is controlled by the Kinect Sensor, the application uses SimpleOpenNI ( https://code.google.com/p/simple-openni/ )library for Processing. For which you need to install OpenNI and NITE middleware and kinect drivers - you can find them in "openni_nite" folder.

All included drivers/middleware is for windows 32/64 (tested on win7 - both 32 and 64 bit versions).

## instructions before running the app
- install processing 1.5.1 for your system - the application will not run on processing 2.xx so please use distribution attached to this repository, or download version 1.5.1 from here: https://code.google.com/p/processing/downloads/list
- install OpenNI, NITE and Kinect drivers - for other than windows system you can find the drivers here: https://code.google.com/p/simple-openni/downloads/list?can=1&q=&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount - if you are using 64 bit windows, and 32 bit processing you have to install 32bit drivers and middleware
- connect your Kinect to PC
- copy attached Processing libraries to your processing installation: path_to_your_processing\modes\java\libraries
- copy somwhere to your disk "enterin_wodies_project"

## system requirements
- Kinect sensor (first version, NOT kinect2) pluggable to PC - kinect for X-Box can be used, but you need specia cable to connect it to PC
- PC running windows7 (4GB RAM, intel i5 CPU)
- discrete graphics card capadble of openGL (NVIDIA/ATI)
- projector (not needed high res, because of application runs in 640x480px)
- loudspeakers connected to computer

## running the app
- start processing and open "path_to_the\enterin_wodies_project\entering_wodies_v4.pde" 
- connect the projector to your computer, and set ti up to "extend desktop" mode and set the resolution to as low as possible - 800x600px for example. The application is running in 640x480px resolution
- in the "enterin_wodies_v4" tab there is a line "frame.setLocation(2000, 0);" which places the application window on location 2000px from left corner and 0px from top corner of your screen. so please set this line to match your screen and projctor resolution. frame.setLocation(left, top) where 
	- left = your primary screen width resolution + ((yor projector width resolution - 640) /2 )
	- top  = ( your projector height resolution - 480 ) /2
	- "frame.setLocation(0, 0);" means it would run in top left corner of your primary screen.

## physical setup of the scene
- dark room
- at least 3m x 4m x 2.5m (width x length x height)
- screen for projector
- tripod for kinect - kinect should be in the centre of the width o fthe screen, that when user stands directly in front of it, user is looking directly to the screen. but kinect should not cover any part of the screen - that user will see whole picture on the screen
as well please put the projector to cover the screen in way that when user will stand in front of the sensor and screen nor the Kinect, nor the user will throw shadow to the screen.

## how to interact.
Interaction area of user is approximetly 2 meters away from the sensor - when user is outside that interaction area there is no text and no person showed on the screen.
When Kinect regognises the person in front of it, it show the persons hands - each hand represented by yellow cursor in the form of square. More the hand is closer to the sensor the bigger the square is.

"explore more" button works as button. so user should press it - go with the hand/cursor above it and press it - it turns from white to red, and then "release" it by going with the hand back - it turns white again and fires the action.
