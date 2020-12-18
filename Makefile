TARGETS   = shm_monitor

GCC_VER_GTEQ_5 = $(shell expr `gcc -dumpversion | cut -f1-2 -d.` \>= 5.0)
ifeq ($(GCC_VER_GTEQ_5),1)
PIEFLAGS  =  -O -no-pie
else
PIEFLAGS  =
endif

CC        = gcc $(PIEFLAGS)
CXX       = g++ $(PIEFLAGS)
FC        = gfortran $(PIEFLAGS)
CFLAGS    = 
FFLAGS    = -std=legacy -Wno-argument-mismatch
LFLAGS    = 
# Explicit version of ROOT is used
ROOTCONF  = /home/kobayash/cern/root_v6.22.06/bin/root-config
# Present version of ROOT is used
# ROOTCONF  = root-config
HAS_RPATH = $(shell $(ROOTCONF) --has-rpath)
ifeq ($(HAS_RPATH),yes)
CXXFLAGS  = $(shell $(ROOTCONF) --cflags)
ROOTLIBS  = $(shell $(ROOTCONF) --libs) -lRHTTP -lgfortran
else
CXXFLAGS  = $(shell $(ROOTCONF) --cflags)
ROOTLIBS  = $(shell $(ROOTCONF) --libs) -lRHTTP -lgfortran -Wl,-rpath,$(shell $(ROOTCONF) --libdir) -Wl,--disable-new-dtags
endif

all:	$(TARGETS)
shm_monitor: shm_monitor.o hlimap.o hidall.o mzwork.o hcreatem.o hshm.o hmapm.o hrin2.o hcopyu.o hcopyn.o hcopyt.o zebra.o hbook.o cernlib.o kernlib.o
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
