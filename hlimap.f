* $Id: hlimap.F,v 1.5 2003/06/04 15:01:57 couet Exp $
*
* $Log: hlimap.F,v $
* Revision 1.5  2003/06/04 15:01:57  couet
* - New COMMON block MMPSHR in order to share the variable IGOFF with the
*   PAW routine PAHIO. Without this, the reset of the histograms (via
*   GRESET) in shared memory, does not work.
*
* Revision 1.4  2001/10/10 08:10:08  couet
* - Call MZFROM to initialise IOCC which is used later in HLABEL to create
*   alphamuneric labels data bank in histograms.
*
* Revision 1.3  1998/04/08 14:12:20  couet
* - VIDQQ was not used, and was initialised as a wrong "what" string.
*
* Revision 1.2  1996/05/08 10:04:26  couet
* - Fix a typo
*
* Revision 1.1.1.1  1996/01/16 17:08:09  mclareni
* First import
*
*
*#include "hbook/pilot.h"
*CMZ :  4.22/12 13/09/94  12.32.24  by  Rene Brun
*-- Author :    Rene Brun         20/03/91
      SUBROUTINE HLIMAP(LIMIT,NAME)
*.==========>
*.            Initialization routine for HBOOK
*.
*.         The routine maps the file NAME to memory
*          using the routine HCREATEM.
*
*          Note that HBOOK does not delete the shared memory when the job
*          finishes. It is the user responsability to do it:
*          on SYSTEM 5 machines, one can list the current active shared memories
*          with the system command  ipcs -m
*          A shared memory can be deleted on these systems by:
*          ipcrm -m ID
*          If the size of the shared memory is increased, one must delete
*          first the old memory.
*
*          The ZEBRA store is created between the address
*          at the start of /PAWC/ and the end of the mapped region.
*
*          In case ZEBRA is not initialized, a dummy primary store
*          is created (BIDON)
*
*.            IF(LIMIT>0) CALL MZEBRA and MZPAW
*.                        and create a shared memory of size LIMIT
*.            IF(LIMIT=0) no calls to MZEBRA and MZPAW (HLIMIT already called)
*.                        only attach shared memory
*.            IF(LIMIT<0) Do not initialize ZEBRA (already done)
*.                        and create a shared memory of size -LIMIT
*..=========> ( R.Brun )
      COMMON/BIDON/IBID,FENBID(5),LQBID(10000)
#include "hbook/hcbook.inc"
#include "hbook/hcform.inc"
#include "hbook/hcdire.inc"
#include "hbook/hcunit.inc"
      CHARACTER*(*) NAME
      INTEGER     HCREATEM,HMAPM,HFREEM
      CHARACTER*4 GNAME
      CHARACTER*64 CHGLOB
      SAVE CHGLOB
*     nobu modified?
      COMMON /MMPSHR/ IGSIZE,IGOFF
*     nobu added
      INTEGER*8 IGSIZE,IGOFF
      DATA IGSIZE,IGOFF/0,0/
*     nobu added
      INTEGER*8 IOFFST,ILAST

*.___________________________________________
*
*. CASE  LIMIT=0   only attach shared memory
*. =========================================
*      write(*,*) '################# hlimap.f ######################'
      IF(LIMIT.EQ.0)THEN
*         write(*,*) 'hlimap.f: IGOFF', IGOFF
*         IF(IGOFF.GT.0) THEN
         IF(IGOFF.NE.0) THEN
            IERROR=HFREEM(IGOFF)
*            write(*,*) 'hlimap.f CHGLOB:', CHGLOB
            CALL HREND(CHGLOB)
         ENDIF
*         write(*,*) 'here in hlimap.f'
         NCH=LENOCC(NAME)
*         write(*,*) 'NCH', NCH
*         write(*,*) 'LENOCC(NAME)', LENOCC(NAME)
*         write(*,*) 'IGSIZE', IGSIZE
*         write(*,*) 'LQ(1)', LQ(1)
*         write(*,*) 'LOCF(LQ(1))', LOCF(LQ(1))
*         write(*,*) 'LOCF(LMAIN)', LOCF(LMAIN)
*         write(*,*) 'IGOFF', IGOFF
         IGSIZE=HMAPM(NAME,LQ,IGOFF)
*         write(*,*) 'IGSIZE', IGSIZE
*         write(*,*) 'LQ(1)', LQ(1)
*         write(*,*) 'LOCF(LQ(1))', LOCF(LQ(1))
*         write(*,*) 'LOCF(LMAIN)', LOCF(LMAIN)
*         write(*,*) 'IGOFF', IGOFF
         IF(IGSIZE.NE.0) THEN
            IGOFF=0
            IERROR=-IGSIZE
            WRITE(LERR,1000)IERROR,NAME(1:NCH)
1000        FORMAT(' ***** HLIMAP Error',I6,' mapping memory ',A)
            GO TO 99
         ENDIF
*         write(*,*) 'here in hlimap.f 3'
*
*           Connect Global Memory as a virtual HBOOK file.
*
         NCHT=NCHTOP
*         write(*,*) 'hlimap.f NAME:', NAME
*         write(*,*) 'IGOFF:', IGOFF 
*         write(*,*) 'LQ(IGOFF+1):', LQ(IGOFF+1)
*         write(*,*) 'LOC(LQ(IGOFF+1))/4:', LOC(LQ(IGOFF+1))/4
*     LQ(IGOFF+1) = 32000000
*         CALL HRFILE(32000000,NAME,'M')
         CALL HRFILE(LQ(IGOFF+1),NAME,'M')
         IF(NCHTOP.NE.NCHT)THEN
            HFNAME(NCHTOP)='Global memory  : '//NAME(1:NCH)
            CHGLOB=CHTOP(NCHTOP)
         ENDIF

         GO TO 99
      ENDIF
*         write(*,*) 'here in hlimap.f 4'
*.
*. All other cases create a new shared memory
*. ==========================================
      CALL HMACHI
*         write(*,*) 'here in hlimap.f 4'
*
*         write(*,*) 'here in hlimap.f 5'
      NHBOOK=IABS(LIMIT)
*         write(*,*) 'here in hlimap.f 5.5'
      IF(LIMIT.GE.0)THEN
*         write(*,*) 'here in hlimap.f 5.6'
         CALL MZEBRA(-3)
*         write(*,*) 'here in hlimap.f 5.7'
         CALL MZSTOR(IBID,'/BIDON/',' ',FENBID,LQBID,LQBID,LQBID,
     +     LQBID(2000),LQBID(10000))
*
      ENDIF
*      write(*,*) 'here in hlimap.f 6'
*
*      write(*,*) 'LQ(1)', LQ(1)
*      write(*,*) 'LOCF(LQ(1))', LOCF(LQ(1))
*      write(*,*) 'LOC(LQ(1))/4', LOC(LQ(1))/4
*      write(*,*) 'LOCF(LMAIN)', LOCF(LMAIN)

         GNAME=NAME
      IS = HCREATEM(GNAME, LQ, NHBOOK, IOFFST)
      IF (IS .EQ. 0) THEN
         PRINT *, 'GLOBAL MEMORY CREATED, offset from LQ =', IOFFST
      ELSE
         PRINT *, 'GLOBAL MEMORY ERROR = ',IS
         RETURN
      ENDIF
*
*          Option ':' disables checking of overlapping stores
*      write(*,*) 'hlimap 6 IXPAWC', IXPAWC
      CALL MZSTOR (IXPAWC,'/PAWC/',':',FENC,LQ(1),LQ(1),LQ(1),
     +            LQ(IOFFST+10),LQ(IOFFST+NHBOOK-10))
      NWPAW  = NHBOOK
*      write(*,*) 'hlimap 7 IXPAWC', IXPAWC
      CALL MZWORK(IXPAWC,LQ(2),LQ(IOFFST),0)
*
      IHDIV  = 0
      IXHIGZ = 0
      IXKU   = 0
*
*      write(*,*) 'hlimap 8 IXPAWC', IXPAWC
      CALL MZLINK(IXPAWC,'/HCBOOK/',LHBOOK,LCDIR,LCIDN)
      ILAST=IOFFST+NHBOOK
*      write(*,*) 'ILAST,IOFFST,NHBOOK', ILAST,IOFFST,NHBOOK
      
*      write(*,*) 'hlimap 9 IXPAWC', IXPAWC
      CALL MZLINK(IXPAWC,'HCMAP',LQ(ILAST),LQ(ILAST),LQ(ILAST))
*
***************************************************************
*                                                             *
*--   Structural links in LHBOOK and LCDIR                    *
*                                                             *
*      lq(lcdir-1)= lsdir : pointer to subdirectory          *
*      lq(lcdir-2)= lids  : pointer to 1st ID in directory   *
*      lq(lcdir-3)= ltab  : pointer to list of ordered IDs   *
*      lq(lcdir-4)= lbuf  : pointer to ntuple buffers        *
*      lq(lcdir-5)= ltmp  : pointer to ntuple buffers        *
*      lq(lcdir-6)= lhquad: pointer to HQUAD buffers         *
*      lq(lcdir-7)=       : free                             *
*      lq(lcdir-8)= labl  : used by HPLOT routine HPLABL     *
* R    lq(lcdir-9)= llid  : pointer to last ID in directory  *
* R    lq(lcdir-10)=      : free                             *
***************************************************************
*
*
*      write(*,*) 'hlimap 10 IXPAWC', IXPAWC
      IHWORK=IXPAWC+1
      IHDIV =IXPAWC+2
*
      CALL MZFORM('HDIR','4H -I',IODIR)
      CALL MZFORM('HID1','1B 2I 6F -H',IOH1)
      CALL MZFORM('HID2','1B 2I 3F 1I 4F -H',IOH2)
      CALL MZFORM('HIDN','11I -H',IOHN)
      CALL MZFORM('HIDT','13I -H',IONT)
      CALL MZFORM('HBLK','7I -H',IOBL)
      CALL MZFORM('HCF1','2I 2F 4D -F',IOCF1)
      CALL MZFORM('HCB1','2I 2F 4D -B',IOCB1)
      CALL MZFORM('HCF2','2I -F',IOCF2)
      CALL MZFORM('HCF4','4I -F',IOCF4)
      CALL MZFORM('HCB2','2I -B',IOCB2)
      CALL MZFORM('HFIT','10I -F',IOFIT)
      CALL MZFORM('LCHX','2I -H',IOCC)
*      write(*,*) 'hlimap 1 IHDIV, LCDIR', IHDIV, LCDIR
*      write(*,*) 'hlimap 1 LTAB, LHBOOK', LTAB, LHBOOK
      CALL MZBOOK(IHDIV,LCDIR,LHBOOK, 1,'HDIR',50,8,10,IODIR,0)
      CALL UCTOH('PAWC            ',IQ(LCDIR+1),4,16)
*      write(*,*) 'hlimap 2 IHDIV, LCDIR', IHDIV, LCDIR
*      write(*,*) 'hlimap 2 LTAB, LHBOOK', LTAB, LHBOOK
      CALL MZBOOK(IHDIV,LTAB ,LHBOOK,-3,'HTAB',500,0,500,2,0)
*      write(*,*) 'hlimap 3 LTAB', LTAB
*
      LMAIN =LHBOOK
*      write(*,*) 'hlimap LMAIN=LHBOOK', LMAIN
      LQ(ILAST)=LMAIN
*      write(*,*) 'hlimap ILAST', ILAST
*      write(*,*) 'hlimap IOFFST', IOFFST
*      write(*,*) 'hlimap NHBOOK', NHBOOK
      LQ(IOFFST+1)=NHBOOK
      LQ(IOFFST+2)=IOFFST
      NLCDIR=1
      NLPAT =1
      CHCDIR(1)='PAWC'
      NCHTOP=1
      CHTOP(1)='PAWC'
      HFNAME(1)='COMMON /PAWC/ in memory'
      ICHTOP(1)=0
      ICHLUN(1)=0
      ICDIR=1
*
  99  END
