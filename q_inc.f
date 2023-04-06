*     This file is made by Nobu on Nov. 13, 2021
*     Replacing the zebra/q_***.inc files
*-------------------------------------------------------------------------------

      FUNCTION JBYTET (MZ,IZW,IZP,NZB)
      JBYTET  = IAND (MZ,
     + ISHFT (IAND(ISHFT(IZW,33-IZP-NZB),Z'FFFFFFFF'),
     + -(32-NZB)) )
      END
      
*-------------------------------------------------------------------------------

      FUNCTION MBYTOR (MZ,IZW,IZP,NZB)
      MBYTOR  = IOR (IZW,
     + ISHFT (IAND(ISHFT(MZ,32-NZB),Z'FFFFFFFF'),
     + -(33-IZP-NZB)))
      END
      
*-------------------------------------------------------------------------------

      FUNCTION MSBIT (MZ,IZW,IZP)
      MSBIT = IOR (IAND (IZW, NOT(ISHFT(1,IZP-1)))
     + ,ISHFT(IAND(MZ,1),IZP-1))
      END
      
*-------------------------------------------------------------------------------

      FUNCTION MSBIT0 (IZW,IZP)
      MSBIT0 = IAND (IZW, NOT(ISHFT(1,IZP-1)))
      END
      
*-------------------------------------------------------------------------------

      FUNCTION MSBIT1 (IZW,IZP)
      MSBIT1 = IOR (IZW, ISHFT(1,IZP-1))
      END
      
*-------------------------------------------------------------------------------

      FUNCTION MSBYT (MZ,IZW,IZP,NZB)
      INTEGER*4 IALL11
      PARAMETER (IALL11 = -1)
      MSBYT = IOR (
     + IAND (IZW, NOT(ISHFT (
     + ISHFT(IALL11,-(32-NZB)),IZP-1)))
     + ,ISHFT (IAND(ISHFT(MZ,32-NZB),Z'FFFFFFFF'),
     + -(33-IZP-NZB)) )
      END
      
*-------------------------------------------------------------------------------
      
      FUNCTION ISHFTL (IZW,NZB)
      ISHFTL = ISHFT (IZW, NZB)
      END
      
*-------------------------------------------------------------------------------
