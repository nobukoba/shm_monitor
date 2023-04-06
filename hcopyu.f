*
* $Id: hcopyu.F,v 1.1.1.1 1996/01/16 17:07:34 mclareni Exp $
*
* $Log: hcopyu.F,v $
* Revision 1.1.1.1  1996/01/16 17:07:34  mclareni
* First import
*
*
*#include "hbook/pilot.h"
*CMZ :  4.21/00 23/10/93  16.53.51  by  Rene Brun
*-- Author :    Rene Brun   29/03/91
      SUBROUTINE HCOPYU(ID,IPAWD,IOFSET)
*.==========>
*.           To copy histogram ID from IPAWD area to /PAWC/
*.           If ID=0 copy all histograms
*.           The copied histogram is stored as ID+IOFSET
*..=========> ( R.Brun)

#include "hbook/hcdire.inc"
      DIMENSION IHDIR(4)
      DIMENSION IPAWD(100)
*.___________________________________________

      NW=IPAWD(1)
      KOF=IPAWD(2)
      ILAST=IPAWD(NW)

*     Nobu added 2023.03.24 -->
*     For segv below.
*     
*     hrin2.f LOCF(IQUEST(1)    33687864
*     hrin2.f IQUEST(1)           0
*     hrin2.f LOC(IQUEST(1))            134751456
*     hrin2.f ICHTOP(ICDIR) -1342177280
*     hrin2.f ICDIR           2
*     hrin2.f LOCQ           1308489417
*     hrin2.f here 1
*     hrin2.f IQUEST(LOCQ)     1000000
*     hrin2.f here 2
*     in hcopyu.f NW     1000000
*     in hcopyu.f IPAWD(1)     1000000
*     in hcopyu.f LOCF(IPAWD(1))  1342177280
*     in hcopyu.f IPAWD(2)   266499470
*     in hcopyu.f ILAST = IPAWD(NW)           0
*     in hcopyu.f KOF   266499470
*     in hcopyu.f JR1  -266499470
*    
*     *** Break *** segmentation violation
*     
*     The lines below might hint at the cause of the crash.
*     You may get help by asking at the ROOT forum http://root.cern.ch/forum
*     Only if you are really convinced it is a bug in ROOT then please submit a
*     report at http://root.cern.ch/bugs Please post the ENTIRE stack trace
*     from above as an attachment in addition to anything else
*     that might help us fixing this issue.
*     ===========================================================
*     #5  0x00000000004497fa in hcopyu (id=216, ipawd=..., iofset=0) at hcopyu.f:54
*     #6  0x00000000004370cc in hrin (idd=216, icycle=999, kofset=0) at hbook.f:351
*     #7  0x000000000040f7c7 in convert_dir_hbk2root (cur_dir=0x7ffe3daf4cc0 "//FRED", output_dir=0xc0702c0) at convertfunc.cxx:1093
*     #8  0x000000000040c94c in shm2srv (shm_name=0x7ffe3daf4ef0 "FRED", port=5901, root_dir=0xc0702c0) at convertfunc.cxx:700
*     #9  0x000000000040d61e in shms2srv (shm_names=0x7ffe3daf5e7b "FRED", port=5901) at convertfunc.cxx:815
*     #10 0x000000000040877c in main (argc=3, argv=0x7ffe3daf53b8) at shm_monitor.cxx:35
*     ===========================================================
*
      IF(ILAST.LE.KOF)THEN
*         write(*,*) 'Check Point 1: ILAST.LE.KOF in hcopyu.f'
*         write(*,*) 'Check Point 1: ILAST, KOF', ILAST, KOF
         GO TO 99
      ENDIF
* --> Added on 2023.03.24 Nobu
      
*      write(*,*) 'in hcopyu.f NW', NW
*      write(*,*) 'in hcopyu.f IPAWD(1)', IPAWD(1)
*      write(*,*) 'in hcopyu.f LOCF(IPAWD(1))', LOCF(IPAWD(1))
*      write(*,*) 'in hcopyu.f IPAWD(2)', IPAWD(2)
*      write(*,*) 'in hcopyu.f ILAST = IPAWD(NW)', IPAWD(NW)
      JR1=ILAST-KOF
*      write(*,*) 'in hcopyu.f KOF', KOF
*      write(*,*) 'in hcopyu.f JR1', JR1
*     
*          Search levels down
*
      IF(NLPAT.GT.1)THEN
         DO 50 IL=2,NLPAT
            CALL UCTOH(CHPAT(IL),IHDIR,4,16)
            JR1=IPAWD(JR1-1)-KOF
  30        IF(JR1.EQ.0)GO TO 99
            DO 40 I=1,4
               IF(IHDIR(I).NE.IPAWD(JR1+I+8))THEN
                  JR1=IPAWD(JR1)-KOF
*      write(*,*) 'in hcopyu.f JR1', JR1
                  GO TO 30
               ENDIF
  40        CONTINUE
  50     CONTINUE
      ENDIF
*
      JCDIR = JR1
      JTAB  = IPAWD(JCDIR-3) -KOF
*

*     Nobu added 2023.03.24 -->
      ILAST=IPAWD(NW)
      IF(ILAST.LE.KOF)THEN
*         write(*,*) 'Check point 2: ILAST.LE.KOF in hcopyu.f'
*         write(*,*) 'Check point 2: ILAST, KOF', ILAST, KOF
         GO TO 99
      ENDIF
*     --> Nobu added
      IF(ID.NE.0)THEN
         CALL HCOPYN(IPAWD(9),IPAWD(1),ID,IOFSET,JTAB,KOF)
      ELSE
         NTOT =IPAWD(JTAB-1+8)
         DO 60 I=1,NTOT
            IF(IPAWD(JTAB-I).EQ.0)GO TO 60
            ID1=IPAWD(JTAB+I+8)
*     Nobu added 2023.03.24 -->
            ILAST=IPAWD(NW)
            IF(ILAST.LE.KOF)THEN
*               write(*,*) 'Check point 3: ILAST.LE.KOF in hcopyu.f'
*               write(*,*) 'Check point 3: ILAST, KOF', ILAST, KOF
               GO TO 99
            ENDIF
*     --> Nobu added
            CALL HCOPYN(IPAWD(9),IPAWD(1),ID1,IOFSET,JTAB,KOF)
  60     CONTINUE
      ENDIF
*
  99  RETURN
      END

      
