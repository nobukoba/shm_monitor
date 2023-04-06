TARGETS   = shm_monitor

CC        = gcc
CXX       = g++
FC        = gfortran
CFLAGS    = 
FFLAGS    = -I./ -cpp -std=legacy -Wno-argument-mismatch
LFLAGS    = 

OS_TYPE   = $(shell uname -s)
ifeq ($(OS_TYPE),Darwin)
# macOS
LIBS       = -L /usr/local/lib/gcc/12/ -lgfortran
else
# Linux
LIBS       = -lgfortran
endif

# Explicit version of ROOT is used
ROOTCONF  = /home/kobayash/cern/root_v6.22.06/bin/root-config
# Present version of ROOT is used
#ROOTCONF  = root-config
HAS_RPATH = $(shell $(ROOTCONF) --has-rpath)
ifeq ($(HAS_RPATH),yes)
CXXFLAGS  = $(shell $(ROOTCONF) --cflags)
ROOTLIBS  = $(shell $(ROOTCONF) --libs) -lRHTTP $(LIBS)
else
CXXFLAGS  = $(shell $(ROOTCONF) --cflags)
ROOTLIBS  = $(shell $(ROOTCONF) --libs) -lRHTTP $(LIBS) -Wl,-rpath,$(shell $(ROOTCONF) --libdir) -Wl,--disable-new-dtags
endif

all:	$(TARGETS)
shm_monitor: shm_monitor.o hlimap.o hidall.o mzwork.o hcreatem.o hshm.o hmapm.o hcopyu.o hcopyn.o hcopyt.o zebra.o hbook.o cernlib.o kernlib.o hbug.o hrdir.o hsifla.o hrdirm.o q_inc.o rzrdir.o
	$(CXX)     $(LFLAGS) -o $@ $^ $(ROOTLIBS)
%.o: %.cxx
	$(CXX)     $(CXXFLAGS) -c $<
%.o: %.c
	$(CC)      $(CFLAGS)   -c $<
%.o: %.f
	$(FC)      $(FFLAGS)   -c $<
.PHONY : clean
clean:
	rm -rf *.o $(TARGETS)
