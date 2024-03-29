*-------------------------------------------------------------------------------
*
* This file contains the hbook's package subset needed to build h2root.
* It cannot be used by any hbook application because many hbook functionalities
* are missing.
*
*-------------------------------------------------------------------------------
      
      SUBROUTINE HNTVAR2(ID1,IVAR,CHTAG,CHFULL,BLOCK,NSUB,ITYPE,ISIZE
     +                  ,NBITS,IELEM)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcbits.inc"
      COMMON/BIGBUF/BIGB(32000000)
      character BIGB
      CHARACTER*(*)  CHTAG, CHFULL, BLOCK
      CHARACTER*80 VAR
      CHARACTER*32   NAME, SUBS
      LOGICAL        LDUM
      ID    = ID1
      IDPOS = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF (IDPOS .LE. 0) THEN
         print*,'Unknown N-tuple','HNTVAR',ID1
         RETURN
      ENDIF
      LCID  = LQ(LTAB-IDPOS)
      CHTAG = ' '
      NAME  = ' '
      BLOCK = ' '
      NSUB  = 0
      ITYPE = 0
      ISIZE = 0
      IELEM = 0
      ICNT  = 0
      IF (IVAR .GT. IQ(LCID+ZNDIM)) RETURN
      LBLOK = LQ(LCID-1)
      LCHAR = LQ(LCID-2)
      LINT  = LQ(LCID-3)
      LREAL = LQ(LCID-4)
  5   LNAME = LQ(LBLOK-1)
      IOFF = 0
      NDIM = IQ(LBLOK+ZNDIM)
      DO 10 I = 1, NDIM
         ICNT = ICNT + 1
         IF (ICNT .EQ. IVAR) THEN
            CALL HNDESC(IOFF, NSUB, ITYPE, ISIZE, NBITS, LDUM)
            LL = IQ(LNAME+IOFF+ZLNAME)
            LV = IQ(LNAME+IOFF+ZNAME)
            CALL UHTOC(IQ(LCHAR+LV), 4, NAME, LL)
            CALL UHTOC(IQ(LBLOK+ZIBLOK), 4, BLOCK, 8)
            IELEM = 1
            IF (NSUB .GT. 0) THEN
               VAR = NAME(1:LL)//'['
               DO 25 J = NSUB,1,-1
                  LP = IQ(LINT+IQ(LNAME+IOFF+ZARIND)+(J-1))
                  IF (LP .LT. 0) THEN
                     IE = -LP
                     CALL HITOC(IE, SUBS, LL, IERR)
                  ELSE
                     LL = IQ(LNAME+LP-1+ZLNAME)
                     LV = IQ(LNAME+LP-1+ZNAME)
                     CALL UHTOC(IQ(LCHAR+LV), 4, SUBS, LL)
                     LL1 = IQ(LNAME+LP-1+ZRANGE)
                     IE  = IQ(LINT+LL1+1)
                  ENDIF
                  IELEM = IELEM*IE
                  IF (J .EQ. NSUB) THEN
                     VAR = VAR(1:LENOCC(VAR))//SUBS(1:LL)
                  ELSE
                     VAR = VAR(1:LENOCC(VAR))//']['//SUBS(1:LL)
                  ENDIF
   25          CONTINUE
               VAR = VAR(1:LENOCC(VAR))//']'
            ELSE
               VAR = NAME(1:LL)
            ENDIF
            CHTAG  = NAME
            CHFULL = VAR
            RETURN
         ENDIF
         IOFF = IOFF + ZNADDR
  10  CONTINUE
      LBLOK = LQ(LBLOK)
      IF (LBLOK .NE. 0) GOTO 5
      END

*-------------------------------------------------------------------------------

      subroutine hntvar3(id,last,chvar)
      character *80 allvars
      common/callvars/allvars(100)
      common/calloff/ioffset(100)
      character *(*) chvar
      integer id,ivar,last
      save ivar
      data ivar/0/
      if (ivar.ne.0) then
         if (allvars(ivar).ne.chvar) then
            ivar = ivar+1
            allvars(ivar) = chvar
            ioffset(ivar) = 0
         endif
      else
         ivar = ivar+1
         allvars(ivar) = chvar
         ioffset(ivar) = 0
      endif
      ier = 0
      if (last.ne.0) then
         call hgnt1(id,'*',allvars,ioffset,-ivar,1,ier)
         allvars(1) = ' '
         ivar = 0
      endif
      end

*-------------------------------------------------------------------------------

      SUBROUTINE HLIMIT (LIMIT)
#include "hbook/hcbook.inc"
#include "hbook/hcform.inc"
#include "hbook/hcdire.inc"
*      write(*,*) 'NWPAW', NWPAW
*      write(*,*) 'LOC(NWPAW)', LOC(NWPAW)
*      write(*,*) 'LIMIT', LIMIT
      CALL HMACHI
      NHBOOK = IABS(LIMIT)
      IF (NHBOOK.LT.10000) NHBOOK=10000
      IF (LIMIT.GT.0) CALL MZEBRA(-3)
      IF(LIMIT.NE.0)CALL MZPAW(NHBOOK,' ')
      CALL MZLINK(IXPAWC,'/HCBOOK/',LHBOOK,LCDIR,LCIDN)
      IHWORK = IXPAWC+1
      IHDIV  = IXPAWC+2
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
      CALL MZFORM('HFIT','5I 5F -D',IOFIT)
      CALL MZFORM('LCHX','2I -H',IOCC)
*      write(*,*) 'HLIMIT LOCF(LHBOOK)', LOCF(LHBOOK)
      CALL MZBOOK(IHDIV,LCDIR,LHBOOK, 1,'HDIR',50,8,10,IODIR,0)
      CALL UCTOH('PAWC            ',IQ(LCDIR+1),4,16)
      CALL MZBOOK(IHDIV,LTAB ,LHBOOK,-3,'HTAB',500,0,500,2,0)
      LMAIN     = LHBOOK
      NLCDIR    = 1
      NLPAT     = 1
      CHCDIR(1) = 'PAWC'
      NCHTOP    = 1
      CHTOP(1)  = 'PAWC'
      HFNAME(1) = 'COMMON /PAWC/ in memory'
      ICHTOP(1) = 0
      ICHLUN(1) = 0
      ICDIR     = 1
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HROPEN(LUN,CHDIR,CFNAME,CHOPTT,LRECL,ISTAT)
#include "hbook/hcdire.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*(*) CFNAME,CHDIR,CHOPTT
      CHARACTER*8 CHOPT
*     Nobu added macOS 12.2.1 on 2022.04.16
*     gcc -v --> Apple clang version 13.1.6 (clang-1316.0.21.2.3)
*     gfortran -v --> gcc version 11.2.0 (Homebrew GCC 11.2.0_3)
*     for the error: RZMAKE. LRECP input value less than 50
      CHARACTER*16 CHDIRT
      CHOPT=CHOPTT
*     Nobu added for macOS 12.2.1 2022.04.16
      CHOPT=CHOPTT(1:LENOCC(CHOPTT))
      CHDIRT=CHDIR(1:LENOCC(CHDIR))
      CALL CLTOU(CHOPT)
      DO 10 I=1,NCHTOP
         IF(CFNAME.EQ.HFNAME(I))THEN
            print*, 'File already connected','HROPEN',0
            GO TO 99
         ENDIF
  10  CONTINUE
      IQ10=IQUEST(10)
      IF (INDEX(CHOPT,'F').EQ.0) THEN
         IC = MIN(LENOCC(CHOPT)+1,8)
         CHOPT(IC:IC) = 'C'
      ENDIF
*     Nobu modified 2022.04.16
*      CALL RZOPEN(LUN,CHDIR,CFNAME,CHOPT,LRECL,ISTAT)
      CALL RZOPEN(LUN,CHDIRT,CFNAME,CHOPT,LRECL,ISTAT)
  90  IF(ISTAT.NE.0)THEN
         print*, 'Cannot open file','HROPEN',0
         GO TO 99
      ENDIF
      IF (IQUEST(12).NE.0 ) THEN
         IC = MIN(LENOCC(CHOPT)+1,8)
         CHOPT(IC:IC) = 'X'
      ENDIF
      LRE=IQUEST(10)
      IQUEST(10)=IQ10
      IQUEST(99)=LRE
*     Nobu modified 2022.04.16
*      CALL HRFILE(LUN,CHDIR,CHOPT)
      CALL HRFILE(LUN,CHDIRT,CHOPT)
      IF(IQUEST(1).NE.0)THEN
         ISTAT=IQUEST(1)
*         print*,'>>>>>> CALL RZEND(CHDIR)'
*     Nobu modified 2022.04.16
*         CALL RZEND(CHDIR)
         CALL RZEND(CHDIRT)
         CLOSE(LUN)
         GO TO 90
      ENDIF
      IF(ICDIR.GT.0)HFNAME(ICDIR)=CFNAME
      IF(INDEX(CHOPT,'Q').EQ.0)IQUEST(10)=LRE
99    RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HRFILE(LUN,CHDIR,CHOPT)
#include "hbook/hcdire.inc"
#include "hbook/hcmail.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*(*) CHDIR,CHOPT
      CHARACTER*8   TAGS(2),CHOPTT
      DIMENSION IOPT(6)
      EQUIVALENCE (IOPTN,IOPT(1)),(IOPTG,IOPT(2)),(IOPTQ,IOPT(3))
      EQUIVALENCE (IOPTM,IOPT(4)),(IOPTO,IOPT(5)),(IOPTE,IOPT(6))
* Nobu added 2021.09.08
      INTEGER*8 LOCF
*      write(*,*) 'HRFILE: LUN', LUN
      IF(NCHTOP.GE.MXFILES)THEN
         print*, 'Too many open files','HRFILE',LUN
         GO TO 99
      ENDIF
      CALL HUOPTC(CHOPT,'NGQMOE',IOPT)
      IF(IOPTM.NE.0)IOPTG=1
      IQUEST(1)=0
      IF(IOPTG.EQ.0)THEN
         IF(IOPTN.NE.0)THEN
            IF(IOPTQ.NE.0)THEN
               NQUOT=IQUEST(10)
               IF(NQUOT.LT.100)NQUOT=100
               IF(NQUOT.GT.65000.AND.IOPTE.EQ.0)NQUOT=65000
            ELSE
               NQUOT=32000
            ENDIF
            TAGS(1) = 'HBOOK-ID'
            TAGS(2) = 'VARIABLE'
            NCH=LENOCC(CHOPT)
            IF(NCH.EQ.0)THEN
               CHOPTT='X'
            ELSE
               CHOPTT='X'//CHOPT(1:NCH)
            ENDIF
            CALL CLTOU(CHOPTT)
            I=INDEX(CHOPTT,'N')
            IF(I.NE.0)CHOPTT(I:I)='?'
            I=INDEX(CHOPTT,'E')
            IF(I.NE.0)CHOPTT(I:I)='N'
            IF(IOPTO.NE.0)THEN
               NWK=1
               CHOPTT(1:1)='?'
            ELSE
               NWK=2
            ENDIF
            IQ10=IQUEST(10)
            IF(INDEX(CHOPT,'C').NE.0) IQUEST(10)=IQUEST(99)
            print*,'>>>>>> CALL RZMAKE(...)'
*            CALL RZMAKE(LUN,CHDIR,NWK,'II',TAGS,NQUOT,CHOPTT)
            IQUEST(10)=IQ10
         ELSE
            IQ10=IQUEST(10)
            IF(INDEX(CHOPT,'C').NE.0) IQUEST(10)=IQUEST(99)
            CALL RZFILE(LUN,CHDIR,CHOPT)
            IQUEST(10)=IQ10
            IF(IQUEST(1).EQ.2)IQUEST(1)=0
            NWK=IQUEST(8)
         ENDIF
      ENDIF
      IF(IQUEST(1).NE.0)RETURN
      NCHTOP=NCHTOP+1
      CHTOP(NCHTOP)=CHDIR
      ICHLUN(NCHTOP)=0
      IF(IOPTG.EQ.0)THEN
         ICHTOP(NCHTOP)=LUN
         ICHTYP(NCHTOP)=NWK
         HFNAME(NCHTOP)=CHDIR
      ELSE
*         write(*,*) '-LOCF(LUN)', -LOCF(LUN)
*         write(*,*) '-LOC(LUN)/4', -LOC(LUN)/4
         ICHTOP(NCHTOP)=-LOCF(LUN)
         ICHTYP(NCHTOP)=0
*         write(*,*) 'ICHTOP(NCHTOP)', ICHTOP(NCHTOP)
         IF(IOPTM.EQ.0)THEN
            HFNAME(NCHTOP)='Global section - '//CHDIR
         ELSE
            HFNAME(NCHTOP)='Global memory  - '//CHDIR
         ENDIF
      ENDIF
  10  CHMAIL='//'//CHTOP(NCHTOP)
      CALL HCDIR(CHMAIL,' ')
  99  RETURN
      END

*-------------------------------------------------------------------------------
      
      SUBROUTINE HRIN(IDD,ICYCLE,KOFSET)
#include "hbook/hcntpar.inc"
#include "hbook/hntcur.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcdire.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*128 CHWOLD
      INTEGER       KEYS(2)
      DATA KHIDE,KHID1,KHID2,KHCO1,KHCO2/4HHIDE,4HHID1,4HHID2,
     +                                   4hHCO1,4HHCO2/
* Nobu added 2021.10.11 -->
      INTEGER*8 LOCQ
* <--
*     Nobu test lines 2021.10.11
*     CALL UCTOH ('KHIDE', KHIDE, 4,4)
*      CALL UCTOH ('KHID1', KHID1, 4,4)
*      CALL UCTOH ('KHID2', KHID2, 4,4)
*      CALL UCTOH ('KHCO1', KHCO1, 4,4)
*      CALL UCTOH ('KHCO1', KHCO1, 4,4)

      IOFSET=KOFSET
      IF(ICHTOP(ICDIR).LT.0)THEN
* c/o Nobu 2018/01/26 20:18:17 -->
*         print*, '>>>>>> HRIN: ICHTOP(ICDIR).LT.0'
* --> End
* Nobu added 2018/01/25 16:16:27 -->
         IF(INDEX(HFNAME(ICDIR),'memory').NE.0)THEN
            LOCQ=1-LOCF(IQUEST(1))-ICHTOP(ICDIR)
            LOCQ=1-LOC(IQUEST(1))/4-ICHTOP(ICDIR)
*            write(*,*) "hrin2.f LOCF(IQUEST(1)", LOCF(IQUEST(1))
*            write(*,*) "hrin2.f IQUEST(1)", IQUEST(1)
*            write(*,*) "hrin2.f LOC(IQUEST(1))", LOC(IQUEST(1))
*            write(*,*) "hrin2.f ICHTOP(ICDIR)", ICHTOP(ICDIR)
*            write(*,*) "hrin2.f ICDIR", ICDIR
*            write(*,*) "hrin2.f LOCQ", LOCQ
*            write(*,*) 'hrin2.f here 1'
*            write(*,*) "hrin2.f IQUEST(LOCQ)", IQUEST(LOCQ)
*            write(*,*) 'hrin2.f here 2'
            CALL HCOPYU(IDD,IQUEST(LOCQ),IOFSET)
*            write(*,*) "here in hrin2 1"
*         ELSE
*            LOCQ=1-LOCF(IQUEST(1))-ICHTOP(ICDIR)
*            CALL HCOPYM(IDD,IQUEST(LOCQ),IOFSET)
         ENDIF
         CALL SBIT1(IQ(LCID),5)
*         write(*,*) "hrin2.f IQUEST(LOCQ)", IQUEST(LOCQ)
         GO TO 80
* <-- End
      ENDIF
      IF(ICYCLE.GT.1000.AND.IDD.EQ.0)THEN
         CALL HPAFF(CHCDIR,NLCDIR,CHWOLD)
         LQ(LHBOOK-NLPAT-10)=LCDIR
      ENDIF
      NRHIST=IQ(LCDIR+KNRH)
      IF(KOFSET.EQ.99999.AND.NRHIST.GT.0)THEN
         IF(IQ(LTAB+NRHIST).GE.KOFSET)IOFSET=IQ(LTAB+NRHIST)+1000000
      ENDIF
      KEYS(2) = 0
      IQ42=0
      IDN=IDD
      IF(IDD.EQ.0)THEN
         KEYS(1) = 1
         CALL HRZIN(IHDIV,0,0,KEYS,9999,'SC')
         IDN=IQUEST(21)
         IQ42=IQUEST(22)
      ENDIF
   10 ID=IDN+IOFSET
      NRHIST=IQ(LCDIR+KNRH)
      IDPOS=LOCATI(IQ(LTAB+1),NRHIST,ID)
      INMEM=0
      IF(IDPOS.GT.0)THEN
         LC=LQ(LTAB-IDPOS)
         IF(JBIT(IQ(LC),5).EQ.0)THEN
            INMEM=1
         ELSE
            print*, '+Already existing histogram replaced','HRIN',ID
            CALL HDELET(ID)
            NRHIST=IQ(LCDIR+KNRH)
            IDPOS=-IDPOS+1
         ENDIF
      ENDIF
      KEYS(1) = IDN
      KEYS(2) = IQ42
      CALL HRZIN(IHDIV,0,0,KEYS,ICYCLE,'NC')
      IF(IQUEST(1).NE.0)GO TO 70
      IQ40=IQUEST(40)
      IQ41=IQUEST(41)
      IQ42=IQUEST(42)
      NWORDS=IQUEST(12)
      IOPTA=JBIT(IQUEST(14),4)
      IF(IOPTA.NE.0)GO TO 60
      IF(INMEM.NE.0)GO TO 60
      CALL HSPACE(NWORDS+1000,'HRIN  ',IDD)
      IF(IERR.NE.0)                    GO TO 70
      IDPOS=-IDPOS+1
      IF(NRHIST.GE.IQ(LTAB-1))THEN
         CALL MZPUSH(IHDIV,LTAB,500,500,' ')
      ENDIF
      DO 20 I=NRHIST,IDPOS,-1
         IQ(LTAB+I+1)=IQ(LTAB+I)
         LQ(LTAB-I-1)=LQ(LTAB-I)
   20 CONTINUE
      IF(LIDS.EQ.0)THEN
         KEYS(1) = IDN
         CALL HRZIN(IHDIV,LCDIR,-2,KEYS,ICYCLE,'ND')
         IF(IQUEST(1).NE.0)THEN
            print*, 'Bad sequence for RZ','HRIN',IDN
            GO TO 70
         ENDIF
         LIDS=LQ(LCDIR-2)
         LCID=LIDS
      ELSE
         LLID=LQ(LCDIR-9)
         KEYS(1) = IDN
         CALL HRZIN(IHDIV,LLID,  0,KEYS,ICYCLE,'ND')
         IF(IQUEST(1).NE.0)THEN
            print*, 'Bad sequence for RZ','HRIN',IDN
            GO TO 70
         ENDIF
         LCID=LQ(LLID)
      ENDIF
      IQ(LCID-5)=ID
      LQ(LCDIR-9)=LCID
      IQ(LCDIR+KNRH)=IQ(LCDIR+KNRH)+1
      IQ(LTAB+IDPOS)=ID
      LQ(LTAB-IDPOS)=LCID
      CALL SBIT1(IQ(LCID),5)
      IF(JBIT(IQ(LCID+KBITS),1).NE.0)THEN
         IF(IQ(LCID-4).EQ.KHIDE)THEN
            IQ(LCID-4)=KHID1
            L=LQ(LCID-1)
            IF(L.NE.0)IQ(L-4)=KHCO1
         ENDIF
      ENDIF
      IF(JBYT(IQ(LCID+KBITS),2,2).NE.0)THEN
         IF(IQ(LCID-4).EQ.KHIDE)THEN
            IQ(LCID-4)=KHID2
            L=LQ(LCID-1)
            IF(L.NE.0)IQ(L-4)=KHCO2
         ENDIF
      ENDIF
      IF(JBIT(IQ(LCID+KBITS),4).NE.0)THEN
         IF (IQ(LCID-2) .EQ. 2) THEN
            NCHRZ=IQ(LCID+11)
            IF(NCHRZ.LE.0)GO TO 30
            ITAG1=IQ(LCID+10)
            NW=IQ(LCID-1)-ITAG1+1
            NPLUS=32-ITAG1
            IF(NPLUS.GT.0)THEN
               CALL MZPUSH(IHDIV,LCID,0,NPLUS,' ')
               CALL UCOPY2(IQ(LCID+ITAG1),IQ(LCID+32),NW)
               IQ(LCID+9)=IQ(LCID+9)+NPLUS
               IQ(LCID+10)=32
            ENDIF
            CALL HPAFF(CHCDIR,NLCDIR,CHWOLD)
            NCHRZ=LENOCC(CHWOLD)
            CALL UCTOH(CHWOLD,IQ(LCID+12),4,NCHRZ)
            IQ(LCID+11)=NCHRZ
   30       IQ(LCID)=9999
            LC=LQ(LCID-1)
            CALL SBIT0(IQ(LC),1)
            IF(NCHRZ.LE.0)THEN
               NMORE=IQ(LCID+5)+3-IQ(LCID-3)
               IF(NMORE.GT.0)THEN
                  CALL MZPUSH(IHDIV,LCID,NMORE,0,' ')
               ENDIF
               IF(IQ(LCID+5).GE.1)THEN
                  DO 40 IB=1,IQ(LCID+5)
                     LQ(LCID-3-IB)=LC
                     LC=LQ(LC)
                     IF(LC.EQ.0)THEN
                        LC=LQ(LCID-1)
                        GO TO 60
                     ENDIF
   40             CONTINUE
                  LC=LQ(LCID-1)
               ENDIF
            ELSE
               IF(ICHTOP(ICDIR).LT.1000) THEN
                  print*, '>>>>>> CALL HRZKEY(IDN)'
******            CALL HRZKEY(IDN)
               ENDIF
               IQ(LCID+5)=IDN
            ENDIF
            GO TO 60
         ELSE
            NCHRZ=IQ(LCID+ZNCHRZ)
            IF(NCHRZ.LE.0)GO TO 50
            ITIT1=IQ(LCID+ZITIT1)
            NW=IQ(LCID-1)-ITIT1+1
            NPLUS=34-ITIT1
            IF(NPLUS.GT.0)THEN
               CALL MZPUSH(IHDIV,LCID,0,NPLUS,' ')
               CALL UCOPY2(IQ(LCID+ITIT1),IQ(LCID+34),NW)
               IQ(LCID+ZITIT1)=34
            ENDIF
            CALL HPAFF(CHCDIR,NLCDIR,CHWOLD)
            NCHRZ=LENOCC(CHWOLD)
            CALL UCTOH(CHWOLD,IQ(LCID+ZNCHRZ+1),4,NCHRZ)
            IQ(LCID+ZNCHRZ)=NCHRZ
   50       IQ(LCID)=9999
            LC = LQ(LCID-1)
            CALL SBIT0(IQ(LC),1)
            CALL SBIT0(IQ(LC),2)
            CALL SBIT0(IQ(LC),3)
            CALL HNMSET(ID,ZIBANK,0)
            CALL HNMSET(ID,ZITMP,0)
            IQ(LCID+ZIFTMP) = 2
            IQ(LCID+ZID)    = IDN
            NTCUR = 0
            GO TO 60
         ENDIF
      ENDIF
   60 IF(IQ40.EQ.0)GO TO 80
      IDN=IQ41
      IF(IDD.EQ.0)GO TO 10
   70 CONTINUE
   80 RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HRZIN(IXDIV,LBANK,JBIAS,KEYS,ICYCLE,CHOPT)
#include "hbook/hcbook.inc"
#include "hbook/hcdire.inc"
#include "hbook/hcmail.inc"
      COMMON/QUEST/IQUEST(100)
      DIMENSION LBANK(1),JBIAS(1)
      INTEGER      KEYS(2)
      CHARACTER*(*)CHOPT
      CHARACTER*1 FCHOPT
      CHARACTER*8 CHOPT1
      IF(ICHTOP(ICDIR).GT.1000)THEN
         print*, 'CZ option not active','HRZIN',0
         RETURN
      ENDIF
      CALL RZIN(IXDIV,LBANK,JBIAS,KEYS,ICYCLE,CHOPT)
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNOENT(IDD,NUMB)
#include "hbook/hcbook.inc"
      COMMON /QUEST/ IQUEST(100)
      CALL HFIND(IDD,'HNOENT')
      IF(IQUEST(1).NE.0)THEN
         NUMB=0
      ELSE
         I4=JBIT(IQ(LCID+KBITS),4)
         IF(I4.NE.0)THEN
            NUMB=IQ(LCID+3)
         ELSE
            NUMB=IQ(LCONT+KNOENT)
         ENDIF
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGIVE(IDD,CHTITL,NCX,XMIN,XMAX,NCY,YMIN,YMAX,NWT,IDB)
#include "hbook/hcbook.inc"
#include "hbook/hcbits.inc"
#include "hbook/hcntpar.inc"
      CHARACTER*(*) CHTITL
* Nobu added CHTITLT on 2022.04.16
* for macOS 12.2.1 clang & gfortran
      CHARACTER*(80) CHTITLT
      NARG=10
      NCX=0
      IF(NARG.GT.5)NCY=0
      IF(NARG.GT.8)NWT=0
      IF(NARG.GT.9)IDB=0
      CALL HFIND(IDD,'HGIVE ')
      IF(LCID.LE.0)GO TO 99
      CALL HDCOFL
      IF(I4.NE.0)THEN
         IF (IQ(LCID-2) .NE. ZLINK) THEN
            NCX   = IQ(LCID+2)
            IWT   = IQ(LCID+9)+LCID
            NWTIT = IQ(LCID+8)
         ELSE
            NCX   = IQ(LCID+ZNDIM)
            IWT   = IQ(LCID+ZITIT1)+LCID
            NWTIT = IQ(LCID+ZNWTIT)
         ENDIF
         XMIN=0.
         XMAX=0.
         YMIN=0.
         YMAX=0.
      ELSE
         NCX=IQ(LCID+KNCX)
         XMIN=Q(LCID+KXMIN)
         XMAX=Q(LCID+KXMAX)
         IWT=LCID+KTIT1
         IF(I230.NE.0)THEN
            IF(NARG.GT.5)NCY=IQ(LCID+KNCY)
            IF(NARG.GT.6)YMIN=Q(LCID+KYMIN)
            IF(NARG.GT.7)YMAX=Q(LCID+KYMAX)
            IWT=LCID+KTIT2
         ENDIF
         NWTIT=IQ(LCID-1)-IWT+LCID+1
      ENDIF
      IF(NARG.GT.9)IDB=LCID
      IF(NARG.LT.9)GO TO 99
      NWT=NWTIT
      IF(NWT.EQ.0)GO TO 99
* Nobu added on 2022.04.16
      CHTITLT=CHTITL(1:LENOCC(CHTITL))
* Nobu modified on 2022.04.16
*     NCH=LEN(CHTITL)
      NCH=LEN(CHTITLT)
      NWCH=MIN(NCH,4*NWT)
* Nobu modified on 2022.04.16
*      IF(NCH.GT.0)CHTITL=' '
      IF(NCH.GT.0)CHTITLT=' '
* Nobu modified on 2022.04.16
*      CALL UHTOC(IQ(IWT),4,CHTITL,NWCH)
      CALL UHTOC(IQ(IWT),4,CHTITLT,NWCH)
* Nobu added on 2022.04.16
      CHTITL(1:NWCH)=CHTITLT
 99   RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGIVEN( ID1, CHTITL, NVAR, TAGS, RLOW, RHIGH )
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcbits.inc"
#include "hbook/hcntpar.inc"
      CHARACTER*(*) CHTITL, TAGS(*)
      INTEGER       ID1, NVAR
      REAL          RLOW(*), RHIGH(*)
      CHARACTER*8   BLOCK
      LOGICAL       NTOLD
      NMAX = NVAR
      NVAR = 0
      ID     = ID1
      IDPOS  = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF( IDPOS.LE.0 ) RETURN
      IDLAST = ID1
      LCID   = LQ(LTAB-IDPOS)
      I4     = JBIT(IQ(LCID+KBITS),4)
      IF( I4.EQ.0 ) RETURN
      IF (IQ(LCID-2) .NE. ZLINK) THEN
         NTOLD = .TRUE.
      ELSE
         NTOLD = .FALSE.
      ENDIF
      IF (NTOLD) THEN
         NDIM  = IQ(LCID+2)
         LLIMS = LQ(LCID-2)
         ITAG1 = IQ(LCID+10)
         ITIT1 = IQ(LCID+9)
         NWTIT = IQ(LCID+8)
      ELSE
         NDIM  = IQ(LCID+ZNDIM)
         ITIT1 = IQ(LCID+ZITIT1)
         NWTIT = IQ(LCID+ZNWTIT)
      ENDIF
      NVAR = MIN(NDIM, NMAX)
      NCH = LEN(CHTITL)
      IF (NCH .GT. 0) CHTITL = ' '
      NCH = MIN( NCH, 4*NWTIT )
      IF (NCH .GT. 0) CALL UHTOC( IQ(LCID+ITIT1), 4, CHTITL, NCH )
      IF (NTOLD) THEN
         NCH = LEN( TAGS(1) )
         NCH = MIN( NCH, 8 )
         DO 10 I = 1, NVAR
            IF( NCH.GT.0 ) TAGS(I) = ' '
            IF( NCH.GT.0 )THEN
               TAGS(I)=' '
               CALL UHTOC( IQ(LCID+ITAG1+2*(I-1)), 4, TAGS(I), NCH )
            ENDIF
            RLOW (I) = Q(LLIMS+2*I-1)
            RHIGH(I) = Q(LLIMS+2*I)
  10     CONTINUE
      ELSE
         DO 20 I = 1, NVAR
            CALL HNTVAR(ID1, I, TAGS(I), BLOCK, NS, IT, IS, IE)
            RLOW(I)  = 0.0
            RHIGH(I) = 0.0
  20     CONTINUE
      ENDIF
      NVAR = NDIM
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNPAR(IDN,CHROUT)
#include "hbook/hcbook.inc"
      CHARACTER*(*) CHROUT
      INTEGER KEYS(2)
      LCIDN=0
      NIDN=LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),IDN)
      IF(NIDN.LE.0)THEN
         CALL HRIN(IDN,9999,0)
         NIDN=LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),IDN)
         IF(NIDN.LE.0)THEN
            print*, 'Unknown N-tuple',CHROUT,IDN
            RETURN
         ENDIF
      ENDIF
      LCIDN=LQ(LTAB-NIDN)
      I4=JBIT(IQ(LCIDN+KBITS),4)
      IF(I4.EQ.0)THEN
         print*, 'Not a N-tuple',CHROUT,IDN
         RETURN
      ENDIF
      IF (IQ(LCIDN-2) .NE. 2) THEN
         print*,'New N-tuple, this routine works only for old '//
     +             'N-tuples',CHROUT,IDN
         RETURN
      ENDIF
      NCHRZ=IQ(LCIDN+11)
      IF(NCHRZ.EQ.0)THEN
         NMORE=IQ(LCIDN+5)+3-IQ(LCIDN-3)
         IF(NMORE.GT.0)THEN
            CALL MZPUSH(IHDIV,LCIDN,NMORE,0,' ')
            LC=LQ(LCIDN-1)
            IF(IQ(LCIDN+5).GE.1)THEN
               DO 10 IB=1,IQ(LCIDN+5)
                  LQ(LCIDN-3-IB)=LC
                  LC=LQ(LC)
                  IF(LC.EQ.0)GO TO 999
   10          CONTINUE
            ENDIF
            GO TO 999
         ENDIF
      ENDIF
      LC=LQ(LCIDN-1)
      IF(JBIT(IQ(LC),1).NE.0)THEN
         CALL SBIT0(IQ(LC),1)
         KEYS(1) = IDN
         KEYS(2) = 0
         print*, '>>>>>> HRZOUT'
******   CALL HRZOUT(IHDIV,LCIDN,KEYS,ICYCLE,' ')
      ENDIF
  999 END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNF(IDN,IDNEVT,X,IERROR)
#include "hbook/hcbook.inc"
#include "hbook/hcdire.inc"
      COMMON/QUEST/IQUEST(100)
      DIMENSION X(*)
      INTEGER   KEYS(2)
      LC=LQ(LCIDN-1)
      NEVB=IQ(LC-1)/IQ(LCIDN+2)
      IBANK=(IDNEVT-1)/NEVB + 1
      IF(IQ(LCIDN+11).EQ.0)THEN
         LC=LQ(LCIDN-3-IBANK)
      ELSE
         IF(IQ(LCIDN).EQ.IBANK.OR.IQ(LCIDN+6).EQ.0)GO TO 20
         IF(IBANK.LE.IQ(LCIDN+6))THEN
            LKEY=LQ(LC)
            IF(LKEY.GT.0)THEN
               KEYS(1)=IQ(LKEY+IBANK)
               CALL HRZIN(IHDIV,LCIDN,-1,KEYS,99999,'RS')
            ELSE
               IF(ICHTYP(ICDIR).EQ.1)THEN
                  KEYS(1) = IQ(LCIDN+5)+10000*IBANK
                  KEYS(2) = 0
               ELSE
                  KEYS(1) = IQ(LCIDN+5)
                  KEYS(2) = IBANK
               ENDIF
               CALL HRZIN(IHDIV,LCIDN,-1,KEYS,99999,'R')
               IF(IQUEST(1).NE.0)GO TO 90
            ENDIF
         ELSE
            IOFSET=IDN-IQ(LCIDN+5)
            CALL HDELET(IDN)
            CALL HRIN(IDN-IOFSET,99999,IOFSET)
            NIDN=LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),IDN)
            LCIDN=LQ(LTAB-NIDN)
         ENDIF
         LC=LQ(LCIDN-1)
         IQ(LCIDN)=IBANK
      ENDIF
  20  IERROR=0
      IAD=IQ(LCIDN+2)*(IDNEVT-NEVB*(IBANK-1)-1)
      DO 30 I=1,IQ(LCIDN+2)
         X(I)=Q(LC+IAD+I)
  30  CONTINUE
      RETURN
  90  IERROR=1
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNT(IDN,IDNEVT,IERROR)
      CALL HGNT1(IDN, '*', '*', 0, 0, IDNEVT, IERROR)
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNT1(IDD,BLKNA1,VAR,IOFFST,NVAR,IDNEVT,IERROR)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hntcur.inc"
      CHARACTER*(*) BLKNA1, VAR(*)
      CHARACTER*8   BLKNAM, BLKSAV
      INTEGER       HNBPTR, IOFFST(*)
      LOGICAL       ALLBLK
      SAVE     BLKSAV
      DATA     BLKSAV /' '/
      IERR   = 0
      IERR1  = 0
      IERROR = 0
      IF (IDD.NE.IDLAST .OR. NTCUR.EQ.0) THEN
         CALL HPARNT(IDD,'HGNT')
         IF (IDD .EQ. 0) GOTO 20
         IDLAST = IDD
         BLKSAV = ' '
      ENDIF
      IF (LCID .LE. 0) GOTO 20
      CALL HNBUFR(IDD)
      IF (IERR .NE. 0) GOTO 20
      NTCUR = IDD
      IF (IDNEVT .LE. 0) GOTO 20
      BLKNAM = BLKNA1
      ALLBLK = .FALSE.
      IF (BLKNAM(1:1) .EQ. '*') THEN
         ALLBLK = .TRUE.
         LBLOK  = LQ(LCID-1)
         IF (IDNEVT .GT. IQ(LCID+ZNOENT)) GOTO 20
      ELSEIF (BLKSAV .NE. BLKNAM) THEN
         LBLOK = HNBPTR(BLKNAM)
         IF (LBLOK .EQ. 0) THEN
            print*, 'Block does not exist','HGNTB',IDD
            GOTO 20
         ENDIF
         BLKSAV = BLKNAM
         LQ(LCID-8) = LBLOK
         IF (IDNEVT .GT. IQ(LBLOK+ZNOENT)) GOTO 20
      ELSE
         LBLOK = LQ(LCID-8)
         IF (IDNEVT .GT. IQ(LBLOK+ZNOENT)) GOTO 20
      ENDIF
      LCHAR = LQ(LCID-2)
      LINT  = LQ(LCID-3)
      LREAL = LQ(LCID-4)
      IQ(LTMP1+1) = 0
      IF (ALLBLK) THEN
   10    CALL HGNT2(VAR, IOFFST, NVAR, IDNEVT, IERROR)
         IF (IERROR .NE. 0) IERR1 = 1
         LBLOK = LQ(LBLOK)
         IF (LBLOK .NE. 0) GOTO 10
      ELSE
         CALL HGNT2(VAR, IOFFST, NVAR, IDNEVT, IERROR)
         IF (IERROR .NE. 0) IERR1 = 1
      ENDIF
      IF (IERR1 .EQ. 0) THEN
         IQ(LTMP+1) = IDNEVT
      ELSE
         IQ(LTMP+1) = 0
         IERROR = 2
      ENDIF
      RETURN
   20 IERROR = 1
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNT2(VAR1,IVOFF,NVAR1,IDNEVT,IERROR)
#include "hbook/hcntpar.inc"
#include "hbook/hcnt.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcrecv.inc"
      CHARACTER*(*) VAR1(*)
      INTEGER       IVOFF(*)
      CHARACTER*32  VAR
      INTEGER       ILOGIC, HNMPTR
      LOGICAL       LOGIC, INDVAR, ALLVAR, USEBUF, CHKOFF
      EQUIVALENCE  (LOGIC, ILOGIC)
      IERROR = 0
      IERR1  = 0
      LNAME  = LQ(LBLOK-1)
      CHKOFF = .FALSE.
      USEBUF = .FALSE.
      NVAR   = NVAR1
      IF (NVAR .LT. 0) THEN
         NVAR   = -NVAR
         CHKOFF = .TRUE.
      ENDIF
      IF (NVAR .EQ. 0) THEN
         ALLVAR = .TRUE.
         IOFF   = 0
         NDIM   = IQ(LBLOK+ZNDIM)
      ELSE
         ALLVAR = .FALSE.
         NDIM   = NVAR
      ENDIF
      DO 40 I = 1, NDIM
         IF (.NOT.ALLVAR) THEN
            VAR  = VAR1(I)
            print*, '>>>>>> IOFF = HNMPTR(VAR)'
******      IOFF = HNMPTR(VAR)
            IF (IOFF .LT. 0) GOTO 40
            INDX = IOFF/ZNADDR + 1
            IF (CHKOFF) THEN
               IF (IVOFF(I) .NE. 0) THEN
                  USEBUF = .TRUE.
                  IOFFST = IVOFF(I)
               ELSE
                  USEBUF = .FALSE.
                  IOFFST = 0
               ENDIF
            ENDIF
         ELSE
            INDX = I
         ENDIF
         NSUB  = JBYT(IQ(LNAME+IOFF+ZDESC), 18, 3)
         ITYPE = JBYT(IQ(LNAME+IOFF+ZDESC), 14, 4)
         ISIZE = JBYT(IQ(LNAME+IOFF+ZDESC), 8,  6)
         NBITS = JBYT(IQ(LNAME+IOFF+ZDESC), 1,  7)
         INDVAR = .FALSE.
         IF (JBIT(IQ(LNAME+IOFF+ZDESC),28) .EQ. 1) INDVAR = .TRUE.
         IF (.NOT.NRECOV .AND. IQ(LNAME+IOFF+ZNADDR).EQ.0) GOTO 35
         IF (ITYPE .EQ. 5) THEN
            NBITS = IBIPB*ISIZE
            MXBY  = ISHFT(ISIZE,-2)
            MXBY1 = MXBY
            IF (JBIT(IQ(LQ(LCID-1)),3) .NE. 0) MXBY1 = 8
         ENDIF
         IF (IQ(LNAME+IOFF+ZITMP) .EQ. 0) THEN
            IQ(LNAME+IOFF+ZITMP) = IQ(LCID+ZIFTMP)
            IQ(LCID+ZIFTMP) = IQ(LCID+ZIFTMP) + ZNTMP
         ENDIF
         ITMP = IQ(LNAME+IOFF+ZITMP)
         IEDIF = 0
         IELEM = 1
         NELEM = 1
         INEVT = IDNEVT
         DO 10 J = 1, NSUB
            LP = IQ(LINT+IQ(LNAME+IOFF+ZARIND)+(J-1))
            IF (LP .LT. 0) THEN
               IELEM = IELEM*(-LP)
               NELEM = IELEM
            ELSE
               IF (IQ(LNAME+LP-1+ZNADDR) .EQ. 0) THEN
                  print*,'Address of index variable not set',
     +                      'HGNT',ID
                  GOTO 35
               ENDIF
               LL    = IQ(LNAME+LP-1+ZRANGE)
               IEMAX = IELEM*IQ(LINT+LL+1)
               IPTMP = IQ(LNAME+LP-1+ZITMP)
               INEVT = (IQ(LTMP+IPTMP+4) * IELEM) + 1
               IELEM = IELEM*IQ(LTMP+IPTMP+5)
               NELEM = 1
               IEDIF = IEMAX - IELEM
            ENDIF
   10    CONTINUE
         LCIND = IQ(LNAME+IOFF+ZLCONT)
         LRECL = IABS(IQ(LCID+ZNPRIM)) - 1
         IF (IQ(LTMP+1).NE.0 .AND. IDNEVT.EQ.IQ(LTMP+1)+1) THEN
            IBANK  = IQ(LTMP+ITMP)
            IFIRST = IQ(LTMP+ITMP+1)
            NB     = IQ(LTMP+ITMP+2)
            NLEFT  = IQ(LTMP+ITMP+3)
         ELSE
            IB = NBITS
            NW = 1
            IF (ISIZE .GT. IBYPW) THEN
               NW = ISIZE/IBYPW
               IB = NBITS/NW
            ENDIF
            IPW = IBIPW/IB
            NWRD = (INEVT-1)*NELEM*NW/IPW
            IBANK = NWRD/LRECL + 1
            IFIRST = MOD(NWRD+2, LRECL)
            IF (IFIRST .EQ. 0) IFIRST = LRECL
            IF (IFIRST .EQ. 1) IFIRST = LRECL + 1
            NB = (INEVT-1)*NELEM*NW*IB - NWRD*IB*IPW
            NLEFT = LRECL - IFIRST + 2
            NLEFT = NLEFT*IBIPW - NB
         ENDIF
         IF (IELEM .GT. 0) THEN
            IF (IQ(LNAME+IOFF+ZIBANK) .EQ. IBANK) THEN
               LR2 = LQ(LNAME-INDX)
            ELSE
               CALL HNTRD(INDX, IOFF, IBANK, IER)
               IF (IER .NE. 0) THEN
                  IERR1 = 1
                  GOTO 32
               ENDIF
            ENDIF
         ENDIF
         DO 30 J = 1, IELEM
            IM = IAND(NB, IBIPW-1)
            IF (IM.NE.0 .AND. NBITS.GT.IBIPW-IM) THEN
               NB     = 0
               NLEFT  = NLEFT - IBIPW+IM
               IFIRST = IFIRST + 1
            ENDIF
            IF (NBITS .GT. NLEFT) THEN
               IBANK = IBANK + 1
               CALL HNTRD(INDX, IOFF, IBANK, IER)
               IF (IER .NE. 0) THEN
                  IERR1 = 1
                  GOTO 32
               ENDIF
               NB     = 0
               NLEFT  = LRECL*IBIPW
               IFIRST = 2
            ENDIF
            IF (NRECOV .AND. .NOT.INDVAR) GOTO 25
            IF (ITYPE .EQ. 1) THEN
               IF (ISIZE .EQ. 4) THEN
                  IF (NBITS .EQ. 32) THEN
                     IF (USEBUF) THEN
                        Q(IOFFST+1) = Q(LR2+IFIRST)
                     ELSE
                        Q(IQ(LNAME+IOFF+ZNADDR)+J) = Q(LR2+IFIRST)
                     ENDIF
                  ELSE
                     RMIN  = Q(LREAL+IQ(LNAME+IOFF+ZRANGE))
                     RMAX  = Q(LREAL+IQ(LNAME+IOFF+ZRANGE)+1)
                     IPACK = JBYT(IQ(LR2+IFIRST), NB+1, NBITS)
                     IF (USEBUF) THEN
                        Q(IOFFST+1) = IPACK *
     +                          (RMAX - RMIN)/(ISHFT(1,NBITS)-1) + RMIN
                     ELSE
                        Q(IQ(LNAME+IOFF+ZNADDR)+J) = IPACK *
     +                          (RMAX - RMIN)/(ISHFT(1,NBITS)-1) + RMIN
                     ENDIF
                  ENDIF
               ELSEIF (ISIZE .EQ. 8) THEN
                  IF (NBITS .EQ. 64) THEN
                     IF (USEBUF) THEN
                        Q(IOFFST+1) = Q(LR2+IFIRST+1)
                        Q(IOFFST+2) = Q(LR2+IFIRST)
                     ELSE
                        Q(IQ(LNAME+IOFF+ZNADDR)+2*J-1) = Q(LR2+IFIRST+1)
                        Q(IQ(LNAME+IOFF+ZNADDR)+2*J)   = Q(LR2+IFIRST)
                     ENDIF
                  ELSE
                  ENDIF
               ENDIF
            ELSEIF (ITYPE .EQ. 2) THEN
               IF (ISIZE .EQ. 2) THEN
 
               ELSEIF (ISIZE .EQ. 4) THEN
                  IF (INDVAR) THEN
                     IF (USEBUF) THEN
                        IQ(IOFFST+1) = IQ(LR2+IFIRST) -
     +                                 IQ(LR2+IFIRST-1)
                        IQ(LTMP+ITMP+5) = IQ(IOFFST+1)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+J) = IQ(LR2+IFIRST) -
     +                                                IQ(LR2+IFIRST-1)
                        IQ(LTMP+ITMP+5) = IQ(IQ(LNAME+IOFF+ZNADDR)+J)
                     ENDIF
                     IQ(LTMP+ITMP+4) = IQ(LR2+IFIRST-1)
                  ELSEIF (NBITS .EQ. 32) THEN
                     IF (USEBUF) THEN
                        IQ(IOFFST+1) = IQ(LR2+IFIRST)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+J) = IQ(LR2+IFIRST)
                     ENDIF
                  ELSE
                     IF (JBIT(IQ(LR2+IFIRST), NB+NBITS) .EQ. 1) THEN
                        IF (USEBUF) THEN
                           IQ(IOFFST+1) =
     +                           -JBYT(IQ(LR2+IFIRST), NB+1, NBITS-1)
                        ELSE
                           IQ(IQ(LNAME+IOFF+ZNADDR)+J) =
     +                           -JBYT(IQ(LR2+IFIRST), NB+1, NBITS-1)
                        ENDIF
                     ELSE
                        IF (USEBUF) THEN
                           IQ(IOFFST+1) =
     +                            JBYT(IQ(LR2+IFIRST), NB+1, NBITS-1)
                        ELSE
                           IQ(IQ(LNAME+IOFF+ZNADDR)+J) =
     +                            JBYT(IQ(LR2+IFIRST), NB+1, NBITS-1)
                        ENDIF
                     ENDIF
                  ENDIF
               ELSEIF (ISIZE .EQ. 8) THEN
                  IF (NBITS .EQ. 64) THEN
                     IF (USEBUF) THEN
                        IQ(IOFFST+1) = IQ(LR2+IFIRST)
                        IQ(IOFFST+2) = IQ(LR2+IFIRST+1)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+2*J-1)=IQ(LR2+IFIRST)
                        IQ(IQ(LNAME+IOFF+ZNADDR)+2*J)=IQ(LR2+IFIRST+1)
                     ENDIF
                  ELSE
                  ENDIF
               ENDIF
            ELSEIF (ITYPE .EQ. 3) THEN
               IF (ISIZE .EQ. 2) THEN
 
               ELSEIF (ISIZE .EQ. 4) THEN
                  IF (NBITS .EQ. 32) THEN
                     IF (USEBUF) THEN
                        IQ(IOFFST+1) = IQ(LR2+IFIRST)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+J) = IQ(LR2+IFIRST)
                     ENDIF
                  ELSE
                     IF (USEBUF) THEN
                        IQ(IOFFST+1) =
     +                         JBYT(IQ(LR2+IFIRST), NB+1, NBITS)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+J) =
     +                         JBYT(IQ(LR2+IFIRST), NB+1, NBITS)
                     ENDIF
                  ENDIF
               ELSEIF (ISIZE .EQ. 8) THEN
                  IF (NBITS .EQ. 64) THEN
                     IF (USEBUF) THEN
                        IQ(IOFFST+1)=IQ(LR2+IFIRST)
                        IQ(IOFFST+2)=IQ(LR2+IFIRST+1)
                     ELSE
                        IQ(IQ(LNAME+IOFF+ZNADDR)+2*J-1)=IQ(LR2+IFIRST)
                        IQ(IQ(LNAME+IOFF+ZNADDR)+2*J)=IQ(LR2+IFIRST+1)
                     ENDIF
                  ELSE
                  ENDIF
               ENDIF
            ELSEIF (ITYPE .EQ. 4) THEN
               IF (ISIZE .EQ. 1) THEN
 
               ELSEIF (ISIZE .EQ. 2) THEN
 
               ELSEIF (ISIZE .EQ. 4) THEN
                  ILOGI = JBYT(IQ(LR2+IFIRST), NB+1, NBITS)
                  IF (ILOGI .EQ. 1) THEN
                     LOGIC = .TRUE.
                  ELSE
                     LOGIC = .FALSE.
                  ENDIF
                  IF (USEBUF) THEN
                     IQ(IOFFST+1) = ILOGIC
                  ELSE
                     IQ(IQ(LNAME+IOFF+ZNADDR)+J) = ILOGIC
                  ENDIF
               ENDIF
            ELSEIF (ITYPE .EQ. 5) THEN
               IF (USEBUF) THEN
                  CALL HRZFRA(IQ(LR2+IFIRST),IQ(IOFFST+1),MXBY)
               ELSE
                  CALL HRZFRA(IQ(LR2+IFIRST),
     +                        IQ(IQ(LNAME+IOFF+ZNADDR)+MXBY1*(J-1)+1),
     +                        MXBY)
               ENDIF
            ENDIF
   25       NB = NB + NBITS
            IF (ISHBIT .NE. 0) THEN
               IFIRST = IFIRST + ISHFT(NB,-ISHBIT)
            ELSE
               IFIRST = IFIRST + NB/IBIPW
            ENDIF
            NB     = IAND(NB, IBIPW-1)
            NLEFT  = NLEFT - NBITS
            IF (USEBUF) IOFFST = IOFFST + ISHFT(ISIZE,-2)
   30    CONTINUE
         IQ(LTMP+ITMP)   = IBANK
         IQ(LTMP+ITMP+1) = IFIRST
         IQ(LTMP+ITMP+2) = NB
         IQ(LTMP+ITMP+3) = NLEFT
   32    IQ(LTMP1+1) = IQ(LTMP1+1) + 1
         JTMP = ZNTMP1*(IQ(LTMP1+1)-1) + 2
         IQ(LTMP1+JTMP)        = INDX
         IQ(LTMP1+JTMP+1)      = IOFF
         IF (USEBUF) THEN
            IF (IEDIF .EQ. 0) THEN
               IQ(LTMP1+JTMP+2) = IOFFST
            ELSE
               IQ(LTMP1+JTMP+2) = IOFFST + (IEDIF*ISHFT(ISIZE,-2))
            ENDIF
         ELSE
            IQ(LTMP1+JTMP+2)   = 0
         ENDIF
         LQ(LTMP1-IQ(LTMP1+1)) = LBLOK
   35    IOFF = IOFF + ZNADDR
   40 CONTINUE
      IF (IERR1 .NE. 0) THEN
         IERROR = 1
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HDCOFL
#include "hbook/hcbits.inc"
#include "hbook/hcbook.inc"
      DIMENSION IFLAG(37)
      EQUIVALENCE       (IFLAG(1),I1)
      IF(IQ(LCID-2).NE.0)THEN
         DO 10 J=1,31
  10     IFLAG(J)=JBIT(IQ(LCID+KBITS),J)
      ELSE
         CALL VZERO(IFLAG,31)
      ENDIF
      I230=I2+I3
      I123=   I1+I230
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HDELET(ID1)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcpiaf.inc"
#include "hbook/hcache.inc"
      IF(LCDIR.LE.0)GO TO 999
      IF(ID1.EQ.0)GO TO 120
      ID=ID1
      IDPOS=LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF(IDPOS.LE.0)THEN
         print*, 'Unknown histogram','HDELET',ID1
         GO TO 999
      ENDIF
      LCID=LQ(LTAB-IDPOS)
      IF (JBIT(IQ(LCID+KBITS),4).NE.0 .AND. IQ(LCID-2).EQ.ZLINK) THEN
         CALL HNBUFD(ID1)
      ENDIF
      CALL MZDROP(IHDIV,LCID,' ')
      LIDS=LQ(LCDIR-2)
      LQ(LTAB-IDPOS)=0
      NRHIST=IQ(LCDIR+KNRH)
      DO 10 I=IDPOS,NRHIST-1
         IQ(LTAB+I)=IQ(LTAB+I+1)
         LQ(LTAB-I)=LQ(LTAB-I-1)
  10  CONTINUE
      IQ(LCDIR+KNRH)=NRHIST-1
      NRHIST=IQ(LCDIR+KNRH)
      IF(LQ(LCDIR-9).EQ.LCID)THEN
         LREF=0
         LCID=LIDS
  20     IF(LCID.NE.0)THEN
            LREF=LCID
            LCID=LQ(LCID)
            GO TO 20
         ENDIF
         LQ(LCDIR-9)=LREF
      ENDIF
      GO TO 999
 120  IF(LIDS .GT. 0) THEN
         CALL HNBUFD(0)
         CALL MZDROP(IHDIV,LIDS ,'L')
      ENDIF
      NRHIST=IQ(LCDIR+KNRH)
      IF(NRHIST.GT.0.AND.LTAB.GT.0)THEN
         CALL VZERO(LQ(LTAB-NRHIST),NRHIST)
      ENDIF
      IQ(LCDIR+KNRH)=0
      LQ(LCDIR-2)=0
      LQ(LCDIR-9)=0
      LIDS=0
      LLID=0
      NRHIST=0
  999 IDLAST=0
      IDHOLD=0
      LID   =0
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HBNAM(IDD, BLKNA1, ADDRES, FORM1, ISCHAR)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcform.inc"
      INTEGER        IDD, ADDRES, HNBPTR
      CHARACTER*(*)  BLKNA1, FORM1
      PARAMETER     (MAXTOK = 50)
      CHARACTER*8    BLKNAM
      CHARACTER*40   SFORM
      CHARACTER*80   TOK(MAXTOK)
      CHARACTER*1300 FORM
      LOGICAL        ISCHAR
      IF (IDD .NE. IDLAST) THEN
         ID    = IDD
         IDPOS = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
         IF (IDPOS .LE. 0) THEN
            print*, 'nTuple does not exist.','HBNAME',IDD
            RETURN
         ENDIF
         IDLAST = ID
         LCID   = LQ(LTAB-IDPOS)
         I4 = JBIT(IQ(LCID+KBITS),4)
         IF (I4 .EQ. 0) RETURN
         IF (IQ(LCID-2) .NE. ZLINK) THEN
            print*,'HBNAME cannot be used for Row-wise nTuples',
     +                'HBNAME',IDD
            RETURN
         ENDIF
      ENDIF
      BLKNAM = BLKNA1
      IF (LENOCC(BLKNA1) .GT. LEN(BLKNAM)) THEN
         PRINT *, '*** Warning: Block name truncated to: ', BLKNAM
      ENDIF
      CALL CLTOU(BLKNAM)
      IF (LENOCC(FORM1) .GT. LEN(FORM)) THEN
         print*, 'CHFORM string too long','HBNAME',IDD
         RETURN
      ENDIF
      FORM = FORM1
      IADD = ADDRES
      LBLOK  = LQ(LCID-1)
      LCHAR  = LQ(LCID-2)
      LINT   = LQ(LCID-3)
      LREAL  = LQ(LCID-4)
      SFORM = FORM
      CALL CLTOU(SFORM)
      IF (SFORM(1:6) .EQ. '$CLEAR') THEN
         CALL HNMSET(IDD, ZNADDR, 0)
         CALL SBIT0(IQ(LBLOK),3)
         RETURN
      ELSEIF (SFORM(1:4).EQ.'$SET' .OR. SFORM(1:4).EQ.'!SET') THEN
         IF (SFORM(1:1) .EQ. '!') CALL SBIT1(IQ(LBLOK),3)
         LBLOK = HNBPTR(BLKNAM)
         IF (LBLOK .EQ. 0) THEN
            print*, 'Unknown block '//BLKNAM,'HBNAME',IDD
            RETURN
         ENDIF
         LNAME = LQ(LBLOK-1)
         LSF = LENOCC(SFORM)
         I = INDEX(SFORM,':')
         IF (I.GT.0 .AND. LSF.GT.5) THEN
            CALL HNMADR(SFORM(I+1:LSF), IADD, ISCHAR)
         ELSE
            CALL HNMADR('*', IADD, ISCHAR)
         ENDIF
         RETURN
      ENDIF
      print*, '>>>>>> Should not be here when called from h2root'
      END

*-------------------------------------------------------------------------------

      FUNCTION HI(IDD,I)
      CALL HFIND(IDD,'HI    ')
      HI=HCX(I,1)
      END

*-------------------------------------------------------------------------------

      FUNCTION HIE(IDD,I)
#include "hbook/hcbook.inc"
      CALL HFIND(IDD,'HIE   ')
      IF(JBIT(IQ(LCID+KBITS),9).NE.0)THEN
         HIE=HCX(I,2)
      ELSE
         RES=ABS(HCX(I,1))
         HIE=SQRT(RES)
      ENDIF
      END

*-------------------------------------------------------------------------------

      FUNCTION HIF(IDD,I)
      CALL HFIND(IDD,'HIF   ')
      HIF=HCX(I,3)
      END

*-------------------------------------------------------------------------------

      FUNCTION HIJ(IDD,I,J)
      CALL HFIND(IDD,'HIJ   ')
      HIJ=HCXY(I,J,1)
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HIX(IDD,I,X)
#include "hbook/hcbook.inc"
#include "hbook/hcbits.inc"
      CALL HFIND(IDD,'HIX   ')
      CALL HDCOFL
      IF(I6.EQ.0)THEN
         DX=(Q(LCID+KXMAX)-Q(LCID+KXMIN))/FLOAT(IQ(LCID+KNCX))
         X=FLOAT(I-1)*DX+Q(LCID+KXMIN)
      ELSE
         LBINS=LQ(LCID-2)
         X=Q(LBINS+I)
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HIJXY(IDD,I,J,X,Y)
#include "hbook/hcbook.inc"
      CALL HFIND(IDD,'HIJXY ')
      DX=(Q(LCID+KXMAX)-Q(LCID+KXMIN))/FLOAT(IQ(LCID+KNCX))
      DY=(Q(LCID+KYMAX)-Q(LCID+KYMIN))/FLOAT(IQ(LCID+KNCY))
      X=FLOAT(I-1)*DX+Q(LCID+KXMIN)
      Y=FLOAT(J-1)*DY+Q(LCID+KYMIN)
      END

*-------------------------------------------------------------------------------

      FUNCTION HIJE(IDD,I,J)
      CALL HFIND(IDD,'HIJE  ')
      HIJE=HCXY(I,J,2)
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HCDIR(CHPATH,CHOPT)
#include "hbook/hcbook.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcunit.inc"
#include "hbook/hcdire.inc"
#include "hbook/hcmail.inc"
#include "hbook/hcpiaf.inc"
#include "hbook/czsock.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*2   NODIR
      PARAMETER    (NODIR = '@#')
      CHARACTER*128 CHAIN, CACHE
      DIMENSION     IOPTV(2),IHDIR(4)
      EQUIVALENCE  (IOPTR,IOPTV(1)), (IOPTP,IOPTV(2))
      CHARACTER*(*) CHPATH,CHOPT
      SAVE  CACHE
      DATA  CACHE  /NODIR/
*      write(*,*) 'HCDIR routine LHBOOK', LHBOOK
      IF(LHBOOK.EQ.0)GO TO 99
      CALL HUOPTC (CHOPT,'RP',IOPTV)
      IF(IOPTR.NE.0)THEN
         CALL HPAFF(CHCDIR,NLCDIR,CHPATH)
         GO TO 99
      ENDIF
      IF(IOPTP.NE.0)THEN
         CALL HPAFF(CHCDIR,NLCDIR,CHMAIL)
         WRITE(LOUT,1000)CHMAIL(1:90)
 1000 FORMAT(' Current Working Directory = ',A)
         GO TO 99
      ENDIF
      IQUEST(1)=0
      IF(CHPATH(1:1).EQ.'.')THEN
         CALL HPATH(' ')
      ELSE
         CALL HPATH(CHPATH)
      ENDIF
      IF(NLPAT.LE.0)GO TO 99
      ICDOLD=ICDIR
      ICDIR=1
*      write(*,*) 'HCDIR: NCHTOP', NCHTOP
*      write(*,*) 'HCDIR: ICDIR', ICDIR
*      write(*,*) 'HCDIR: CHPAT(1)', CHPAT(1)
*      write(*,*) 'HCDIR: CHTOP(1)', CHTOP(1)
*      write(*,*) 'HCDIR: CHTOP(2)', CHTOP(2)
*      write(*,*) 'HCDIR: CHTOP(3)', CHTOP(3)
*      write(*,*) 'HCDIR: CHPATH ', CHPATH
      DO 10 I=1,NCHTOP
*         write(*,*) 'HCDIR: 1'
*         write(*,*) 'HCDIR: CHPAT(1), CHTOP(I)', CHPAT(1), CHTOP(I)
         IF(CHPAT(1).EQ.CHTOP(I))THEN
*            write(*,*) 'HCDIR: 2'
            ICDIR=I
            IF(ICHTOP(I).GT.0)THEN
*               write(*,*) 'HCDIR: 3'
               IF (ICHTOP(I).GT.200 .AND. ICHTOP(I).LT.300) THEN
                  print*, '>>>>>> HCDIR: ICHTOP(I).GT.200'
*                  write(*,*) 'HCDIR: 4'
               ELSE
*                  write(*,*) 'HCDIR: 5'
                  IF(CHPATH(1:1).EQ.'.')THEN
                     CALL HRZCD(' ',CHOPT)
                  ELSE
*                     write(*,*) 'HCDIR: CHPATH, CHOPT', CHPATH, CHOPT
                     CALL HRZCD(CHPATH,CHOPT)
                  ENDIF
               ENDIF
               IF(IQUEST(1).NE.0)THEN
                  ICDIR=ICDOLD
                  GO TO 99
               ENDIF
               GO TO 60
            ELSEIF(ICHTOP(I).LT.0)THEN
*               write(*,*) 'HCDIR: 6'
               GO TO 60
            ENDIF
*            write(*,*) 'HCDIR: 7'
            GO TO 20
         ENDIF
  10  CONTINUE
      ICDIR=ICDOLD
      GO TO 90
  20  LR1 = LHBOOK
      IF(NLPAT.GT.1)THEN
         DO 50 IL=2,NLPAT
            CALL UCTOH(CHPAT(IL),IHDIR,4,16)
            LR1=LQ(LR1-1)
  30        IF(LR1.EQ.0)GO TO 90
            DO 40 I=1,4
               IF(IHDIR(I).NE.IQ(LR1+I))THEN
                  LR1=LQ(LR1)
                  GO TO 30
               ENDIF
  40        CONTINUE
  50     CONTINUE
      ENDIF
  60  NLCDIR= NLPAT
      DO 70 I=1,NLPAT
         CHCDIR(I)=CHPAT(I)
  70  CONTINUE
*      write(*,*) 'HCDIR NLPAT ', NLPAT
*      write(*,*) 'HCDIR CHPAT(1) ', CHPAT(1)
*      write(*,*) 'HCDIR CHPAT(2) ', CHPAT(2)

      IF(ICHTOP(ICDIR).EQ.0)THEN
         LCDIR = LR1
         LID   = 0
      ENDIF
      IDLAST= 0
      IDHOLD= 0
      LIDS  = LQ(LCDIR-2)
      LTAB  = LQ(LCDIR-3)
      LBUFM = LQ(LCDIR-4)
      LTMPM = LQ(LCDIR-5)
      IQUEST(1)=0
      GO TO 99
  90  CALL HPAFF(CHPAT,NLPAT,CHMAIL)
      IQUEST(1)=1
      WRITE(LOUT,2000)CHMAIL(1:90)
 2000 FORMAT(' HCDIR. UNKNOWN DIRECTORY ',A)
  99  RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HMACHI
#include "hbook/hcflag.inc"
#include "hbook/hcbits.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcpar0.inc"
#include "hbook/hcprin.inc"
#include "hbook/hcunit.inc"
#include "hbook/hcfitr.inc"
#include "hbook/hcvers.inc"
#include "hbook/hcnt.inc"
#include "hbook/hcset.inc"
#include "hbook/hcrecv.inc"
#include "hbook/hmachine.inc"
#include "hbook/hcminpu.inc"
#include "hbook/hcpiaf.inc"
#include "hbook/czcbuf.inc"
#include "hbook/hcopt.inc"
      PARAMETER (MBIT=32,MBITCH=8,MOUT=6,HMBIGP=1.E+30)
      CHARACTER*1 IDGTDA(42)
      CHARACTER*4 IPROJ(9)
      SAVE IDGTDA,IPROJ
      DATA IDGTDA/'0','1','2','3','4','5','6','7','8','9',
     +            'A','B','C','D','E','F','G','H','I','J',
     +            'K','L','M','N','O','P','Q','R','S','T',
     +            'U','V','W','X','Y','Z','*','.','-','+',
     +            ' ','/'/
      DATA IPROJ/'HIST','HIST','PROX','PROY','SLIX',
     +           'SLIY','BANX','BANY','FUNC'/
      HVERSN = 1.00
      NBIT   = MBIT
      NBITCH = MBITCH
      LINFIT = 5
      LOUT   = MOUT
      BIGP   = HMBIGP
      LERR   = LOUT
      NHT    = 1
      MSTEP  = 1
      NOLD   = 4
      NCHAR  = NBIT/NBITCH
      NCOLPA = 128
      NCOLMA = 100
      NLINPA = 61
      IDHOLD = 0
      IDLAST = 0
      NV     = 2
      KBINSZ = 0
      KSQUEZ = 0
      LID    = 0
      NRHIST = 0
      IERR   = 0
      IH     = 0
      NH     = 0
      IPONCE = 0
      CALL VZERO(I1,37)
      K = (NBIT+1)/2
      MAXBIT(1) = 2
      DO 10 I=2,K
         MAXBIT(I)   = MAXBIT(I-1)*2
         MAXBIT(I-1) = MAXBIT(I-1)-1
 10   CONTINUE
      MAXBIT(K) = MAXBIT(K)-1
      CALL VBLANK(IDG,42)
      CALL UCTOH(IDGTDA,IDG,1,42)
      ICSTAR = IDG(37)
      ICBLAC = IDG(34)
      ICFUNC = IDG(37)
      CALL UCTOH(IPROJ,IDENT,4,36)
      CALL UCTOH('NO  ',INO,4,4)
      L2 = 1
      CALL UCTOH('$   ',IDOL,4,4)
      IDOLAR = JBYT(IDOL,L2,NBITCH)
      IBLANC = JBYT(IDG(41),L2,NBITCH)
      NRECOV = .FALSE.
      IBSIZE = 1009
      IBIPW  = MBIT
      IBIPB  = MBITCH
      IBYPW  = NCHAR
      ISHBIT = 0
      DO 20 I = 1, 10
         IF (2**I .EQ. IBIPW) THEN
            ISHBIT = I
         ENDIF
 20   CONTINUE
      END

*-------------------------------------------------------------------------------

      FUNCTION HCX(ICX,IOPT)
#include "hbook/hcbook.inc"
#include "hbook/hcprin.inc"
      DOUBLE PRECISION CONT,ERR2,SUM,EPRIM
      HCX = 0.0
      LW = LQ(LCONT)
      IF(IOPT.EQ.1.OR.(IOPT.EQ.2.AND.LW.EQ.0)) THEN
         IF(NB.GE.32)THEN
            HCX = Q(LCONT+KCON1+ICX)
            IF(LW.NE.0)THEN
               IF(LQ(LW).NE.0)THEN
                  LN=LQ(LW)
                  IF(ICX.LE.0.OR.ICX.GT.IQ(LN-1)) THEN
                     HCX = 0.0
                     GOTO 1
                  ENDIF
                  SUM=Q(LN+ICX)
                  IF(SUM.NE.0.) HCX = HCX/SUM
               ENDIF
            ENDIF
         ELSE
            L1=ICX*NB
            NBITH=32-MOD(32,NB)
            L2=MOD(L1,NBITH)+1
            L1=LCONT+KCON1+L1/NBITH
            HCX = JBYT(IQ(L1),L2,NB)
         ENDIF
   1     IF(IOPT.EQ.1) RETURN
      ENDIF
      IF(IOPT.EQ.2) THEN
         IF(LW.EQ.0) THEN
            HCX = SQRT(ABS(HCX))
            RETURN
         ENDIF
         IF(LQ(LW).EQ.0)THEN
            HCX=SQRT(Q(LW+ICX))
            RETURN
         ELSE
            IOPTS=JBYT(IQ(LW),1,2)
            LN=LQ(LW)
            CONT=Q(LCONT+KCON1+ICX)
            ERR2=Q(LW+ICX)
            SUMP=ABS(Q(LN+ICX))
            IF(SUMP.NE.0.)THEN
               IF(JBIT(IQ(LW),3).EQ.0)THEN
                  EPRIM=SQRT(ABS(ERR2/SUMP - (CONT/SUMP)**2))
               ELSE
                  EPRIM=SQRT(ABS(ERR2/SUMP))
               ENDIF                         
               IF(EPRIM.LE.0..AND.SUMP.GE.1.)THEN
                  IF(IOPTS.EQ.2)THEN
                     EPRIM=1./SQRT(12.)
                  ELSE
                     EPRIM=SQRT(ABS(CONT))
                  ENDIF
               ENDIF
               IF(IOPTS.EQ.0)THEN
                  HCX=EPRIM/SQRT(SUMP)
               ELSEIF(IOPTS.EQ.1)THEN
                  HCX=EPRIM
               ELSE
                  HCX=EPRIM/SQRT(SUMP)
               ENDIF
            ENDIF
            RETURN
         ENDIF
      ELSE IF(IOPT.EQ.3) THEN
         LFUNC=LQ(LCONT-1)
         IC1=IQ(LFUNC+1)
         IF(ICX.GE.IC1.AND.ICX.LE.IQ(LFUNC+2))THEN
            HCX=Q(LFUNC+ICX-IC1+3)
         ENDIF
      ELSE
         print*, '+Error in option value','HCX',IOPT
      ENDIF
      END

*-------------------------------------------------------------------------------

      FUNCTION HCXY(ICX,ICY,IOPT)
#include "hbook/hcbook.inc"
#include "hbook/hcprin.inc"
      NW=32/NB
      J=(IQ(LCID+KNCY)-ICY+1)*(IQ(LCID+KNCX)+2)
      L2=ICX+J
      L1=L2/NW+LSCAT+KCON2
      IF(NW.NE.1)THEN
         L2=(NW-1-MOD(L2,NW))*NB +1
         HCXY=JBYT(IQ(L1),L2,NB)
      ELSE
         HCXY=Q(L1)
      ENDIF
      IF(IOPT.EQ.2) THEN
         LW = LQ(LCONT)
         IF(LW.NE.0) THEN
            NCX = IQ(LCID+KNCX)
            IOFF = (ICY-1)*NCX + ICX
            HCXY = SQRT(Q(LW+IOFF))
         ELSE
            HCXY = SQRT(ABS(HCXY))
         ENDIF
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HFIND(IDD,CHROUT)
#include "hbook/hcbook.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcprin.inc"
      COMMON /QUEST/ IQUEST(100)
      CHARACTER*(*) CHROUT
      IF(LFIX.NE.0)GO TO 99
      IQUEST(1)=0
      ID=IDD
      IDLAST=0
      IDPOS=LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF(IDPOS.LE.0)THEN
         LCID=0
         print*, 'Unknown histogram',CHROUT,IDD
         IQUEST(1)=1
         GO TO 99
      ENDIF
      LCID=LQ(LTAB-IDPOS)
      LCONT=LQ(LCID-1)
      LSCAT=LCONT
      NB=IQ(LCONT+KNBIT)
      LPRX=LCID+KNCX
      IF(JBYT(IQ(LCID+KBITS),2,2).NE.0)THEN
         LPRY=LCID+KNCY
      ELSE
         LPRY=0
      ENDIF
  99  RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HUOPTC(CCHOPT,CSTR,IOPT)
      CHARACTER*(*) CCHOPT,CSTR
      CHARACTER*12 CHOPT
      DIMENSION IOPT(1)
      CHOPT = CCHOPT
      CALL CLTOU(CHOPT)
      CALL UOPTC(CHOPT,CSTR,IOPT)
      RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HRZCD(CHDIR,CHOPT)
#include "hbook/hcdire.inc"
#include "hbook/czsock.inc"
      CHARACTER*(*)CHDIR,CHOPT
      IF(ICHTOP(ICDIR).GT.1000)THEN
         print*, 'CZ option not active','HRZCD',0
         RETURN
      ENDIF
      CALL RZCDIR(CHDIR,CHOPT)
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNMADR(VAR1, IADD, ISCHAR)
#include "hbook/hcntpar.inc"
#include "hbook/hcnt.inc"
#include "hbook/hcbook.inc"
      CHARACTER*(*) VAR1
      CHARACTER*32  NAME, VAR
      INTEGER       IADD
      LOGICAL       ISCHAR, ALL, LDUM
      VAR  = VAR1
      CALL CLTOU(VAR)
      LVAR = LENOCC(VAR)
      ALL  = .FALSE.
      IF (VAR(1:1).EQ.'*' .AND. LVAR.EQ.1) ALL = .TRUE.
      IOFF = 0
      NDIM = IQ(LBLOK+ZNDIM)
      DO 30 I = 1, NDIM
         CALL HNDESC(IOFF, NSUB, ITYPE, ISIZE, NBITS, LDUM)
         LL = IQ(LNAME+IOFF+ZLNAME)
         LV = IQ(LNAME+IOFF+ZNAME)
         NAME = ' '
         CALL UHTOC(IQ(LCHAR+LV), 4, NAME, LL)
         CALL CLTOU(NAME)
         IF (.NOT.ALL .AND. VAR(1:LVAR).NE.NAME(1:LL)) GOTO 20
         IF (ISCHAR .AND. ITYPE.NE.5)                  GOTO 20
         IF (.NOT.ISCHAR .AND. ITYPE.EQ.5)             GOTO 20
         IELEM = 1
         DO 10 J = 1, NSUB
            LP = IQ(LINT+IQ(LNAME+IOFF+ZARIND)+(J-1))
            IF (LP .LT. 0) THEN
               IE = -LP
            ELSE
               LL = IQ(LNAME+LP-1+ZRANGE)
               IE = IQ(LINT+LL+1)
            ENDIF
            IELEM = IELEM*IE
   10    CONTINUE
         IADDW = ISHFT(IADD, -2)
         IBYOF = IAND(IADD, IBYPW-1)
         IF (IBYOF .NE. 0) GOTO 40
         IQ(LNAME+IOFF+ZNADDR) = IADDW - LOCF(IQ(1))
         IADD = IADD + IELEM*ISIZE
   20    IOFF = IOFF + ZNADDR
   30 CONTINUE
      RETURN
   40 PRINT *, 'Variable ', NAME(1:LENOCC(NAME))
      print*, 'Address not word aligned','HBNAME'
      RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HITOC(IVAL, VALC, NCSTR, IERR)
      CHARACTER*(*) VALC
      INTEGER       IVAL, IERR
      CHARACTER*32  TT
      INTEGER       I, J, NCSTR, NCH, LENOCC
      IERR = 0
      WRITE(TT,'(I32)',ERR=20) IVAL
      J = 0
      DO 10 I = 1, LENOCC(TT)
         IF (TT(I:I) .EQ. ' ') GOTO 10
         J = J + 1
         TT(J:J) = TT(I:I)
   10 CONTINUE
      NCSTR = J
      TT = TT(1:NCSTR)
      NCH = LEN(VALC)
      IF (NCH .LT. NCSTR) IERR = -1
      VALC(1:NCH) = TT
      GOTO 999
   20 IERR = 1
  999 END

*-------------------------------------------------------------------------------

      SUBROUTINE HPATH(CHPATH)
#include "hbook/hcunit.inc"
#include "hbook/hcdire.inc"
      CHARACTER*(*) CHPATH
      CHARACTER*1 CH1,BSLASH
      CHARACTER*2 CH2
      BSLASH='\\'
      NCHP=LEN(CHPATH)
      NLPAT=0
  10  IF(CHPATH(NCHP:NCHP).EQ.' ')THEN
         NCHP=NCHP-1
         IF(NCHP.GT.0)GO TO 10
         NLPAT=NLCDIR
         DO 20 I=1,NLCDIR
            CHPAT(I)=CHCDIR(I)
  20     CONTINUE
         GO TO 99
      ENDIF
      IS1=1
  30  IF(CHPATH(IS1:IS1).EQ.' ')THEN
         IS1=IS1+1
         GO TO 30
      ENDIF
      CH1=CHPATH(IS1:IS1)
      IF(IS1.LT.NCHP)CH2=CHPATH(IS1:IS1+1)
      IF(CH1.EQ.'/')THEN
         IF(IS1.GE.NCHP)GO TO 90
         IF(CHPATH(IS1+1:IS1+1).EQ.'/')THEN
            IS=IS1+2
            IF(IS.GT.NCHP)GO TO 99
  40        IF(CHPATH(IS:IS).EQ.'/')THEN
               IF(IS.EQ.IS1+2)GO TO 90
               NLPAT=1
               CHPAT(1)=CHPATH(IS1+2:IS-1)
               IS1=IS+1
               IS=IS1
               GO TO 50
            ELSE
               IS=IS+1
               IF(IS.LT.NCHP)GO TO 40
               NLPAT=1
               CHPAT(1)=CHPATH(IS1+2:IS)
               GO TO 99
            ENDIF
         ENDIF
         IF(CHPATH(IS1+1:IS1+1).EQ.BSLASH)GO TO 90
         NLPAT=1
         CHPAT(1)=CHCDIR(1)
         IS=IS1+1
         IS1=IS
  50     IF(IS.EQ.NCHP)THEN
            IF(CHPATH(IS1:IS).NE.'..'.AND.
     +         CHPATH(IS1:IS).NE.BSLASH) THEN
               NLPAT=NLPAT+1
               IF(NLPAT.GT.NLPATM)GO TO 90
               CHPAT(NLPAT)=CHPATH(IS1:IS)
            ELSE
               NLPAT = NLPAT -1
            ENDIF
            GO TO 99
         ELSE
            IF(CHPATH(IS:IS).EQ.'/')THEN
               IF(NLPAT.GT.NLPATM)GO TO 90
               IF(CHPATH(IS1:IS-1).NE.'..'.AND.
     +            CHPATH(IS1:IS-1).NE.BSLASH) THEN
                  NLPAT=NLPAT+1
                  CHPAT(NLPAT)=CHPATH(IS1:IS-1)
               ELSE
                  NLPAT = NLPAT - 1
               ENDIF
               IS1=IS+1
            ENDIF
            IS=IS+1
            GO TO 50
         ENDIF
      ENDIF
      DO 70 I=1,NLCDIR
         CHPAT(I)=CHCDIR(I)
  70  CONTINUE
      NLPAT=NLCDIR
  75  IF(CH1.EQ.BSLASH)THEN
         NLPAT=NLPAT-1
         IF(NLPAT.EQ.0)NLPAT=1
         IF(IS1.EQ.NCHP)GO TO 99
         IS1=IS1+1
         CH1=CHPATH(IS1:IS1)
         GO TO 75
      ENDIF
      IS=IS1
  76  IF(CH2.EQ.'..')THEN
         NLPAT=NLPAT-1
         IF(NLPAT.EQ.0)NLPAT=1
         IF(IS1+1.EQ.NCHP)GO TO 99
         IF(CHPATH(IS1+2:IS1+2).NE.'/') GOTO 90
         IS =IS1
         IS1=IS1+3
         CH2=CHPATH(IS1:IS1+1)
         GO TO 76
      ENDIF
  80  IF(IS.EQ.NCHP)THEN
         NLPAT=NLPAT+1
         IF(NLPAT.GT.NLPATM)GO TO 90
         CHPAT(NLPAT)=CHPATH(IS1:IS)
         GO TO 99
      ELSE
         IF(CHPATH(IS:IS).EQ.'/')THEN
            IF(IS.GT.IS1)THEN
               NLPAT=NLPAT+1
               IF(NLPAT.GT.NLPATM)GO TO 90
               CHPAT(NLPAT)=CHPATH(IS1:IS-1)
            ENDIF
            IS1=IS+1
         ENDIF
         IS=IS+1
         GO TO 80
      ENDIF
  90  IS1=LEN(CHPATH)
      IF(IS1.GT.90)IS1=90
      WRITE(LOUT,1000)CHPATH(1:IS1)
 1000 FORMAT(' HPATH.  ERROR IN PATHNAME,',A)
      NLPAT=0
  99  RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNDESC(IOFF, NSUB, ITYPE, ISIZE, NBITS, INDVAR)
#include "hbook/hcntpar.inc"
#include "hbook/hcnt.inc"
#include "hbook/hcbook.inc"
      LOGICAL INDVAR
      NSUB  = JBYT(IQ(LNAME+IOFF+ZDESC), 18, 3)
      ITYPE = JBYT(IQ(LNAME+IOFF+ZDESC), 14, 4)
      ISIZE = JBYT(IQ(LNAME+IOFF+ZDESC), 8,  6)
      NBITS = JBYT(IQ(LNAME+IOFF+ZDESC), 1,  7)
      INDVAR = .FALSE.
      IF (JBIT(IQ(LNAME+IOFF+ZDESC),28) .EQ. 1) INDVAR = .TRUE.
      IF (ITYPE .EQ. 5) NBITS = IBIPB*ISIZE
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HPARNT(IDN, CHROUT)
#include "hbook/hcntpar.inc"
#include "hbook/hcbook.inc"
      CHARACTER*(*) CHROUT
      LCID = 0
      NIDN  = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),IDN)
      IF (NIDN .LE. 0) THEN
         CALL HRIN(IDN,9999,0)
         NIDN = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),IDN)
         IF (NIDN .LE. 0) THEN
            print*,'Unknown N-tuple',CHROUT,IDN
            IDN = 0
            RETURN
         ENDIF
      ENDIF
      LCID = LQ(LTAB-NIDN)
      I4 = JBIT(IQ(LCID+KBITS),4)
      IF (I4 .EQ. 0) THEN
         print*,'Not a N-tuple',CHROUT,IDN
         IDN = 0
         RETURN
      ENDIF
      IF (IQ(LCID-2) .NE. ZLINK) THEN
         print*,'Old N-tuple, this routine works only for new '//
     +             'N-tuples',CHROUT,IDN
         IDN = 0
         RETURN
      ENDIF
      IF (IQ(LCID+ZNPRIM) .GT. 0) THEN
         CALL HNBFWR(IDN)
         CALL HNHDWR(IDN)
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNTMP(IDD)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      NDIM = IQ(LCID+ZNDIM)
      NW   = 1 + ZNTMP*NDIM
      IF (LQ(LCDIR-5) .EQ. 0) THEN
         NW1  = 1 + ZNTMP1*NDIM
         NTOT = NW + NW1 + NDIM + 2*33
         CALL HSPACE(NTOT,'HNTMP',IDD)
         IF (IERR.NE.0) GOTO 70
         IDLAST = IDD
         CALL MZBOOK(IHDIV,LTMPM,LCDIR,-5,'HTMP',2,1,NW,2,1)
         LTMP = LTMPM
         IQ(LTMP-5) = IDD
         CALL MZBOOK(IHDIV,LTMP1,LTMP,-1,'HTMP1',NDIM,0,NW1,2,-1)
      ELSEIF (IQ(LTMP-5) .NE. IDD) THEN
         LTMP = LQ(LCDIR-5)
   20    IF (IQ(LTMP-5) .EQ. IDD) GOTO 40
         IF (LQ(LTMP) .NE. 0) THEN
            LTMP = LQ(LTMP)
            GOTO 20
         ENDIF
         NW1  = 1 + ZNTMP1*NDIM
         NTOT = NW + NW1 + NDIM + 2*33
         CALL HSPACE(NTOT,'HNTMP',IDD)
         IF (IERR.NE.0) GOTO 70
         IDLAST = IDD
         CALL MZBOOK(IHDIV,LTMP,LTMP,0,'HTMP',2,1,NW,2,1)
         IQ(LTMP-5) = IDD
         CALL MZBOOK(IHDIV,LTMP1,LTMP,-1,'HTMP1',NDIM,0,NW1,2,-1)
      ENDIF
   40 LTMP1 = LQ(LTMP-1)
      LQ(LTMP-2) = LCID
      NWP   = IQ(LTMP-1)
      IF (NWP .NE. NW) THEN
         ND = NW - NWP
         CALL MZPUSH(IHDIV, LTMP, 0, ND, 'I')
         NWP = IQ(LTMP1-1)
         ND  = 1+ZNTMP1*NDIM - NWP
         NLP = IQ(LTMP1-3)
         NL  = NDIM - NLP
         CALL MZPUSH(IHDIV, LTMP1, NL, ND, 'I')
      ENDIF
   70 RETURN
      END
 
*-------------------------------------------------------------------------------
      SUBROUTINE HNBUFR(IDD)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*128 CHWOLD, CHDIR, CWDRZ
      INTEGER       KEYS(2)
      LOGICAL       MEMORY
      IERR   = 0
      ICYCLE = 9999
      NDIM = IQ(LCID+ZNDIM)
      NWP  = IABS(IQ(LCID+ZNPRIM))
      IF (LQ(LCDIR-4) .EQ. 0) THEN
         NTOT = NDIM+2+33
         CALL HSPACE(NTOT,'HNBUFR',IDD)
         IF (IERR.NE.0) GOTO 50
         CALL MZBOOK(IHDIV,LBUFM,LCDIR,-4,'HBUF',NDIM,NDIM,2,2,0)
         LBUF = LBUFM
         IQ(LBUF-5) = IDD
      ELSEIF (IQ(LBUF-5) .NE. IDD) THEN
         LBUF = LQ(LCDIR-4)
   10    IF (IQ(LBUF-5) .EQ. IDD) GOTO 20
         IF (LQ(LBUF) .NE. 0) THEN
            LBUF = LQ(LBUF)
            GOTO 10
         ENDIF
         NTOT = NDIM+2+33
         CALL HSPACE(NTOT,'HNBUFR',IDD)
         IF (IERR.NE.0) GOTO 50
         CALL MZBOOK(IHDIV,LBUF,LBUF,0,'HBUF',NDIM,NDIM,2,2,0)
         IQ(LBUF-5) = IDD
      ENDIF
   20 MEMORY = IQ(LCID+ZNPRIM) .LE. 0
      IF (MEMORY) THEN
         NCHRZ = IQ(LCID+ZNCHRZ)
         CALL RZCDIR(CWDRZ,'R')
         CALL HCDIR(CHWOLD,'R')
         CHDIR = ' '
         CALL UHTOC(IQ(LCID+ZNCHRZ+1),4,CHDIR,NCHRZ)
         IF (CHDIR.NE.CWDRZ) THEN
            CALL HCDIR(CHDIR,' ')
         ENDIF
         KEYS(1) = IQ(LCID+ZID)
      ENDIF
      LBLOK = LQ(LCID-1)
      LCHAR = LQ(LCID-2)
      LINT  = LQ(LCID-3)
      LREAL = LQ(LCID-4)
   30 LNAME  = LQ(LBLOK-1)
      IOFF = 0
      NDIM = IQ(LBLOK+ZNDIM)
      DO 40 I = 1, NDIM
         LCIND = IQ(LNAME+IOFF+ZLCONT)
         IADD  = IQ(LNAME+IOFF+ZNADDR)
         LB    = LQ(LBUF-LCIND)
         IF (IADD .EQ. 0) THEN
            IF (LB .NE. 0) THEN
               IF (JBIT(IQ(LB),1) .EQ. 0) THEN
                  CALL MZDROP(IHDIV,LB,' ')
                  LQ(LBUF-LCIND) = 0
               ENDIF
            ENDIF
         ELSEIF (MEMORY .AND. LB.EQ.0) THEN
            KEYS(2) = IQ(LNAME+IOFF+ZNRZB)*10000 +
     +                IQ(LNAME+IOFF+ZLCONT)
            CALL HRZIN(IHDIV,0,0,KEYS,ICYCLE,'C')
            IF (IQUEST(1) .NE. 0) THEN
               print*,'Error reading contents bank', 'HNBUFR', IDD
               IERR = 1
               GOTO 50
            ENDIF
            NWORDS = IQUEST(12)
            CALL HSPACE(NWORDS+1000,'HNBUFR',IDD)
            IF (IERR .NE. 0) GOTO 50
            CALL HRZIN(IHDIV,LBUF,-LCIND,KEYS,ICYCLE,' ')
         ELSEIF (LB .EQ. 0) THEN
            NTOT = NWP+33
            CALL HSPACE(NTOT,'HNBUFR',IDD)
            IF (IERR.NE.0) GOTO 50
            CALL MZBOOK(IHDIV,L,LBUF,-LCIND,'HCON',0,0,NWP,1,-1)
         ENDIF
         IOFF = IOFF + ZNADDR
   40 CONTINUE
      LBLOK = LQ(LBLOK)
      IF (LBLOK .NE. 0) GOTO 30
      IF (MEMORY) THEN
         IF (CHDIR.NE.CWDRZ) THEN
            CALL HCDIR(CHWOLD,' ')
            IF (CHWOLD .NE. CWDRZ) THEN
               CALL RZCDIR(CWDRZ,' ')
            ENDIF
         ENDIF
      ENDIF
      CALL HNTMP(IDD)
   50 RETURN
      END
 
*-------------------------------------------------------------------------------

      SUBROUTINE HNTRD(INDX, IOFF, IBANK, IERROR)
#include "hbook/hcntpar.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcrecv.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*128 CHWOLD, CHDIR, CWDRZ
      INTEGER       KEYS(2)
      IF (IQ(LNAME+IOFF+ZIBANK) .EQ. IBANK) THEN
         LR2 = LQ(LNAME-INDX)
         RETURN
      ENDIF
      IERROR = 0
      IDD    = IQ(LBUF-5)
      LCIND  = IQ(LNAME+IOFF+ZLCONT)
      IF (IQ(LCID+ZNPRIM) .LT. 0) THEN
         LR2 = LQ(LBUF-LCIND)
         DO 10 I = 2, IBANK
            IF (LQ(LR2) .NE. 0) LR2 = LQ(LR2)
  10     CONTINUE
         IF (LR2 .EQ. 0) THEN
            print*,'Bank does not exist', 'HGNT', IDD
            GOTO 90
         ENDIF
      ELSE
         IF (.NOT.NRECOV .AND. IBANK.GT.IQ(LNAME+IOFF+ZNRZB)) THEN
            print*,'Bank does not exist', 'HGNT', IDD
            GOTO 90
         ENDIF
         NCHRZ = IQ(LCID+ZNCHRZ)
         IF(NCHRZ.NE.0)THEN
            CALL RZCDIR(CWDRZ,'R')
            CALL HCDIR(CHWOLD,'R')
            CHDIR = ' '
            CALL UHTOC(IQ(LCID+ZNCHRZ+1),4,CHDIR,NCHRZ)
            IF (CHDIR.NE.CWDRZ) THEN
               CALL HCDIR(CHDIR,' ')
            ENDIF
         ENDIF
         KEYS(1) = IQ(LCID+ZID)
         KEYS(2) = IBANK*10000 + IQ(LNAME+IOFF+ZLCONT)
         IF (NRECOV) THEN
            CALL RZINK(KEYS,99999,'R')
            IF (IQUEST(1) .NE. 0) GOTO 90
            IQ(LNAME+IOFF+ZNRZB) = IBANK
            IF (JBIT(IQ(LNAME+IOFF+ZDESC),28) .EQ. 1) THEN
               CALL HRZIN(IHDIV,LBUF,-LCIND,KEYS,99999,'R')
               IF (IQUEST(1) .NE. 0) GOTO 90
            ENDIF
         ELSE
            CALL HRZIN(IHDIV,LBUF,-LCIND,KEYS,99999,'R')
            IF (IQUEST(1) .NE. 0) THEN
               KEYS(1)   = 0
               IQUEST(1) = 0
               CALL HRZIN(IHDIV,LBUF,-LCIND,KEYS,99999,'R')
            ENDIF
            IF (IQUEST(1) .NE. 0) GOTO 90
            IQ(LQ(LBUF-LCIND)) = 0
         ENDIF
         IF (NCHRZ.NE.0.AND.CHDIR .NE. CWDRZ) THEN
            CALL HCDIR(CHWOLD,' ')
            IF (CHWOLD .NE. CWDRZ) THEN
               CALL RZCDIR(CWDRZ,' ')
            ENDIF
         ENDIF
         LR2 = LQ(LBUF-LCIND)
      ENDIF
      IQ(LNAME+IOFF+ZIBANK) = IBANK
      LQ(LNAME-INDX) = LR2
      RETURN
90    IERROR = 1
99    END

*-------------------------------------------------------------------------------

      SUBROUTINE HPAFF(CH,NL,CHPATH)
#include "hbook/hcmail.inc"
      CHARACTER*(*) CHPATH,CH(*)
      CHARACTER*16 CHL
      MAXLEN=LEN(CHPATH)
      IF(MAXLEN.GT.110)MAXLEN=110
      CHPATH='//'//CH(1)
      LENG=LENOCC(CHPATH)
      IF(LENG.EQ.2) THEN
         CHPATH='//HOME'
         LENG=6
      ENDIF
      IF(NL.EQ.1) GOTO 99
      DO 20 I=2,NL
         CHL=CH(I)
         NMAX=LENOCC(CHL)
         IF(NMAX.EQ.0) GOTO 99
         IF(LENG+NMAX.GT.MAXLEN)NMAX=MAXLEN-LENG
         CHMAIL=CHPATH(1:LENG)//'/'//CHL(1:NMAX)
         CHPATH=CHMAIL
         LENG=LENG+NMAX+1
         IF(LENG.EQ.MAXLEN)GO TO 99
   20 CONTINUE
   99 RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HRZFRA(IH,IOH,NW)
      DIMENSION IH(1), IOH(1)
      DO 20 IW=1,NW
         IB1=JBYT(IH(IW), 1,8)
         IB2=JBYT(IH(IW), 9,8)
         IB3=JBYT(IH(IW),17,8)
         IB4=JBYT(IH(IW),25,8)
         IOH(IW)=IB4
         CALL SBYT(IB3,IOH(IW), 9,8)
         CALL SBYT(IB2,IOH(IW),17,8)
         CALL SBYT(IB1,IOH(IW),25,8)
   20 CONTINUE
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HSPACE (N,CHROUT,IDD)
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      COMMON/QUEST/IQUEST(100)
      CHARACTER*(*) CHROUT
      IDLAST=0
      IERR=0
      CALL MZNEED(IHDIV,N,' ')
      IF(IQUEST(11).LT.0)THEN
         CALL MZNEED(IHDIV,N,'G')
      ENDIF
      IQUEST(1)=0
      IF(IQUEST(11).LT.0)THEN
         print*,'Not enough space in memory',CHROUT,IDD
         IERR  =1
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNTMPD(IDD)
#include "hbook/hcbook.inc"
      IF (LQ(LCDIR-5) .EQ. 0) RETURN
      IF (IDD .EQ. 0) THEN
         CALL MZDROP(IHDIV,LQ(LCDIR-5),'L')
         LQ(LCDIR-5) = 0
         LTMPM       = 0
         LTMP        = 0
      ELSE
         LTMP = LQ(LCDIR-5)
   20    IF (IQ(LTMP-5) .EQ. IDD) THEN
            CALL MZDROP(IHDIV,LTMP,' ')
            LTMP = LQ(LCDIR-5)
            GOTO 40
         ENDIF
         LTMP = LQ(LTMP)
         IF (LTMP .NE. 0) GOTO 20
         RETURN
      ENDIF
 40   END

*-------------------------------------------------------------------------------

      SUBROUTINE HNBUFD(IDD)
#include "hbook/hcbook.inc"
      CALL HNTMPD(IDD)
      IF (LQ(LCDIR-4) .EQ. 0) RETURN
      IF (IDD .EQ. 0) THEN
         CALL MZDROP(IHDIV,LQ(LCDIR-4),'L')
         LQ(LCDIR-4) = 0
         LBUFM       = 0
         LBUF        = 0
      ELSE
         LBUF = LQ(LCDIR-4)
   20    IF (IQ(LBUF-5) .EQ. IDD) THEN
            CALL MZDROP(IHDIV,LBUF,' ')
            LBUF = LQ(LCDIR-4)
            GOTO 40
         ENDIF
         LBUF = LQ(LBUF)
         IF (LBUF .NE. 0) GOTO 20
         RETURN
      ENDIF
 40   END
 
*-------------------------------------------------------------------------------

      SUBROUTINE HNTVAR(ID1,IVAR,CHTAG,BLOCK,NSUB,ITYPE,ISIZE,IELEM)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
#include "hbook/hcbits.inc"
      CHARACTER*(*)  CHTAG, BLOCK
      CHARACTER*32   NAME
      LOGICAL        NEWTUP, LDUM
      ID    = ID1
      IDPOS = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF (IDPOS .LE. 0) THEN
         print*,'Unknown N-tuple','HNTVAR',ID1
         RETURN
      ENDIF
      LCID  = LQ(LTAB-IDPOS)
      I4 = JBIT(IQ(LCID+KBITS),4)
      IF (I4 .EQ. 0) RETURN
      NEWTUP = .TRUE.
      IF (IQ(LCID-2) .NE. ZLINK) NEWTUP = .FALSE.
      CHTAG = ' '
      NAME  = ' '
      BLOCK = ' '
      NSUB  = 0
      ITYPE = 0
      ISIZE = 0
      IELEM = 0
      ICNT  = 0
      IF (NEWTUP) THEN
         IF (IVAR .GT. IQ(LCID+ZNDIM)) RETURN
         LBLOK = LQ(LCID-1)
         LCHAR = LQ(LCID-2)
         LINT  = LQ(LCID-3)
         LREAL = LQ(LCID-4)
  5      LNAME = LQ(LBLOK-1)
         IOFF = 0
         NDIM = IQ(LBLOK+ZNDIM)
         DO 10 I = 1, NDIM
            ICNT = ICNT + 1
            IF (ICNT .EQ. IVAR) THEN
               CALL HNDESC(IOFF, NSUB, ITYPE, ISIZE, NBITS, LDUM)
               LL = IQ(LNAME+IOFF+ZLNAME)
               LV = IQ(LNAME+IOFF+ZNAME)
               CALL UHTOC(IQ(LCHAR+LV), 4, NAME, LL)
               CALL UHTOC(IQ(LBLOK+ZIBLOK), 4, BLOCK, 8)
               IELEM = 1
               DO 25 J = 1, NSUB
                  LP = IQ(LINT+IQ(LNAME+IOFF+ZARIND)+(J-1))
                  IF (LP .LT. 0) THEN
                     IE = -LP
                  ELSE
                     LL = IQ(LNAME+LP-1+ZRANGE)
                     IE = IQ(LINT+LL+1)
                  ENDIF
                  IELEM = IELEM*IE
   25          CONTINUE
               CHTAG = NAME
               RETURN
            ENDIF
            IOFF = IOFF + ZNADDR
  10     CONTINUE
         LBLOK = LQ(LBLOK)
         IF (LBLOK .NE. 0) GOTO 5
      ELSE
         IF (IVAR .GT. IQ(LCID+2)) RETURN
         ITAG1 = IQ(LCID+10)
         CALL UHTOC(IQ(LCID+ITAG1+2*(IVAR-1)), 4, NAME, 8)
         CHTAG = NAME
         ITYPE = 1
         ISIZE = 4
         IELEM = 1
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNMSET(IDD, ITEM, IVAL)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      ID    = IDD
      IDPOS = LOCATI(IQ(LTAB+1),IQ(LCDIR+KNRH),ID)
      IF (IDPOS .LE. 0) THEN
         print*,'Unknown N-tuple','HNMSET',IDD
         RETURN
      ENDIF
      LCID=LQ(LTAB-IDPOS)
      LBLOK = LQ(LCID-1)
      LCHAR = LQ(LCID-2)
      LINT  = LQ(LCID-3)
      LREAL = LQ(LCID-4)
10    LNAME = LQ(LBLOK-1)
      IOFF = 0
      NDIM = IQ(LBLOK+ZNDIM)
      DO 20 I = 1, NDIM
         IQ(LNAME+IOFF+ITEM) = IVAL
         IOFF = IOFF + ZNADDR
20    CONTINUE
      LBLOK = LQ(LBLOK)
      IF (LBLOK .NE. 0) GOTO 10
      END

*-------------------------------------------------------------------------------

      INTEGER FUNCTION HNBPTR(BLKNA1)
#include "hbook/hcntpar.inc"
#include "hbook/hcbook.inc"
      CHARACTER*(*) BLKNA1
      CHARACTER*8   BLKNAM
      INTEGER       IBLKN(2)
      BLKNAM = BLKNA1
      CALL CLTOU(BLKNAM)
      HNBPTR = 0
      CALL UCTOH(BLKNAM, IBLKN, 4, 8)
      LL = LQ(LCID-1)
10    IF (IBLKN(1).EQ.IQ(LL+ZIBLOK) .AND.
     +    IBLKN(2).EQ.IQ(LL+ZIBLOK+1)) THEN
         HNBPTR = LL
         RETURN
      ENDIF
      LL = LQ(LL)
      IF (LL .NE. 0) GOTO 10
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HNBUFF(IDD, FATAL)
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      LOGICAL  FATAL
      IF (LQ(LCDIR-4) .EQ. 0) THEN
         IF (FATAL) THEN
            print*,'Buffer structure not initialized.','HNBUFF',IDD
         ENDIF
         IERR = 1
         RETURN
      ELSEIF (IQ(LBUF-5) .NE. IDD) THEN
         LBUF = LQ(LCDIR-4)
   20    IF (IQ(LBUF-5) .EQ. IDD) GOTO 40
         IF (LQ(LBUF) .NE. 0) THEN
            LBUF = LQ(LBUF)
            GOTO 20
         ENDIF
         IF (FATAL) THEN
            print*,'Buffer structure not found.','HNBUFF',IDD
         ENDIF
         IERR = 1
         RETURN
      ENDIF
   40 CONTINUE
      print*, '>>>>>> CALL HNTMPF(IDD, FATAL)'
******CALL HNTMPF(IDD, FATAL)
      END
 
*-------------------------------------------------------------------------------

      SUBROUTINE HNBFWR(IDD)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      CHARACTER*128 CHWOLD, CHDIR, CWDRZ
      INTEGER       KEYS(2)
      IERR = 0
      CALL HNBUFF(IDD, .FALSE.)
      IF (IERR .NE. 0) GOTO 99
      NCHRZ = IQ(LCID+ZNCHRZ)
      IF(NCHRZ.NE.0)THEN
         CALL RZCDIR(CWDRZ,'R')
         CALL HCDIR(CHWOLD,'R')
         CHDIR = ' '
         CALL UHTOC(IQ(LCID+ZNCHRZ+1),4,CHDIR,NCHRZ)
         IF (CHDIR .NE. CWDRZ) THEN
            CALL HCDIR(CHDIR,' ')
         ENDIF
      ENDIF
      KEYS(1) = IDD
      KEYS(2) = 0
      LBLOK = LQ(LCID-1)
      LCHAR = LQ(LCID-2)
      LINT  = LQ(LCID-3)
      LREAL = LQ(LCID-4)
10    LNAME  = LQ(LBLOK-1)
      IOFF = 0
      NDIM = IQ(LBLOK+ZNDIM)
      DO 20 I = 1, NDIM
         LCIND = IQ(LNAME+IOFF+ZLCONT)
         LB = LQ(LBUF-LCIND)
         IF (LB .EQ. 0) GOTO 15
         IF (JBIT(IQ(LB),1) .EQ. 0) GOTO 15
         CALL SBIT0(IQ(LB),1)
         KEYS(2) = IQ(LNAME+IOFF+ZNRZB)*10000 + IQ(LNAME+IOFF+ZLCONT)
         IF (IQ(LCID+ZNPRIM) .GT. 0) THEN
            print*, '>>>>>> HRZOUT'
******      CALL HRZOUT(IHDIV,LB,KEYS,ICYCLE,'A')
         ELSE
            print*, '>>>>>> HRZOUT'
******      CALL HRZOUT(IHDIV,LB,KEYS,ICYCLE,'LA')
         ENDIF
15       IOFF = IOFF + ZNADDR
20    CONTINUE
      LBLOK = LQ(LBLOK)
      IF (LBLOK .NE. 0) GOTO 10
      IF (KEYS(2) .NE. 0) CALL SBIT1(IQ(LQ(LCID-1)),1)
      IF (NCHRZ.NE.0.AND.CHDIR .NE. CWDRZ) THEN
         CALL HCDIR(CHWOLD,' ')
         IF (CHWOLD .NE. CWDRZ) THEN
            CALL RZCDIR(CWDRZ,' ')
         ENDIF
      ENDIF
99    RETURN
      END
*-------------------------------------------------------------------------------

      SUBROUTINE HNHDWR(IDD)
#include "hbook/hcntpar.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcbook.inc"
      CHARACTER*128 CHWOLD, CHDIR, CWDRZ
      INTEGER       KEYS(2)
      IERR = 0
      NCHRZ = IQ(LCID+ZNCHRZ)
      CALL RZCDIR(CWDRZ,'R')
      CALL HCDIR(CHWOLD,'R')
      CHDIR = ' '
      CALL UHTOC(IQ(LCID+ZNCHRZ+1),4,CHDIR,NCHRZ)
      IF (CHDIR.NE.CWDRZ) THEN
         CALL HCDIR(CHDIR,' ')
      ENDIF
      LC = LQ(LCID-1)
      IF (JBIT(IQ(LC),1) .NE. 0) THEN
         CALL SBIT0(IQ(LC),1)
         CALL SBIT0(IQ(LC),2)
         KEYS(1) = IDD
         KEYS(2) = 0
         print*, '>>>>>> HRZOUT'
******   CALL HRZOUT(IHDIV,LCID,KEYS,ICYCLE,' ')
         CALL RZSAVE
      ENDIF
      IF (CHDIR.NE.CWDRZ) THEN
         CALL HCDIR(CHWOLD,' ')
         IF (CHWOLD .NE. CWDRZ) THEN
            CALL RZCDIR(CWDRZ,' ')
         ENDIF
      ENDIF
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HLDIR(CHPATH,CHOPT)
#include "hbook/hcbook.inc"
#include "hbook/hcunit.inc"
#include "hbook/hcdire.inc"
#include "hbook/hcmail.inc"
#include "hbook/hcpiaf.inc"
      DIMENSION IPAWC(99)
      EQUIVALENCE (NWPAW,IPAWC(1))
      COMMON/QUEST/IQUEST(100)
      CHARACTER*(*) CHPATH,CHOPT
      CHARACTER*128 CHWOLD
      DIMENSION LCUR(15),IOPT(5)
      EQUIVALENCE (IOPTT,IOPT(1)),(IOPTR,IOPT(2)),(IOPTN,IOPT(3))
      EQUIVALENCE (IOPTI,IOPT(4)),(IOPTS,IOPT(5))
      EXTERNAL HLDIRT
      IF(CHPATH.EQ.'//')THEN
         DO 10 I=1,NCHTOP
            CHMAIL=CHTOP(I)//HFNAME(I)
            NCH=LENOCC(CHMAIL)
            WRITE(LOUT,1000)CHMAIL(1:NCH)
  10     CONTINUE
 1000    FORMAT(' //',A)
         GO TO 99
      ENDIF
      IF(LHBOOK.EQ.0)GO TO 99
      CALL HUOPTC (CHOPT,'TRNIS',IOPT)
      CALL HPAFF(CHCDIR,NLCDIR,CHWOLD)
      LR2=LCDIR
      CALL HCDIR(CHPATH,' ')
      IF (IQUEST(1) .NE. 0) GOTO 40
      IF(ICHTOP(ICDIR).NE.0)THEN
         IF(IOPTR.NE.0)THEN
            print*,'CALL HRZLD(...)'
******      CALL HRZLD(' ',CHOPT)
         ELSE
            IQUEST(88)=IOPTS
            IQUEST(89)=IOPTN
            IF(IOPTT.EQ.0)THEN
               CALL HLDIRT(CHPATH)
            ELSE
               CALL RZSCAN(' ',HLDIRT)
            ENDIF
         ENDIF
         GO TO 40
      ENDIF
      NLPAT0=NLPAT
      LCUR(NLPAT)=LCDIR
      IF(IOPTS.NE.0)THEN
         print*,'>>>>>> CALL ZSORTI(IHDIV,LIDS,-5)'
******   CALL ZSORTI(IHDIV,LIDS,-5)
      ENDIF
      print*,'>>>>>> CALL HLDIR1(IOPTI,IOPTN,1)'
******   CALL HLDIR1(IOPTI,IOPTN,1)
  20  NLPAT=NLPAT+1
      LCDIR=LQ(LCDIR-1)
  30  LCUR(NLPAT)=LCDIR
      IF(LCDIR.EQ.0)THEN
         NLPAT=NLPAT-1
         LCDIR=LCUR(NLPAT)
         IF(NLPAT.LE.NLPAT0)GO TO 40
         LCDIR=LQ(LCDIR)
         GO TO 30
      ENDIF
      CALL UHTOC(IQ(LCDIR+1),4,CHCDIR(NLPAT),16)
      LIDS=LQ(LCDIR-2)
      LTAB=LQ(LCDIR-3)
      IF(IOPTS.NE.0)THEN
         print*,'>>>>>> CALL ZSORTI(IHDIV,LIDS,-5)'
******   CALL ZSORTI(IHDIV,LIDS,-5)
      ENDIF
      print*,'>>>>>> CALL HLDIR1(IOPTI,IOPTN,IOPTT)'
******   CALL HLDIR1(IOPTI,IOPTN,IOPTT)
      GO TO 20
  40  CALL HCDIR(CHWOLD,' ')
      LCDIR = LR2
      LIDS  = LQ(LCDIR-2)
      LTAB  = LQ(LCDIR-3)
      LBUFM = LQ(LCDIR-4)
      LTMPM = LQ(LCDIR-5)
  99  RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HLDIRT(CHDIR)
#include "hbook/hcbook.inc"
#include "hbook/hcflag.inc"
#include "hbook/hcunit.inc"
#include "hbook/hcntpar.inc"
      CHARACTER*(*) CHDIR
      COMMON/QUEST/IQUEST(100)
      CHARACTER*1 HTYPE
      INTEGER     KEYS(2)
      NCH=LENOCC(CHDIR)
      WRITE(LOUT,1000)CHDIR(1:NCH)
      IOPTS=IQUEST(88)
      IOPTN=IQUEST(89)
      IF(IOPTS.NE.0)THEN
         print*,'>>>>>> CALL HRSORT(...)'
******   CALL HRSORT('S')
      ENDIF
      KEYNUM  = 1
      KEYS(1) = KEYNUM
      KEYS(2) = 0
      CALL HRZIN(IHWORK,0,0,KEYS,9999,'SC')
      IDN=IQUEST(21)
      IQ42=IQUEST(22)
  10  IF (IDN .EQ. 0) GOTO 90
      KEYS(1) = KEYNUM
      CALL HRZIN(IHWORK,0,0,KEYS,9999,'SNC')
      IF(IQUEST(1).NE.0)GO TO 90
      IDN =IQUEST(21)
      IQ40=IQUEST(40)
      IQ41=IQUEST(41)
      IQ42=IQUEST(42)
      IF(IQ40.EQ.0) IQ41=0
      NWORDS=IQUEST(12)
      IOPTA=JBIT(IQUEST(14),4)
      IF(IOPTA.NE.0)GO TO 40
      CALL HSPACE(NWORDS+1000,'HLDIR ',IDN)
      IF(IERR.NE.0)                    GO TO 90
      CALL HRZIN(IHWORK,LHWORK,1,KEYS,9999,'SND')
      IF(IQUEST(1).NE.0)THEN
         print*, 'Bad sequence for RZ','HLDIR',IDN
         GO TO 90
      ENDIF
      IF(IQ(LHWORK-2).EQ.0)THEN
         WRITE(LOUT,2100)IDN
      ELSEIF(JBIT(IQ(LHWORK+KBITS),1).NE.0)THEN
         IF(IOPTN.EQ.0)THEN
            HTYPE='1'
            NWTITL=IQ(LHWORK-1)-KTIT1+1
            WRITE(LOUT,2000)IDN,HTYPE,(IQ(LHWORK+KTIT1+I-1),I=1,NWTITL)
         ENDIF
      ELSEIF(JBYT(IQ(LHWORK+KBITS),2,2).NE.0)THEN
         IF(IOPTN.EQ.0)THEN
            HTYPE='2'
            NWTITL=IQ(LHWORK-1)-KTIT2+1
            WRITE(LOUT,2000)IDN,HTYPE,(IQ(LHWORK+KTIT2+I-1),I=1,NWTITL)
         ENDIF
      ELSEIF(JBIT(IQ(LHWORK+KBITS),4).NE.0)THEN
         HTYPE='N'
         IF (IQ(LHWORK-2) .EQ. 2) THEN
            ITIT1=IQ(LHWORK+9)
            NWTITL=IQ(LHWORK+8)
         ELSE
            ITIT1=IQ(LHWORK+ZITIT1)
            NWTITL=IQ(LHWORK+ZNWTIT)
         ENDIF
         WRITE(LOUT,2000)IDN,HTYPE,(IQ(LHWORK+ITIT1+I-1),I=1,NWTITL)
      ENDIF
      CALL MZDROP(IHWORK,LHWORK,' ')
  40  LHWORK=0
      IF(IQ40.EQ.0)THEN
         CALL MZWIPE(IHWORK)
         GO TO 99
      ENDIF
      KEYNUM=KEYNUM+1
      IDN=IQ41
      GO TO 10
  90  CONTINUE
 1000 FORMAT(//,' ===> Directory : ',A)
 2000 FORMAT(1X,I10,1X,'(',A,')',3X,20A4)
 2100 FORMAT(1X,I10,1X,'(A)   Unnamed array')
  99  RETURN
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HREND(CHDIR)
#include "hbook/hcdire.inc"
      CHARACTER*(*) CHDIR
      NCHMAX=NCHTOP
      DO 20 I=2,NCHMAX
         IF(CHTOP(I).EQ.CHDIR)THEN
            IF(ICHTOP(I).GT.0.AND.ICHTOP(I).LT.1000)THEN
               CALL RZEND(CHDIR)
******         CALL HBFREE(ICHTOP(I))
            ENDIF
******      CALL HNTDEL(CHDIR)
            DO 10 J=I+1,NCHTOP
               ICHTOP(J-1)=ICHTOP(J)
               ICHLUN(J-1)=ICHLUN(J)
               ICHTYP(J-1)=ICHTYP(J)
               CHTOP(J-1)=CHTOP(J)
               HFNAME(J-1)=HFNAME(J)
  10        CONTINUE
            NCHTOP=NCHTOP-1
         ENDIF
  20  CONTINUE
      CALL HCDIR('//PAWC',' ')
      END

*-------------------------------------------------------------------------------

      SUBROUTINE HGNTF(IDD,IDNEVT,IERROR)
      print*,'>>>>>> Dummy HGNTF'
      END

*-------------------------------------------------------------------------------

