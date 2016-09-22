//*****************************************************************************
// TITLE:         Point sequence for editing polylines and polyloops  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2012
// EDITS:         Last revised Sept 10, 2016
//*****************************************************************************
class pts 
  {
  int nv=0;                                // number of vertices in the sequence
  int pv = 0;                              // picked vertex 
  int iv = 0;                              // insertion index 
  int maxnv = 100*2*2*2*2*2*2*2*2;         //  max number of vertices
  Boolean loop=true;                       // is a closed loop
  float angle = 0.0;
  float scaleFactor = 0.0;
  vec translate = V(0.0,0.0);

  pt[] G = new pt [maxnv];                 // geometry table (vertices)

 // CREATE


  pts() {}
  
  void printPoints() {
    println();
    for (int i = 0; i < nv; i++) {
      print(G[i].x + ", " + G[i].y + " ");
    }
  }
  
  void declare() {for (int i=0; i<maxnv; i++) G[i]=P(); }               // creates all points, MUST BE DONE AT INITALIZATION

  void empty() {nv=0; pv=0; }                                                 // empties this object
  
  void addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  }                    // appends a point at position P
  
  void addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; }    // appends a point at position (x,y)
  
  void insertPt(pt P)  // inserts new point after point pv
    { 
    for(int v=nv-1; v>pv; v--) G[v+1].setTo(G[v]); 
    pv++; 
    G[pv].setTo(P);
    nv++; 
    }
     
  void insertClosestProjection(pt M) // inserts point that is the closest to M on the curve
    {
    insertPt(closestProjectionOf(M));
    }
  
  void resetOnCircle(int k)                                                         // init the points to be on a well framed circle
    {
    empty();
    pt C = ScreenCenter(); 
    for (int i=0; i<k; i++)
      addPt(R(P(C,V(0,-width/3)),2.*PI*i/k,C));
    } 
  
  void makeGrid (int w) // make a 2D grid of w x w vertices
   {
   empty();
   for (int i=0; i<w; i++) 
     for (int j=0; j<w; j++) 
       addPt(P(.7*height*j/(w-1)+.1*height,.7*height*i/(w-1)+.1*height));
   }    


  // PICK AND EDIT INDIVIDUAL POINT
  
  void pickClosest(pt M) 
    {
    pv=0; 
    for (int i=1; i<nv; i++) 
      if (d(M,G[i])<d(M,G[pv])) pv=i;
    }
    
  e pickClosestEdge(pt M)
    {
      pickClosest(M);
      return disToLine(M,G[pv],G[n(pv)])<disToLine(M,G[p(pv)],G[pv])?new e(G[pv], G[n(pv)]):new e(G[p(pv)],G[pv]);
    }

  void dragPicked()  // moves selected point (index pv) by the amount by which the mouse moved recently
    { 
    G[pv].moveWithMouse(); 
    }     
  
  void deletePickedPt() {
    for(int i=pv; i<nv; i++) 
      G[i].setTo(G[i+1]);
    pv=max(0,pv-1);       // reset index of picked point to previous
    nv--;  
    }
  
  void setPt(pt P, int i) 
    { 
    G[i].setTo(P); 
    }
  
  
  // DISPLAY
  
  void IDs() 
    {
    for (int v=0; v<nv; v++) 
      { 
      fill(white); 
      show(G[v],13); 
      fill(black); 
      if(v<10) label(G[v],str(v));  
      else label(G[v],V(-5,0),str(v)); 
      }
    noFill();
    }
  
  void showPicked() 
    {
    show(G[pv],13); 
    }
  
  void drawVertices(color c) 
    {
    fill(c); 
    drawVertices();
    }
  
  void drawVertices()
    {
    for (int v=0; v<nv; v++) show(G[v],13); 
    }
   
  void drawCurve() 
    {
    if(loop) drawClosedCurve(); 
    else drawOpenCurve(); 
    }
    
  void drawOpenCurve() 
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(); 
    }
    
  void drawClosedCurve()   
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(CLOSE); 
    }

  // EDIT ALL POINTS TRANSALTE, ROTATE, ZOOM, FIT TO CANVAS
  
  void dragAll() // moves all points to mimick mouse motion
    { 
    for (int i=0; i<nv; i++) G[i].moveWithMouse(); 
    translate.add(V(mouseX - pmouseX,mouseY - pmouseY));
    }      
  
  void moveAll(vec V) // moves all points by V
    {
    for (int i=0; i<nv; i++) G[i].add(V); 
    translate.add(V);
    }   

  void rotateAll(float a, pt C) // rotates all points around pt G by angle a
    {
    for (int i=0; i<nv; i++) G[i].rotate(a,C); 
    angle += a;
    } 
  
  void rotateAllAroundCentroid(float a) // rotates points around their center of mass by angle a
    {
    rotateAll(a,Centroid()); 
    }
    
  void rotateAllAroundCentroid(pt P, pt Q) // rotates all points around their center of mass G by angle <GP,GQ>
    {
    pt G = Centroid();
    rotateAll(angle(V(G,P),V(G,Q)),G); 
    }

  void scaleAll(float s, pt C) // scales all pts by s wrt C
    {
    for (int i=0; i<nv; i++) G[i].translateTowards(s,C); 
    scaleFactor += s;
    }  
  
  void scaleAllAroundCentroid(float s) 
    {
    scaleAll(s,Centroid()); 
    }
  
  void scaleAllAroundCentroid(pt M, pt P) // scales all points wrt centroid G using distance change |GP| to |GM|
    {
    pt C=Centroid(); 
    float m=d(C,M),p=d(C,P); 
    scaleAll((p-m)/p,C); 
    }

  void fitToCanvas()   // translates and scales mesh to fit canvas
     {
     float sx=100000; float sy=10000; float bx=0.0; float by=0.0; 
     for (int i=0; i<nv; i++) {
       if (G[i].x>bx) {bx=G[i].x;}; if (G[i].x<sx) {sx=G[i].x;}; 
       if (G[i].y>by) {by=G[i].y;}; if (G[i].y<sy) {sy=G[i].y;}; 
       }
     for (int i=0; i<nv; i++) {
       G[i].x=0.93*(G[i].x-sx)*(width)/(bx-sx)+23;  
       G[i].y=0.90*(G[i].y-sy)*(height-100)/(by-sy)+100;
       } 
     }   
     
  // MEASURES 
  float length () // length of perimeter
    {
    float L=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) L+=d(G[i],G[j]); 
    return L; 
    }
    
  float area()  // area enclosed
    {
    pt O=P(); 
    float a=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) a+=det(V(O,G[i]),V(O,G[j])); 
    return a/2;
    }   
    
  pt CentroidOfVertices() 
    {
    pt C=P(); // will collect sum of points before division
    for (int i=0; i<nv; i++) C.add(G[i]); 
    return P(1./nv,C); // returns divided sum
    }
  
  //pt Centroid() // temporary, should be updated to return centroid of area
  //  {
  //  return CentroidOfVertices();
  //  }

  
  pt closestProjectionOf(pt M) 
    {
    int c=0; pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<d) {c=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) 
      { 
      pt A = G[i], B = G[j];
      if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) 
        {
        d=disToLine(M,A,B); 
        c=i; 
        C=projectionOnLine(M,A,B);
        }
      } 
     pv=c;    
     return C;    
     }  

  Boolean contains(pt Q) {
    Boolean in=true;
    // provide code here
    return in;
    }
  
  pt Centroid () 
      {
      pt C=P(); 
      pt O=P(); 
      float area=0;
      for (int i=nv-1, j=0; j<nv; i=j, j++) 
        {
        float a = triangleArea(O,G[i],G[j]); 
        area+=a; 
        C.add(a,P(O,G[i],G[j])); 
        }
      C.scale(1./area); 
      return C; 
      }
        
  float alignentAngle(pt C) { // of the perimeter
    float xx=0, xy=0, yy=0, px=0, py=0, mx=0, my=0;
    for (int i=0; i<nv; i++) {xx+=(G[i].x-C.x)*(G[i].x-C.x); xy+=(G[i].x-C.x)*(G[i].y-C.y); yy+=(G[i].y-C.y)*(G[i].y-C.y);};
    return atan2(2*xy,xx-yy)/2.;
    }


  // FILE I/O   
     
  void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y);}
    saveStrings(fn,inppts);
    };
  

  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) {
      int i=k+s; 
      comma=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma));
      y=float(ss[i].substring(comma+1, ss[i].length()));
      G[k].setTo(x,y);
      };
    pv=0;
    }; 
    
  int n(int v) { return (v+1)%nv; }
  int p(int v) { return (v+nv-1)%nv; }
    
  boolean inside(int i) {
    pt A = P(0,0);
    pt B = Mouse();
    vec V = V(A,B);
    int count = 0;
    for (int v=0; v<nv; v++) {
      if(LineStabsEdge(A,B,G[v],G[n(v)])) {
        float t = RayEdgeCrossParameter(A,V,G[v],G[n(v)]);
        
        if (t < 1) {
          count++;
        }
      }
    }
    if (debugPoints) {
      println(count + " collisions on region " + i);
    }
    return count % 2 == 1;
  }
  void attemptSplit(pt A, pt B)
    {
      int back = 0;
      int front = 0;
      float backT = 0.;
      float frontT = 0.;
      int r = 0; int b = 0;
      int g = 0; 
      boolean goodSplit = true;
      vec V = V(A,B);
      for (int v=0; v<nv; v++) {
        if(LineStabsEdge(A,B,G[v],G[n(v)]))
        {
          float t = RayEdgeCrossParameter(A,V,G[v],G[n(v)]);
          pt X = P(A,t,V);
          if (t < 0) {
            pen(red,2);
            if (r == 0 || t > backT) {
              r++;
              backT = t;
              back = v;
            }
          }
          if (0 <= t && t <= 1) {
            pen(green,5);
            g++;
          }
          if (1<t) {
            pen(blue,2);
            if (b == 0 || t < frontT) {
              b++;
              frontT = t;
              front = v;
            }
          }
        }
        
      }
      pt backPoint = P(A,backT,V);
      pt frontPoint = P(A, frontT, V);
      pen(green, 4);
      if (g > 0 || r == 0 || b == 0) { goodSplit = false; pen(red, 4);}
      if (drawing) {
        arrow(backPoint, frontPoint);
      }
      if (goodSplit && split) {
        pts rightRegion = new pts();
        pts temp = P;
        rightRegion.declare();
        rightRegion.addPt(backPoint);
        rightRegion.angle = temp.angle;
        rightRegion.scaleFactor = temp.scaleFactor;
        rightRegion.translate = V(temp.translate.x, temp.translate.y);
        int current = n(back);
        while (current != n(front)) {
          rightRegion.addPt(G[current]);
          current = n(current);
        }
        rightRegion.addPt(frontPoint);
        pts leftRegion = new pts();
        leftRegion.declare();
        leftRegion.addPt(frontPoint);
        leftRegion.angle = temp.angle;
        leftRegion.scaleFactor = temp.scaleFactor;
        leftRegion.translate = V(temp.translate.x, temp.translate.y);
        current = n(front);
        while (current != n(back)) {
          leftRegion.addPt(G[current]);
          current = n(current);
        }
        leftRegion.addPt(backPoint);
        R[regions] = rightRegion;
        R[currentRegion] = leftRegion;
        regions++;
        println("# of regions is now " + regions);
        println("We replaced region " + currentRegion + " with leftRegion");
        println("We inserted the rightRegion at position " + regions);
      }
      split = false;
    }
  
  }  // end class pts