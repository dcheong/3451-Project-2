// Computer Graphics Project 2
// Author: Douglas Cheong, Lily Lau
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!

//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to standardize GUI
int mode = 0;
int maxRegionCount = 64;
int currentRegion = 0;
int regions = 1;
pts [] R = new pts [maxRegionCount];
float t=0., f=0.;
boolean debugPoints = false;
boolean drawing;
boolean split = false;
boolean animate=true, fill=false, timing=false;
boolean lerp=true, slerp=true, spiral=true; // toggles to display vector interpoations
int ms=0, me=0; // milli seconds start and end for timing
int npts=20000; // number of points
pt A=P(100,100), B=P(300,300);
pts outline;
//****************************PlAYER VARIABLES****************************
e edge1, edge2;
int edgesSelected = 0;
float aF = 1000.; //animate time for edge animation in milliseconds
boolean moving = false;
boolean win;

//**************************** initialization ****************************
void setup()               // executed once at the begining 
  {
  size(800, 800);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  for (int r = 0; r < maxRegionCount; r++) R[r] = new pts();
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  R[0].declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS 
  // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas
  R[0].loadPts("data/pts");  // loads points form file saved with this program
  P = R[0];
  outline = R[0];
  } // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  
    background(white); // clear screen and paints white background
    fill(white);
    pen(red, 2);
    outline.drawCurve();
    for (int i = 0; i < regions; i++) {
      pen(white,3);
      fill(black);
      if (mode == 2) fill(green);
      
      if (R[i].inside(i) && mode != 2) {
        fill(grey);
        P = R[i];
        if (debugPoints) {
          println("The mouse is inside region " + i);
          println("angle: " + P.angle);
          println("scale: " + P.scaleFactor);
          println("translate: " + P.translate.x + " " + P.translate.y);
        }
        currentRegion = i;
      }
      R[i].drawCurve();
    }
    
    debugPoints = false;
    switch (mode) {
      case 0:
        P.attemptSplit(A,B);
        break;
      case 1:
        if (edge1 != null) {
          edge1.show();
        }
        if (edge2 != null) {
          edge2.show();
        }
        win = true;
          for (int j = 0; j < regions;j++) {
            if (abs(R[j].angle) > 0.01 || abs(R[j].scaleFactor) > 0.01 || abs(R[j].translate.x) > 0.01 || abs(R[j].translate.y) > 0.01) {
              println(j);
              println(R[j].angle);
              println(R[j].scaleFactor);
              println(R[j].translate.x + " " + R[j].translate.y);
              win = false;
            }
          }
          if (win) {
            mode = 2;
            println("win");
            break;
          }
        if (moving) {
          //e moveTo = spiral(edge1, edge2, t/aF);
          float angleInc = angle(edge1, edge2);
          pts points = R[edge1.P];
          if (!Float.isNaN(angleInc) || abs(angleInc) > 0.001) points.rotateAll(angleInc, edge1.A);
          float scaleInc = scaleF(edge2, edge1) - 1;
          vec transInc = translation(edge1, edge2);
          points.scaleAll(scaleInc, edge1.A);
          points.moveAll(transInc);
          
          moving = false;
          edge1 = null;
          edge2 = null;
          edgesSelected = 0;
          //t += 1000/30;
          //if (t >= aF) {
          //  println("over aF");
          //  t = 0.;
          //  moving = false;
          //  edge1 = null;
          //  edge2 = null;
          //  edgesSelected = 0;
          //}
        }
        break;
      case 2:
        println("You win.");
      default:
    }


  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 

  if(filming && (animating || change)) snapFrameToTIF(); // saves image on canvas as movie frame 
  if(snapTIF) snapPictureToTIF();   
  if(snapJPG) snapPictureToJPG();   
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw
  