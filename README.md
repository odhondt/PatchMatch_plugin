# PatchMatch plugin for the C++ CImg library

- The PatchMatch algorithm looks for an approximate nearest neighbour of each patch of a source image into a query image and returns an XY offset 2-channel image. This algorithms has many applications such as inpainting, image compositing, stereo matching, optical flow, etc.
- This is a simple implementation of the algorithm.
- The code is not optimized, it is intended to be short, clean and readable.
- A fast version could be implemented.
- Compile with `make linux` (olinux to eneable compiler optimizations)
- Type ./PatchMatch -h to display help.

- TODO
  - [ ] More detailed doc.
  - [ ] Add limits for offsets.
  - [ ] Stereo version.
  - [ ] Add more features (ex: adaptive supports, etc.)

