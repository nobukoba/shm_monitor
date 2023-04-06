/*
 * $Id: hshm.c,v 1.2 1996/03/13 10:13:08 couet Exp $
 *
 * $Log: hshm.c,v $
 * Revision 1.2  1996/03/13 10:13:08  couet
 * Mods for ALPHA_OSF: William Badgett, Univ of Wisconsin <BADGETT@vxdesy.desy.de>
 *
 * Revision 1.1.1.1  1996/01/16 17:08:10  mclareni
 * First import
 *
 */
/*CMZ :  4.20/10 11/10/93  15.44.27  by  Rene Brun*/
/*-- Author :    Fons Rademakers   20/03/91*/
/*-- Modified:   Wojtek Burkot     02/03/92*/
 
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
 
#define  SHM_R      0400
#define  SHM_W      0200

static int    shm_pawc;
static void  *paddr = 0; /* 0 was added nobu */
static long   len;
 
/* Nobu added 2021.10.11
   Nobu hfreem_cre_ -->  hfreem_map_ 2022.06.30 --> */
static void  *paddr_map = 0;
int hfreem_(long *);
int hfreem_map_(long *);
/* <-- */

 
/***********************************************************************
 *                                                                     *
 *   Create a shared memory segment.                                   *
 *   mkey          identifier for the shared segment                   *
 *   size          length of common in 32 bit words                    *
 *   comaddr       required starting address of mapping on input       *
 *                 starting address of the mapping on output           *
 *                                                                     *
 ***********************************************************************/
int hcreatei_(key_t *mkey, int *size, long *comaddr)
{
   int             istat;
   int             flag = IPC_CREAT | 0666;
   unsigned long   inter;
   void           *req_addr;
 
#if !defined(DOUBLE_PRECISION)
   len = *size * 4;
#else
   len = *size * 8;
#endif

   /* Nobu added 2021.10.11, modified 2022.06.30  --> */
   if (paddr){
     hfreem_(0);
   }
   /* <-- */

   /* create shared memory segment */
   if ((shm_pawc = shmget(*mkey, len, flag)) < 0) {
      perror("shmget");
      istat = -errno;
      return(istat);
   }
 
   /*
    * attach shared memory segment
    * starting at req_addr
    */
    req_addr = (void*)(*comaddr);
    if ((paddr = shmat(shm_pawc, req_addr, SHM_RND)) == (void *)-1) {
      perror("shmat");
      istat = -errno;
   } else {
      istat    = 0;
      inter    = (unsigned long) paddr;
#if !defined(DOUBLE_PRECISION)
      *comaddr = (long) (inter >> 2);
#else
      *comaddr = (long) (inter >> 3);
#endif
   }
    /*
      printf("hshm.c (unsigned long)paddr %ld\n", (unsigned long)paddr);
      printf("hshm.c comaddr %ld\n", comaddr);
      printf("hshm.c *comaddr %ld\n", *comaddr);
    */
    
    return(istat);
}
 
/***********************************************************************
 *                                                                     *
 *   Attach to existing shared memory segment.                         *
 *   mkey          identifier for the shared segment                   *
 *   comaddr       required starting address of mapping on input       *
 *                 starting address of the mapping on output           *
 *                                                                     *
 ***********************************************************************/
int hmapi_(key_t *mkey, long *comaddr)
{
   int              istat;
   unsigned long    inter;
   void            *req_addr;
   struct shmid_ds  shm_stat;

   /* Nobu added 2021.10.11, modified 2022.06.30 --> */
   if (paddr_map){
     hfreem_map_(0);
   }
   /* <-- */
   /*
     printf("hshm.c comaddr %ld\n", comaddr);
     printf("hshm.c *comaddr %ld\n", *comaddr);
   */      
   /* get id of existing shared memory segment */
   if ((shm_pawc = shmget(*mkey, 0, SHM_R | SHM_W)) < 0) {
      perror("shmget");
      istat = -errno;
      return(istat);
   }
 
   /* get size of shared memory segment */
   if (shmctl(shm_pawc, IPC_STAT, &shm_stat) == -1) {
      perror("shmctl");
      istat = -errno;
      return(istat);
   }
   len = shm_stat.shm_segsz;
 
  /*
   * set required mapping address - actual mapping addres depends on
   * setting of system variables. This requires modification in
   * the interface fortran routine HMAPM
   */
   req_addr=(void*)(*comaddr);
   /* attach shared memory segment */

   /*printf("hshm.c (unsigned long)req_addr %ld\n", (unsigned long)req_addr);*/

   if ((paddr = shmat(shm_pawc, req_addr, SHM_RND)) == (void *)-1) {
      perror("shmat");
      istat = -errno;
   } else {
      istat    = 0;
      inter    = (unsigned long) paddr;
#if !defined(DOUBLE_PRECISION)
      *comaddr = (long) (inter >> 2);
#else
      *comaddr = (long) (inter >> 3);
#endif
      /*printf("hshm.c (unsigned long)paddr %ld\n", (unsigned long)paddr);
      printf("hshm.c comaddr %ld\n", comaddr);
      printf("hshm.c *comaddr %ld\n", *comaddr);*/
   }
   
   return(istat);
}
 
/***********************************************************************
 *                                                                     *
 *   Free a shared memory segment.                                     *
 *   comaddr      address of common that should be unmapped (not used) *
 *                                                                     *
 ***********************************************************************/
int hfreem_(long *comaddr)
{
   int istat;
 
   /*printf("hshm.c (unsigned long)paddr %ld\n", (unsigned long)paddr);*/

   /* unmaps segment from address space */
   if ((istat = shmdt(paddr)) == -1) {
      perror("shmdt");
      istat = -errno;
      return(istat);
   }
   /* Nobu added 2021.10.11 --> */
   paddr = 0;
   /* <-- */
   
   /* delete shared segment */
/*****
   if ((istat = shmctl(shm_pawc, IPC_RMID, (struct shmid_ds *)0)) == -1) {
      perror("shmctl");
      istat = -errno;
   }
*****/
   return(istat);
}

/* Nobu added 2021.10.11 --> */
int hfreem_map_(long *comaddr)
{
   int istat;
   /* unmaps segment from address space */
   if ((istat = shmdt(paddr_map)) == -1) {
      perror("shmdt");
      istat = -errno;
      return(istat);
   }
   paddr_map = 0;
   return(istat);
}
/* <-- */
