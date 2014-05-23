#include<iostream>
#include<sys/stat.h>
#include<algorithm>
#include<queue>
#include<list>
#include<string>
#include<sstream>
#include<fstream>

#include "./CImg.h"

using namespace cimg_library;
using namespace std;

typedef unsigned char uc;


CImg<float> vizFlow(CImg<int> &off, int cutVal=0)
{
  CImg<float> res(off, "x,y,1,3", 0.0);

  // Normalizing offset magnitude
  CImg<float> mag(off, "xy", 0.0);
  cimg_forXY(off, x, y){
    mag(x, y) = sqrt(off(x, y, 0, 0)*off(x, y, 0, 0) + off(x , y, 0, 1)*off(x, y, 0, 1)); 
  }
  
  if(cutVal)
    mag.cut(0, cutVal);
  
  mag /= mag.max();

  // Filling HSV values
  cimg_forXY(off, x, y){
    float xx = -off(x, y, 0, 0);
    float yy = -off(x, y, 0, 1);
    
    float H = cimg::max(180*((atan2(yy, xx)/M_PI)+1.0), 0.0);
    float S = mag(x, y);
    float V = 1.0;
    
    res(x, y, 0, 0) = H;
    res(x, y, 0, 1) = mag(x, y);
    res(x, y, 0, 2) = V;

  }

  res.HSVtoRGB();
  
  return res;
}

int distPatch(CImg<int> &img0, CImg<int> &img1, 
    int x0, int y0, 
    int x1, int y1,
    int pSize)
{
  int d2 = 0;
  for(int c = 0; c < img0.spectrum(); c++){
    for(int y = 0; y < pSize; y++){
      for(int x = 0; x < pSize; x++){
        int d = (img0(x0 + x, y0 + y, 0, c) - img1(x1 + x, y1 + y, 0, c)); 
        d2 += d*d;      
      }
    } 
  }
  return d2;
}

// Original patch match
CImg<int> patchMatch(CImg<int> &img0, CImg<int> &img1, int patchSize, int nIter = 2)
{
  if(img0.spectrum() != img1.spectrum())
    cerr<<"Images must have the same number of channels.\n";
  if(!patchSize % 2){
    patchSize++;
    cout<<"Input patch size is even, adding 1.\n";
  }
  int w0 = img0.width();
  int h0 = img0.height();
  int w1 = img1.width();
  int h1 = img1.height();
  int nChannels = img0.spectrum();

  int P = patchSize;
  int H = int(P/2);
  
  // Zero padding borders
  // TODO : correct imgW in image 1 can be diff from img 0
  CImg<int> img0big(w0+2*H, h0+2*H, 1, nChannels, 0);
  CImg<int> img1big(w1+2*H, h1+2*H, 1, nChannels, 0);
  
  img0big.rand(0,255);
  img1big.rand(0,255);
  img0big.draw_image(H, H, 0, 0, img0);
  img1big.draw_image(H, H, 0, 0, img1);

  CImg<int> off(w0, h0, 1, 2, 0);
  CImg<int> minDist(w0, h0, 1, 1, 0);

  int cnt = 0;
  // Initialize
  cimg_forXY(off, x0, y0){
    int x1 = ((w1-1) * cimg::rand());
    int y1 = ((h1-1) * cimg::rand());
    off(x0, y0, 0, 0) = x1-x0;
    off(x0, y0, 0, 1) = y1-y0;
    minDist(x0, y0) = distPatch(img0big, img1big, x0, y0, x1, y1, P);
  }
  vizFlow(off).display(); 

  int xStart, yStart, xFinish, yFinish;
  int inc;
  for(int n = 0; n < nIter; n++){
    
    // at odd iterations, reverse scan order
    if(n%2 == 0){
      xStart = 1; yStart = 1;
      xFinish = w0;
      yFinish = h0;
      inc = 1;
    }else{
      xStart = w0-2;
      yStart = h0-2;
      xFinish = -1; yFinish = -1;
      inc = -1;
    }
    for(int y = yStart; y != yFinish; y=y+inc)
      for(int x = xStart; x != xFinish; x=x+inc){
        // Propagate
        int d2 = distPatch(img0big, img1big, x, y, x+off(x-inc, y, 0, 0), y+off(x-inc, y, 0, 1), P);
        if(d2<minDist(x, y)){
          minDist(x, y) = d2;
          off(x, y, 0, 0) = off(x-inc, y, 0, 0);
          off(x, y, 0, 1) = off(x-inc, y, 0, 1);
        }
        d2 = distPatch(img0big, img1big, x, y, x+off(x, y-inc, 0, 0), y+off(x, y-inc, 0, 1), P);
        if(d2<minDist(x, y)){
          minDist(x, y) = d2;
          off(x, y, 0, 0) = off(x, y-inc, 0, 0);
          off(x, y, 0, 1) = off(x, y-inc, 0, 1);
        }

        // Search
        int wSizX = w1-1;
        int wSizY = h1-1;
        int offXCurr = off(x, y, 0, 0);
        int offYCurr = off(x, y, 0, 1);
        do{
          int wMinX = cimg::max(0, x+offXCurr-wSizX/2); 
          int wMaxX = cimg::min(w1-1, x+offXCurr+wSizX/2); 
          int x1 = (wMaxX-wMinX) * cimg::rand() + wMinX;

          int wMinY = cimg::max(0, y+offYCurr-wSizY/2); 
          int wMaxY = cimg::min(h1-1, y+offYCurr+wSizY/2); 
          int y1 = (wMaxY-wMinY) * cimg::rand() + wMinY;

          int d2 = distPatch(img0big, img1big, x, y, x1, y1, P);

          if(d2 < minDist(x, y)){
            minDist(x, y) = d2;
            off(x, y, 0, 0) = x1-x;
            off(x, y, 0, 1) = y1-y;
          }
          wSizX /= 2;
          wSizY /= 2;
        }while(wSizX >= 1 && wSizY >= 1); 

      }
  }

  return off;
}

int main(int argc, char **argv)
{
  cimg_usage("Randomized patch matching.");
  cimg_help("Input / Output parameters:\n--------------------------");
  //const char *file_m = cimg_option("-m", (char*)0, "Foreground / Background scribble mask (optional).");

  //if(file_num<0){
  //  cerr<<"Must specify one input file number with -in option...\n";
  //  exit(0);
  //}

  srand (time(NULL));
  

  CImg<int> img0("10.png");
  CImg<int> img1("11.png");

  CImg<int> off(patchMatch(img0, img1, 21, 7));
  
  vizFlow(off, 25).display();
}
