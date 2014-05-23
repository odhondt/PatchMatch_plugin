#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
#
#  Makefile  : Makefile for compiling CImg-based code on Unix
#
#  Copyright : David Tschumperle (http://www.greyc.ensicaen.fr/~dtschump/)
#
#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Define the CImg files to be compiled (name of the source file without the .cpp extension)
#-------------------------------------------------------------------------------------------
CIMG_FILES = PatchMatch\
            

#---------------------------------
# Set correct variables and paths
#---------------------------------
CIMG_VERSION = 1.24
CC           = g++
X11PATH      = /usr/X11R6
#CFLAGS       = -Wall -W -ansi -pedantic -ffast-math
CFLAGS       = -ansi -pedantic -ffast-math
#CFLAGS       = -O3 -ansi -pedantic -ffast-math 
LDFLAGS      = -lm -lpthread  
#LDFLAGS      = -L/home/olivier/lib -I/home/olivier/lib -lm -lpthread -lfigtree -lmgl -lmgl-fltk

#--------------------------------------------------
# Set compilation flags allowing to customize CImg
#--------------------------------------------------

# Flags to enable the use of the X11 library.
# (X11 is used by CImg to handle display windows)
# !!! For 64bits systems : replace -L$(X11PATH)/lib by -L$(X11PATH)/lib64 !!!
CIMG_X11_FLAGS = -I$(X11PATH)/include -L$(X11PATH)/lib -lX11 
#CIMG_X11_FLAGS = -I$(X11PATH)/include -L$(X11PATH)/lib64 -lX11

# Flags to enable fast image display, using the XSHM library.
# (CIMG_X11_FLAGS must be defined also)
CIMG_XSHM_FLAGS = -Dcimg_use_xshm -lXext

# Flags to enable screen mode switching, using the XRandr library.
# (CIMG_X11_FLAGS must be defined also)
CIMG_XRANDR_FLAGS = -Dcimg_use_xrandr -lXrandr

# Flags to enable native support for PNG image files, using the PNG library.
CIMG_PNG_FLAGS = -Dcimg_use_png -lpng -lz

# Flags to enable native support for JPEG image files, using the JPEG library.
CIMG_JPEG_FLAGS = -Dcimg_use_jpeg -ljpeg

# Flags to enable native support for TIFF image files, using the TIFF library.
CIMG_TIFF_FLAGS = -Dcimg_use_tiff -ltiff

# Flags to enable native support of most classical image file formats, using the Magick++ library.
CIMG_MAGICK_FLAGS = -Dcimg_use_magick `Magick++-config --cppflags` `Magick++-config --cxxflags` `Magick++-config --ldflags` `Magick++-config --libs`

# Flags to enable faster Discrete Fourier Transform computation, using the FFTW3 library
CIMG_FFTW3_FLAGS = -Dcimg_use_fftw3 -lfftw3

# Flags to enable the use of LAPACK routines for matrix computation
CIMG_LAPACK_FLAGS = -Dcimg_use_lapack -lblas -lg2c -llapack

# Flags to enable the use of the Board library
CIMG_BOARD_FLAGS = -Dcimg_use_board -lboard

# Flags to compile on Solaris
CIMG_SOLARIS_FLAGS = -R$(X11PATH)/lib -lrt -lnsl -lsocket

# Set default compilation flags.
# Uncomment lines here, if you want to customize your default configuration
CIMG_DEFAULT_FLAGS = $(CIMG_X11_FLAGS) \
                     $(CIMG_XSHM_FLAGS) \
                     $(CIMG_XRANDR_FLAGS) \
                     $(CIMG_JPEG_FLAGS) \
                     $(CIMG_TIFF_FLAGS) \
                     $(CIMG_FFTW3_FLAGS)
#                     $(CIMG_PNG_FLAGS) \
#                     $(CIMG_MAGICK_FLAGS) \
#		      $(CIMG_LAPACK_FLAGS)

# Gather all compilation flags.
CIMG_ALL_FLAGS = $(CIMG_X11_FLAGS) \
                 $(CIMG_XSHM_FLAGS) \
                 $(CIMG_XRANDR_FLAGS) \
                 $(CIMG_PNG_FLAGS) \
                 $(CIMG_JPEG_FLAGS) \
                 $(CIMG_TIFF_FLAGS) \
                 $(CIMG_MAGICK_FLAGS) \
                 $(CIMG_FFTW3_FLAGS) \
	         $(CIMG_LAPACK_FLAGS) \
                 $(CIMG_BOARD_FLAGS)

#-------------------------
# Define Makefile entries
#-------------------------
.cpp:
	@echo
	@echo "** Compiling '$* ($(CIMG_VERSION))' with '`$(CC) -v 2>&1 | grep version`'"
	@echo
	$(CC) -o $* $< $(CFLAGS) $(LDFLAGS) $(ARCHFLAGS)
menu:
	@echo
	@echo "CImg Library $(CIMG_VERSION) : Examples"
	@echo "-----------------------------"
	@echo "  > dlinux   : Compile for Linux/MacOSX, with debug informations."
	@echo "  > linux    : Compile for Linux/MacOSX, with standard options."
	@echo "  > olinux   : Compile for Linux/MacOSX, with optimizations."
	@echo "  > mlinux   : Compile for Linux/MacOSX, with minimal dependancies."
	@echo "  > Mlinux   : Compile for Linux/MacOSX, with maximal dependancies."
	@echo
	@echo "  > dsolaris : Compile for Solaris, with debug informations."
	@echo "  > solaris  : Compile for Solaris, with standard options."
	@echo "  > osolaris : Compile for Solaris, with optimizations."
	@echo "  > msolaris : Compile for Solaris, with minimal dependancies."
	@echo "  > Msolaris : Compile for Solaris, with maximal dependancies."
	@echo
	@echo "  > clean    : Clean generated files."
	@echo
	@echo "Choose your option :"
	@read CHOICE; echo; make $$CHOICE; echo; echo "> Next time, you can bypass the menu by typing directly 'make $$CHOICE'"; echo;

all: $(CIMG_FILES)

clean:
	rm -f *.exe *~ jpeg_buffer greycstoration4gimp $(CIMG_FILES)

greycstoration4gimp: greycstoration4gimp.cpp
	@echo
	@echo "** Compiling 'greycstoration4gimp ($(CIMG_VERSION))' with '`$(CC) -v 2>&1 | grep version`'"
	@echo
	$(CC) -o greycstoration4gimp greycstoration4gimp.cpp `gimptool-2.0 --cflags` `gimptool-2.0 --libs` -lpthread -O3

# Linux/Mac OSX targets
linux:
	make "ARCHFLAGS=$(CIMG_DEFAULT_FLAGS)" all
dlinux:
	make "ARCHFLAGS=-Dcimg_debug=3 -g $(CIMG_DEFAULT_FLAGS)" all
olinux:
	make "ARCHFLAGS=-O3 $(CIMG_DEFAULT_FLAGS)" all
mlinux:
	make "ARCHFLAGS=-Dcimg_display_type=0 -O3" all
Mlinux:
	make "ARCHFLAGS=-O3 $(CIMG_ALL_FLAGS)" all jpeg_buffer greycstoration4gimp

# Sun Solaris targets
solaris:
	make "ARCHFLAGS=$(CIMG_SOLARIS_FLAGS) $(CIMG_DEFAULT_FLAGS)" all
dsolaris:
	make "ARCHFLAGS=-Dcimg_debug=3 -g $(CIMG_SOLARIS_FLAGS) $(CIMG_DEFAULT_FLAGS)" all
osolaris:
	make "ARCHFLAGS=-O3 $(CIMG_SOLARIS_FLAGS) $(CIMG_DEFAULT_FLAGS)" all
msolaris:
	make "ARCHFLAGS=-Dcimg_display_type=0 -O3" all
Msolaris:
	make "ARCHFLAGS=-Dcimg_display_type=0 -O3 $(CIMG_ALL_FLAGS)" all jpeg_buffer greycstoration4gimp
