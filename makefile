#
# This makefile, adapted from FB's, creates a libfb archives combining fbrtlib .bas
# files with rtlib .c files. Doesn't produce pic variants by default (see below)
# Either edit FB_SRC_PATH below, or create a config.mk and define it there,
# or pass it on the commandline or in an envvar. See below for other options
# you can put in your config.mk file.

# Warning: if fbc defaults to 32 bit but gcc defaults to 64 bit, then you need
# to specify MULTILIB=32 or MULTILIB=64 unless you specify TARGET instead.

# Targets are:
#  rtlib    (default)
#  install  For convenience, to install over top of an existing FB install

# Options include:
#  MULTILIB   32 or 64, changes the arch
#  TARGET     GNU triplet for cross-compiling
#  TARGET_OS/TARGET_ARCH  Alternative to TARGET
# The following only matter for 'make install':
#  prefix
#  DESTDIR
#  ENABLE_STANDALONE
#  ENABLE_SUFFIX


# The path to the src/ subdirectory in a checked out copy of the FB source
#FB_SRC_PATH := ../fbc/src/

# Location of fbrtLib source
srcdir := .

FBC := fbc

prefix := /usr/local

# Can define these to speed up compiles
# DISABLE_MT := YesPlease
DISABLE_PIC := YesPlease

# To skip files, add them to BLACKLIST:
# crt/stat.bi not supported on linux
BLACKLIST += ./dev_file_eof.bas ./dev_file_size.bas ./dev_file_tell.bas ./file_len.bas ./dev_file_open.bas ./signals.bas ./file_datetime.bas ./sys_mkdir.bas

# Define this if libffi isn't installed
#ALLCFLAGS += -DDISABLE_FFI

-include config.mk

ifndef FB_SRC_PATH
  $(error You need to provide FB_SRC_PATH, the path to the FreeBASIC source)
endif


###############################################################################
# Determine TARGET_OS & TARGET_ARCH & FBTARGET
###############################################################################

#
# We need to know target OS/architecture names to select the proper
# rtlib/gfxlib2 source directories.
#
# If TARGET is given, we try to parse it to determine TARGET_OS/TARGET_ARCH.
# Otherwise we rely on "uname" and "uname -m".
#
ifdef TARGET
  # Parse TARGET
  triplet := $(subst -, ,$(TARGET))
  TARGET_PREFIX := $(TARGET)-

  ifndef TARGET_OS
    ifneq ($(filter cygwin%,$(triplet)),)
      TARGET_OS := cygwin
    else ifneq ($(filter darwin%,$(triplet)),)
      TARGET_OS := darwin
    else ifneq ($(filter djgpp%,$(triplet)),)
      TARGET_OS := dos
    else ifneq ($(filter msdos%,$(triplet)),)
      TARGET_OS := dos
    else ifneq ($(filter freebsd%,$(triplet)),)
      TARGET_OS := freebsd
    else ifneq ($(filter linux%,$(triplet)),)
      TARGET_OS := linux
    else ifneq ($(filter mingw%,$(triplet)),)
      TARGET_OS := win32
    else ifneq ($(filter netbsd%,$(triplet)),)
      TARGET_OS := netbsd
    else ifneq ($(filter openbsd%,$(triplet)),)
      TARGET_OS := openbsd
    else ifneq ($(filter solaris%,$(triplet)),)
      TARGET_OS := solaris
    else ifneq ($(filter xbox%,$(triplet)),)
      TARGET_OS := xbox
    endif
  endif

  ifndef TARGET_ARCH
    # arch = iif(has >= 2 words, first word, empty)
    # 'i686 pc linux gnu' -> 'i686'
    # 'mingw32'           -> ''
    TARGET_ARCH := $(if $(word 2,$(triplet)),$(firstword $(triplet)))
  endif
else
  # No TARGET given, so try to detect the native system with 'uname'.
  # Note, fbc target might differ from uname
  ifndef TARGET_OS
    uname := $(shell uname)
    ifneq ($(findstring CYGWIN,$(uname)),)
      TARGET_OS := cygwin
    else ifeq ($(uname),Darwin)
      TARGET_OS := darwin
    else ifeq ($(uname),FreeBSD)
      TARGET_OS := freebsd
    else ifeq ($(uname),Linux)
      TARGET_OS := linux
    else ifneq ($(findstring MINGW,$(uname)),)
      TARGET_OS := win32
    else ifeq ($(uname),MS-DOS)
      TARGET_OS := dos
    else ifeq ($(uname),NetBSD)
      TARGET_OS := netbsd
    else ifeq ($(uname),OpenBSD)
      TARGET_OS := openbsd
    else ifeq ($(uname),SunOS)
      TARGET_OS := solaris
    endif
  endif

  ifndef TARGET_ARCH
    # For DJGPP, always use x86 (DJGPP's uname -m returns just "pc")
    ifeq ($(TARGET_OS),dos)
      #TARGET_ARCH := x86  # Not supported by fbc!!!
      TARGET_ARCH := 32
    else
      TARGET_ARCH = $(shell uname -m)
    endif
  endif
endif

ifndef TARGET_OS
  $(error couldn't identify TARGET_OS automatically)
endif
ifndef TARGET_ARCH
  $(error couldn't identify TARGET_ARCH automatically)
endif

# Normalize TARGET_ARCH to x86
ifneq ($(filter 386 486 586 686 i386 i486 i586 i686,$(TARGET_ARCH)),)
  TARGET_ARCH := x86
endif

# Normalize TARGET_ARCH to arm
ifneq ($(filter arm%,$(TARGET_ARCH)),)
  TARGET_ARCH := arm
endif

# Normalize TARGET_ARCH to x86_64 (e.g., FreeBSD's uname -m returns "amd64"
# instead of "x86_64" like Linux)
ifneq ($(filter amd64 x86-64,$(TARGET_ARCH)),)
  TARGET_ARCH := x86_64
endif

# Switch TARGET_ARCH depending on MULTILIB
ifeq ($(MULTILIB),32)
  ifeq ($(TARGET_ARCH),x86_64)
    TARGET_ARCH := x86
  endif
else ifeq ($(MULTILIB),64)
  ifeq ($(TARGET_ARCH),x86)
    TARGET_ARCH := x86_64
  endif
endif

ifeq ($(TARGET_OS),dos)
  #FBNAME := freebas$(ENABLE_SUFFIX)
  #FB_LDSCRIPT := i386go32.x
  DISABLE_MT := YesPlease
endif

# ENABLE_PIC for every system where we need separate
# -fPIC versions of FB libs besides the normal ones
ifneq ($(filter android freebsd linux netbsd openbsd solaris,$(TARGET_OS)),)
  ENABLE_PIC := YesPlease
endif

#
# Determine FB target name:
# dos, win32, win64, xbox, linux-x86, linux-x86_64, ...
#

# Some use a simple free-form name
ifeq ($(TARGET_OS),dos)
  FBTARGET := dos
else ifeq ($(TARGET_OS),xbox)
  FBTARGET := xbox
else ifeq ($(TARGET_OS),win32)
  ifeq ($(TARGET_ARCH),x86_64)
    FBTARGET := win64
  else
    FBTARGET := win32
  endif
endif

# The rest uses the <os>-<cpufamily> format
ifndef FBTARGET
  FBTARGET := $(TARGET_OS)-$(TARGET_ARCH)
endif

ifeq ($(TARGET_OS),xbox)
  # Assume no libffi for now (does it work on Xbox?)
  ALLCFLAGS += -DDISABLE_FFI

  # -DENABLE_MT parts of rtlib XBox code aren't finished
  DISABLE_MT := YesPlease
endif


# Try to determine whether fbc will use the GCC backend (yuck)
ifneq ($(TARGET_ARCH),x86)
  GCC_BACKEND := yes
else ifeq ($(TARGET_OS),darwin)
  GCC_BACKEND := yes
else ifeq ($(filter gcc,$(ALLFBRTFLAGS)),gcc)
  GCC_BACKEND := yes
endif

###############################################################################
# fbc and gcc arguments
###############################################################################

ifdef TARGET
  ALLFBRTFLAGS += -target $(TARGET)
endif
ifdef MULTILIB
  ALLCFLAGS   += -m$(MULTILIB)
  ALLFBRTFLAGS += -arch $(MULTILIB)
else ifeq ($(TARGET_ARCH),x86_64)
  # fbc's default arch can differ from the system arch
  ALLFBRTFLAGS += -arch 64
else ifeq ($(TARGET_ARCH),x86)
  # fbc's default arch can differ from the system arch
  ALLFBRTFLAGS += -arch 32
endif

#ALLFBRTFLAGS += -e -w pedantic  # These are the flags used for compiling fbc
ALLCFLAGS += -Wall -Wextra -Wno-unused-parameter -Werror-implicit-function-declaration
# These are for GCC 7, and are missing from FB's makefile
ALLCFLAGS += -Wno-misleading-indentation -Wno-implicit-fallthrough

###############################################################################
# Determine directory layout for .o files and final binaries.
###############################################################################

FBNAME := freebasic$(ENABLE_SUFFIX)
libsubdir := $(FBTARGET)
ifdef ENABLE_STANDALONE
  # Traditional standalone layout: fbc.exe at toplevel, libs in lib/<fbtarget>/
  libdir         := lib/$(libsubdir)
  prefixlibdir   := $(prefix)/$(libdir)
else
  # Normal (non-standalone) setup: bin/fbc, include/freebasic/, lib[64]/freebasic/<fbtarget>/.
  libdir         := lib/$(FBNAME)/$(libsubdir)
  prefixlibdir   := $(prefix)/$(libdir)
endif

# Where to put object files. FB and C object files are put in the same place.
# Have to use an absolute path, to stop make from putting .o files under FB_SRC_PATH
# (realpath may not exist on windows, use readlink instead)
libfbobjdir := $(shell readlink -m obj/$(libsubdir))
#libfbobjdir := $(shell realpath -m obj/$(libsubdir))
#libfbobjdir := obj/$(libsubdir)
libfbmtobjdir := $(libfbobjdir)/mt
libfbpicobjdir := $(libfbobjdir)/pic
libfbmtpicobjdir := $(libfbobjdir)/mtpic

###############################################################################
# Source files
###############################################################################

RTLIB_DIRS := $(FB_SRC_PATH)/rtlib $(FB_SRC_PATH)/rtlib/$(TARGET_OS) $(FB_SRC_PATH)/rtlib/$(TARGET_ARCH)
FBRTLIB_DIRS := $(srcdir) $(srcdir)/$(TARGET_OS) $(srcdir)/$(TARGET_ARCH)
ifeq ($(TARGET_OS),cygwin)
  RTLIB_DIRS += $(FB_SRC_PATH)/rtlib/win32
  FBRTLIB_DIRS += $(srcdir)/win32
endif
ifneq ($(filter darwin freebsd linux netbsd openbsd solaris,$(TARGET_OS)),)
  RTLIB_DIRS += $(FB_SRC_PATH)/rtlib/unix
  FBRTLIB_DIRS += $(srcdir)/unix
endif

# Where to search for dependencies
VPATH = $(FBRTLIB_DIRS) $(RTLIB_DIRS)

ifdef GCC_BACKEND
  # These files use varargs and can't be compiled by the gcc backend
  # BLACKLIST += ./array_redim.bas ./array_redim_obj.bas ./array_tempdesc.bas ./array_redimpresv.bas ./array_redimpresv_obj.bas ./array_setdesc.bas ./str_chr.bas ./strw_chr.bas
endif

LIBFB_BI := $(sort $(foreach i,$(FBRTLIB_DIRS),$(wildcard $(i)/*.bi)))
LIBFB_BAS := $(sort $(foreach i,$(FBRTLIB_DIRS),$(patsubst $(i)/%.bas,$(libfbobjdir)/%.o,$(filter-out $(BLACKLIST),$(wildcard $(i)/*.bas)))))

LIBFB_H := $(sort $(foreach i,$(RTLIB_DIRS),$(wildcard $(i)/*.h)))
LIBFB_C := $(sort $(foreach i,$(RTLIB_DIRS),$(patsubst $(i)/%.c,$(libfbobjdir)/%.o,$(wildcard $(i)/*.c))))
LIBFB_S := $(sort $(foreach i,$(RTLIB_DIRS),$(patsubst $(i)/%.s,$(libfbobjdir)/%.o,$(wildcard $(i)/*.s))))

# Remove all .o files that can be derived from a .bas file rather than a .c file
LIBFB_C := $(filter-out $(LIBFB_BAS),$(LIBFB_C))

# mt and pic variants
LIBFBMT_BAS    := $(patsubst $(libfbobjdir)/%,$(libfbmtobjdir)/%,$(LIBFB_BAS))
LIBFBPIC_BAS   := $(patsubst $(libfbobjdir)/%,$(libfbpicobjdir)/%,$(LIBFB_BAS))
LIBFBMTPIC_BAS := $(patsubst $(libfbobjdir)/%,$(libfbmtpicobjdir)/%,$(LIBFB_BAS))
LIBFBMT_C    := $(patsubst $(libfbobjdir)/%,$(libfbmtobjdir)/%,$(LIBFB_C))
LIBFBPIC_C   := $(patsubst $(libfbobjdir)/%,$(libfbpicobjdir)/%,$(LIBFB_C))
LIBFBMTPIC_C := $(patsubst $(libfbobjdir)/%,$(libfbmtpicobjdir)/%,$(LIBFB_C))

###############################################################################
# Build rules
###############################################################################

.PHONY: all
all: rtlib

CC = $(TARGET_PREFIX)gcc

# Rules to compile normal, mt, pic, and mtpic variants of .bas, .c and .s

$(LIBFB_BAS): $(libfbobjdir)/%.o: %.bas $(LIBFB_BI) | $(libfbobjdir)
	$(FBC) $(ALLFBRTFLAGS) -c $< -o $@
$(LIBFBMT_BAS): $(libfbmtobjdir)/%.o: %.bas $(LIBFB_BI) | $(libfbmtobjdir)
	$(FBC) -d ENABLE_MT $(ALLFBRTFLAGS) -c $< -o $@
$(LIBFBPIC_BAS): $(libfbpicobjdir)/%.o: %.bas $(LIBFB_BI) | $(libfbpicobjdir)
	$(FBC) -pic $(ALLFBRTFLAGS) -c $< -o $@
$(LIBFBMTPIC_BAS): $(libfbmtpicobjdir)/%.o: %.bas $(LIBFB_BI) | $(libfbmtpicobjdir)
	$(FBC) -pic $(ALLFBRTFLAGS) -c $< -o $@

$(LIBFB_C): $(libfbobjdir)/%.o: %.c $(LIBFB_H) | $(libfbobjdir)
	$(CC) $(ALLCFLAGS) -c $< -o $@
$(LIBFBMT_C): $(libfbmtobjdir)/%.o: %.c $(LIBFB_H) | $(libfbmtobjdir)
	$(CC) -DENABLE_MT $(ALLCFLAGS) -c $< -o $@
$(LIBFBPIC_C): $(libfbpicobjdir)/%.o: %.c $(LIBFB_H) | $(libfbpicobjdir)
	$(CC) -fPIC $(ALLCFLAGS) -c $< -o $@
$(LIBFBMTPIC_C): $(libfbmtpicobjdir)/%.o: %.c $(LIBFB_H) | $(libfbmtpicobjdir)
	$(CC) -DENABLE_MT -fPIC $(ALLCFLAGS) -c $< -o $@

$(LIBFB_S): $(libfbobjdir)/%.o: %.s $(LIBFB_H) | $(libfbobjdir)
	$(CC) -x assembler-with-cpp $(ALLCFLAGS) -c $< -o $@
# FB's makefile compiles mt variants on .s files which aren't needed.

# delete this later
ifdef DISABLE_PIC
  ENABLE_PIC :=
endif

RTL_LIBS := $(libdir)/fbrt0.o $(libdir)/libfb.a
# RTL_LIBS += $(libdir)/$(FB_LDSCRIPT)
ifdef ENABLE_PIC
  RTL_LIBS += $(libdir)/fbrt0pic.o $(libdir)/libfbpic.a
endif
ifndef DISABLE_MT
  RTL_LIBS += $(libdir)/libfbmt.a
  ifdef ENABLE_PIC
    RTL_LIBS += $(libdir)/libfbmtpic.a
  endif
endif

.PHONY: rtlib
rtlib: $(RTL_LIBS)

$(libfbobjdir) \
$(libfbmtobjdir) \
$(libfbpicobjdir) \
$(libfbmtpicobjdir) \
$(libdir):
	mkdir -p $@

$(libdir)/libfb.a: $(LIBFB_BAS) $(LIBFB_C) $(LIBFB_S) | $(libdir)
	rm -f $@
	@echo "AR $@"
	@$(AR) rcs $@ $^

$(libdir)/libfbmt.a: $(LIBFBMT_BAS) $(LIBFBMT_C) $(LIBFB_S) | $(libdir)
	rm -f $@
	@echo "AR $@"
	@$(AR) rcs $@ $^

$(libdir)/libfbpic.a: $(LIBFBPIC_BAS) $(LIBFBPIC_C) $(LIBFB_S) | $(libdir)
	rm -f $@
	@echo "AR $@"
	@$(AR) rcs $@ $^

$(libdir)/libfbmtpic.a: $(LIBFBMTPIC_BAS) $(LIBFBMTPIC_C) $(LIBFB_S) | $(libdir)
	rm -f $@
	@echo "AR $@"
	@$(AR) rcs $@ $^


$(libdir)/fbrt0.o: $(srcdir)/static/fbrt0.bas $(LIBFB_BI) | $(libdir)
	$(FBC) $(ALLFBRTFLAGS) -c $< -o $@

$(libdir)/fbrt0pic.o: $(srcdir)/static/fbrt0.bas $(LIBFB_BI) | $(libdir)
	$(FBC) -pic $(ALLFBRTFLAGS) -c $< -o $@


.PHONY: clean
clean:
	rm -rf $(RTL_LIBS) $(libfbobjdir)

INSTALL_FILE := cp

install: rtlib
	mkdir -p $(DESTDIR)$(prefixlibdir)
	$(INSTALL_FILE) $(RTL_LIBS) $(DESTDIR)$(prefixlibdir)
