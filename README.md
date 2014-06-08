# PatchMatch plugin for the C++ CImg library

## Description
- The PatchMatch algorithm looks for an approximate nearest neighbour of each patch of a source image into a query image and returns an XY offset 2-channel image. This algorithms has many applications such as inpainting, image compositing, stereo matching, optical flow, etc.
- This is a simple implementation of the algorithm.
- The code is not optimized, it is intended to be short, clean and readable.
- A fast version could be implemented.
- Compile with `make linux` (olinux to enable compiler optimizations)
- Type `./PatchMatch -h` to display help.
- The original paper can be found here: http://gfx.cs.princeton.edu/pubs/Barnes_2009_PAR/index.php

## TODO
  - [x] Display in real-time
  - [ ] More detailed doc
  - [ ] Add limits for offsets
  - [ ] Fast version
  - [ ] Add more features (ex: adaptive supports, etc.)
  - [ ] Applications (inpainting, reshuffling...)
  - [ ] Stereo version
  - [ ] Generalized PatchMatch
