//**************************** user actions ****************************
void keyPressed()  // executed each time a key is pressed: sets the Boolean "keyPressed" till it is released   
                    // sets  char "key" state variables till another key is pressed or released
    {
  
    if(key=='~') recordingPDF=true; // to snap an image of the canvas and save as zoomable a PDF, compact and great quality, but does not always work
    if(key=='!') snapJPG=true; // make a .PDF picture of the canvas, compact, poor quality
    if(key=='@') snapTIF=true; // make a .TIF picture of the canvas, better quality, but large file
    if(key=='#') ;
    if(key=='$') ;
    if(key=='%') ; 
    if(key=='^') ;
    if(key=='&') ;
    if(key=='*') ;    
    if(key=='(') ;
    if(key==')') ;  
    if(key=='_') ;
    if(key=='+') ;

    if(key=='`') filming=!filming;  // filming on/off capture frames into folder IMAGES/MOVIE_FRAMES_TIF/
    if(key=='1') ;               // toggles what should be displayed at each fram
    if(key=='2') debugPoints = true;
    if(key=='3') ;
    if(key=='4') ;
    if(key=='5') ;
    if(key=='6') ;
    if(key=='7') ;
    if(key=='8') ;
    if(key=='9') ;
    if(key=='0') ; 
    if(key=='-') ;
    if(key=='=') ;

    if(key=='a') ; 
    if(key=='b') ; 
    if(key=='c') P.resetOnCircle(P.nv);
    if(key=='d') ; 
    if(key=='e') ;
    if(key=='f') ;
    if(key=='g') ; 
    if(key=='h') ;
    if(key=='i') ; 
    if(key=='j') ;
    if(key=='k') ;   
    if(key=='l') ;
    if(key=='m') ;
    if(key=='n') ;
    if(key=='o') ;
    if(key=='p') ;
    if(key=='q') ; 
    if(key=='r') ; // used in mouseDrag to rotate the control points 
    if(key=='s') ;
    if(key=='t') ; // used in mouseDrag to translate the control points 
    if(key=='p') ;
    if(key=='v') ; 
    if(key=='w') ;  
    if(key=='x') ;
    if(key=='y') ;
    if(key=='z') ; // used in mouseDrag to scale the control points

    if(key=='A') ;
    if(key=='B') ; 
    if(key=='C') ; 
    if(key=='D') ;  
    if(key=='E') ;
    if(key=='F') ;
    if(key=='G') ; 
    if(key=='H') ; 
    if(key=='I') ; 
    if(key=='J') ;
    if(key=='K') ;
    if(key=='L') P.loadPts("data/pts");    // load current positions of control points from file
    if(key=='M') ;
    if(key=='N') ;
    if(key=='O') ;
    if(key=='P') ; 
    if(key=='Q') exit();  // quit application
    if(key=='R') ; 
    if(key=='S') P.savePts("data/pts");    // save current positions of control points on file
    if(key=='T') ;
    if(key=='U') ;
    if(key=='V') ;
    if(key=='W') ;  
    if(key=='X') ;  
    if(key=='Y') ;
    if(key=='Z') ;  

    if(key=='{') ;
    if(key=='}') ;
    if(key=='|') ; 
    
    if(key=='[') ; 
    if(key==']') P.fitToCanvas();  
    if(key=='\\') ;
    
    if(key==':') ; 
    if(key=='"') ; 
    
    if(key==';') ; 
    if(key=='\''); 
    
    if(key=='<') ;
    if(key=='>') ;
    if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
   
    if(key==',') ;
    if(key=='.') ;  // used in mousePressed to tweak current frame f
    if(key=='/') ;
  
    if(key==' ') {
      switch(mode) {
        case 0:
          mode = 1;
          break;
        case 1:
          mode = 0;
          edge1 = null;
          edge2 = null;
          edgesSelected = 0;
          break;
        default:
      }
    }
  
    if (key == CODED) 
       {
       String pressed = "Pressed coded key ";
       if (mode == 0) {
         if (keyCode == UP) {P.scaleAllAroundCentroid(-0.5);   }
         if (keyCode == DOWN) {P.scaleAllAroundCentroid(0.5);   };
       }
       
       if (keyCode == LEFT) {pressed="LEFT";   };
       if (keyCode == RIGHT) {pressed="RIGHT";   };
       if (keyCode == ALT) {pressed="ALT";   };
       if (keyCode == CONTROL) {pressed="CONTROL";   };
       if (keyCode == SHIFT) {pressed="SHIFT";   };
       println("Pressed coded key = "+pressed); 
       } 
  
    change=true; // to make sure that we save a movie frame each time something changes
    println("key pressed = "+key);

    }

void mousePressed()   // executed when the mouse is pressed
  {
  if (!keyPressed || (key=='a') || (key=='i') || (key=='x'))  
  P.pickClosest(Mouse()); // pick vertex closest to mouse: sets pv ("picked vertex") in pts
  if (keyPressed) 
     {
     if (key=='a')  P.addPt(Mouse()); // appends vertex after the last one
     if (key=='i')  P.insertClosestProjection(Mouse()); // inserts vertex at closest projection of mouse
     if (key=='d')  P.deletePickedPt(); // deletes vertex closeset to mouse
     } 
  if (keyPressed && key=='s') {drawing=true; A=Mouse(); B=Mouse();} 
  change=true;
  }

void mouseReleased()   // executed when the mouse is pressed
  {
  if (!keyPressed && mode == 1) {
    switch (edgesSelected) {
      case 0:
        edge1 = P.pickClosestEdge(Mouse());
        edge1.P = currentRegion;
        edgesSelected++;
        break;
      case 1:
        if (currentRegion != edge1.P) {
          e temp = P.pickClosestEdge(Mouse());
          edge2 = new e(temp.B,temp.A);
          edge2.P = currentRegion;
          edgesSelected++;
          pt tempA = new pt(edge1.A.x, edge1.A.y);
          pt tempB = new pt(edge1.B.x, edge1.B.y);
          edge1p = new e(tempA, tempB);
          moving = true;
        }
        break;
      default:
    }
  }
  if (keyPressed && key=='s' && mode == 0) { 
    B=Mouse(); 
    split = true;
  }
  change=true;
  drawing=false;
  
  }

void mouseDragged() // executed when the mouse is dragged (while mouse buttom pressed)
  {
    if (mode == 0) {
      if (!keyPressed && regions > 1) P.dragAll();   // dra g selected point with mouse
      if (keyPressed) {
          if (key=='.') f+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
          if (key=='r') P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
      }
      if (keyPressed && key=='s') B=Mouse(); 
    }
  
  change=true;
  }  

//**************************** text for name, title and help  ****************************
String title ="Split Polygon Puzzle",            name ="Students: Lily LAU, Douglas CHEONG",
       subtitle = "  CS 3451 Project 2",
       
       menu="?:(show/hide) help, ~/!/@:snap pdf/jpg/fif, `:(start/stop) recording, S/L:save/load, Q:quit",
       guide="click&drag:edit, d&click:delete, i&click&drag:insrt, s&click&drag:split"; // help info
       