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
CXXFLAGS  = $(shell /home/kobayash/cern/root_v6.20.04_rpath/bin/root-config --cflags)
ROOTLIBS  = $(shell /home/kobayash/cern/root_v6.20.04_rpath/bin/root-config --libs) -lRHTTP -lgfortran

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
