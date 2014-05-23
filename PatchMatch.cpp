#include<iostream>

#define cimg_plugin "PatchMatch_plugin.h"
#include "./CImg.h"

using namespace cimg_library;
using namespace std;

int main(int argc, char **argv)
{
  cimg_usage("PatchMatch: approximate nearest neighbour patch matching between two images img0 and img1.");
  cimg_help("Input / Output parameters:\n--------------------------");
  const char *file0 = cimg_option("-i0", (char*)0, "Image 0.");
  const char *file1 = cimg_option("-i1", (char*)0, "Image 1.");
//  const char *fileout = cimg_option("-o", (char*)0, "Output image of offsets (channel 0: x offset, channel 1: y offset).");
  const int P = cimg_option("-s", 15, "Patch size.");
  const int N = cimg_option("-n", 5, "Number of iterations.");

  if(!file0 || !file1){
    cerr<<"Must specify images with -i0 and -i1 options (-h for help).\n";
    exit(0);
  }

  srand (time(NULL));
  

  CImg<int> img0(file0);
  CImg<int> img1(file1);

  CImg<int> off;
  off.patchMatch(img0, img1, P, N);
  
  off.get_vizFlow(50).display();
  CImg<int> imgrec(img0.get_reconstruct(img1, off));
  (img0, imgrec, img1).display();
}
