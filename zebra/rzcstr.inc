      PARAMETER (MAXFILES=128, MAXSTRIP=21)
      CHARACTER*128 RZNAMES(MAXFILES),RZSFILE(MAXSTRIP)
      COMMON/RZCSTRC/RZNAMES,RZSFILE
      COMMON/RZCSTRI/ISLAST,ISTRIP(MAXFILES),NSTRIP(MAXFILES),
     + NRSTRIP(MAXFILES)
