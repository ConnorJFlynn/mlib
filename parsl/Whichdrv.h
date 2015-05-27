/***********************************\
*	WHICHDRV.H		VERSION 3.00.	*
*									*
*	WRITTEN FOR BC31, MSC70, WC90.	*
*									*
*	COPYRIGHT (C) GAGE APPLIED		*
*	SCIENCES INC.			1996.	*
*									*
*	LAST UPDATE:		98/09/25.	*
\***********************************/
#ifndef	__WHICHDRV_H__
#define	__WHICHDRV_H__

/*******************************************************\
*														*
*	IMPORTANT NOTE   IMPORTANT NOTE   IMPORTANT NOTE	*
*														*
*********************************************************
*														*
*	#include <windows.h> before #include "which_drv.h"	*
*		when developing windows based applications.		*
*														*
*	#include "whichdrv.h" before #include "gage_drv.h".	*
*														*
\*******************************************************/

/*******************************************\
*											*
*	Compiler in use and Target environment.	*
*											*
\*******************************************/
#ifdef	_CVI_
	#define	__DOS_32__
#endif

#ifndef	__BORLANDC__
	#ifdef	__TURBOC__
		#define	__BORLANDC__	__TURBOC__
	#endif
#endif

#ifdef	__BORLANDC__
	#define	__DOS_16__
#elif	defined(__WATCOMC__)
	#define	__DOS_32__
#else
	#define	__MICROSOFTC__
#endif

#ifndef	WINDOWS_CODE
	#ifdef	__BORLANDC__
		#ifdef	_Windows
			#define	WINDOWS_CODE
		#endif
	#else
		#ifdef	_WINDOWS
			#define	WINDOWS_CODE
		#endif
	#endif
#endif

#if defined WIN32 || defined _WIN32 || defined __WIN32
#define __WIN_32__
#endif

/***********************\
*						*
*	Calling convention.	*
*						*
\***********************/

#ifndef	GAGEAPI
	#ifdef	_CVI_
		#define	GAGEAPI __stdcall
		#ifdef	far
			#undef	far
		#endif
		#define	far
	#else
		#ifdef	__DOS_32__
			#define	GAGEAPI pascal
			#ifdef	far
				#undef	far
			#endif
			#define	far
		#else /* windows or Borlandc */
			#if	defined(__WIN_95__) || defined(__WIN_NT__) 
				#define	GAGEAPI	
			#elif	defined(__WIN_32__)
				#define	GAGEAPI	WINAPI
			#elif	defined(_CONSOLE)
				#define	GAGEAPI
			#else
				#define	GAGEAPI	far pascal /* Borlandc */
			#endif
		#endif
	#endif
#endif

#if defined(__WIN_95__) || defined(__WIN_NT__)
//#pragma warning(disable:4761)
#endif  /* defined(__WIN_95__) || defined(__WIN_NT__) */

#if defined(__WIN_95__) || defined(__WIN_NT__)||defined(__WIN_32__) || defined(_CONSOLE)
#ifdef	far
#undef	far
#endif
#ifdef	pascal
#undef	pascal
#endif
#define	far
#define	pascal
typedef char * LPSTR;
#endif

#ifdef	__WIN_NT__
	#define	DWORD unsigned long
	#define BOOL	BOOLEAN
#endif
#ifndef _CVI_
	#if	defined(__DOS_16__) || defined(__DOS_32__)
		#define	DWORD unsigned long
		#define BOOL	int
	#endif
#endif
/*******************************************\
*											*
*	Memory Type definitions for DRIVERS.	*
*											*
\*******************************************/

#ifndef	__GAGE_MEMORY_TYPES__
	#define	__GAGE_MEMORY_TYPES__
	typedef	unsigned char	uInt8;
	typedef	unsigned short	uInt16;
	typedef	unsigned long	uInt32;
	typedef	signed char		int8;
	typedef	signed short	int16;
	typedef	signed long		int32;
	#ifndef	_WIN32
		#ifdef	_CVI_
			typedef	char *	LPSTR;
		#else
			#if defined	__DOS_32__ || defined __linux__
				typedef	char *		LPSTR;
			#else
				typedef	char far *	LPSTR;
			#endif
		#endif
	#endif
#endif

/***************************************************\
*													*
*	Special typedef, works around Microsoft C		*
*	compiler bug when using the GAGEAPI typedef for	*
*	a pointer to a function.  Neither Borland nor	*
*	Watcom require this workaround.					*
*													*
\***************************************************/

#ifndef	__WIN_NT__
#ifndef	__WIN_95__
#ifndef	__DOS_32__
#ifndef	__DOS_16__
#ifndef	__WIN_32__
#ifndef __linux__

#define	SPECIAL_FOR_MICROSOFT_C

typedef	int16 GAGEAPI IGAGEAPI;
typedef	int32 GAGEAPI I32GAGEAPI;

#endif
#endif
#endif
#endif
#endif
#endif

#ifdef __linux__
	#ifndef __LINUX__
	#define __LINUX__
	#endif
#endif
	
#ifdef __LINUX__
	#ifdef far
	#undef far
	#endif
  
	#ifdef pascal
	#undef pascal
	#endif

	#ifdef GAGEAPI
	#undef GAGEAPI
	#endif
  
	#define far
	#define pascal
	#define GAGEAPI

	#define O_BINARY	0	/* no difference between text and binary in LINUX */ 
	#define O_TEXT		0

	#define max(a, b)	(((a) > (b)) ? (a) : (b))
	#define min(a, b)	(((a) < (b)) ? (a) : (b))
	#define getch		getchar		/* getch() is fro Win 95/NT only	*/
	#define putch		putchar	
	#define _fmemcpy	memcpy
	#define _fmemset	memset
	#define	_fstrcat	strcat		
    #define	_fstrlen	strlen		
    #define _fstrcpy	strcpy		
    #define _fstrncpy	strncpy
    
	#define _MAX_PATH	256
  	#define DWORD		unsigned long
  	#define WORD		unsigned short
  	#define BYTE		unsigned char
	
  	#if defined (__KERNEL__) && defined (MODULE)
		#define __LINUX_KNL__
	
		#define stricmp		strcmp
		#define strnicmp	strncmp

	#else  /* KERNEL  */

		#define stricmp		strcasecmp
		#define strnicmp	strncasecmp
  	#endif
  	
#endif	/* __LINUX__	*/

/***************************************************\
*													*
*	Support WHICH CompuScope cards with DRiVers.	*
*													*
\***************************************************/

#ifdef	__PCI_UTILITIES__

#define	ALLOW_CSPCI_CODE
#define	ALLOW_ONLY_PCI_CODE

#else	/*	__PCI_UTILITIES__	*/

#define	ALLOW_CS220_CODE
#define	ALLOW_CSLITE_CODE
#define	ALLOW_CS250_CODE
#define	ALLOW_CS2125_CODE
#define	ALLOW_TMB_CODE
#define ALLOW_GPIB

#if defined(__DOS_32__) || defined(__DOS_16__)
#undef	ALLOW_GPIB
#endif

#if defined(__WIN_95__) || defined(__WIN_NT__) || defined(__WIN_32__) || defined(__linux__)

	#define	ALLOW_CSPCI_CODE
	#define	ALLOW_CS8500_CODE
	#ifdef	ALLOW_CS8500_CODE
		#define	ALLOW_CS12100_CODE
		#define	ALLOW_CS3200_CODE
		#define ALLOW_CS82G_CODE
		#define	nALLOW_CS8500_CODE_RANGES
		#define	ALLOW_CS1610_CODE_RANGES
		#define	ALLOW_CS85G_CODE_RANGES
		#define	ALLOW_CS85G_CODE /* nat 090501 CS85G not defined for DOS */
		#ifndef	ALLOW_CSPCI_CODE
			#define	ALLOW_CSPCI_CODE
		#endif
	#endif

	#ifdef	ALLOW_TMB_CODE
	#undef	ALLOW_TMB_CODE
	#endif

	#define	ALLOW_CS1012_CODE

	#define	ALLOW_CS2125_CODE
	#define	ALLOW_CS250_CODE
	#define	ALLOW_CS220_CODE
	#define	ALLOW_CSLITE_CODE

//  Enable this to build the Windows driver with Real-time and Interrupts featrure
    #define REALTIME_ISR
#if defined(__DOS_32__) || defined(__DOS_16__)
#undef	REALTIME_ISR
#endif
//	#define REALTIME_ISR_ENABLE

#elif	defined(__DOS_16__) || defined(__DOS_32__)

	#ifndef	__MICROSOFTC__	/*	MICROSOFT C CANNOT COMPILE PCI CODE !!!!	*/

		#define	ALLOW_CSPCI_CODE
		#define	ALLOW_CS8500_CODE
		#ifdef	ALLOW_CS8500_CODE
			#define	ALLOW_CS12100_CODE
			#define	ALLOW_CS3200_CODE
			#define	ALLOW_CS82G_CODE
			#define	nALLOW_CS8500_CODE_RANGES
			#define	ALLOW_CS1610_CODE_RANGES
			#ifndef	ALLOW_CSPCI_CODE
				#define	ALLOW_CSPCI_CODE
			#endif
		#endif
		#define	nALLOW_ONLY_PCI_CODE
		#define	nALLOW_CS1012_CODE
		#define	ALLOW_CS1012_CODE

	#endif

#endif //__WIN_95__ || __WIN_NT__

#define	nALLOW_TALSBIT_CODE

#define	nALLOW_CSDEMO_CODE

#endif	/*	__PCI_UTILITIES__	*/

/***************************************************\
*													*
*	Support WHICH CompuScope features with DRiVers.	*
*													*
\***************************************************/

#define	ALLOW_MULTIPLE_SYSTEMS

#define	ALLOW_MIN_MAX_CODE

#define	ALLOW_MASTER_SLAVE_BOARDS

#define	ALLOW_GATED_MASTER_SLAVE

#define	__PTM_8500_1_2__		1

#ifdef	__DOS_32__
	/*should always be 0 Watcom not supported yet */
	#define __8500_ISR_1_2__	0
#else	//__DOS_32__
	/* enable only for the 8500isrb.exe application */
#if defined(__WIN_NT__) || defined(__WIN_95__)
	#ifdef REALTIME_ISR
		#define __8500_ISR_1_2__	1
	#else
		#define __8500_ISR_1_2__	0
	#endif
#endif

#endif	// __DOS_32__

/***************************************************\
*													*
*	Support WHICH Special and/or debugging features	*
*	with DRiVers.									*
*													*
\***************************************************/

#define	nALLOW_FLOATING_POINT_CODE

#define	ALLOW_CS1012_DIRECT_ISR_CODE

#define	nDEBUGGING_GATED_CAPTURE

#define	nDEBUG_TA

/*******************************************************************\
*																	*
*	Automatic support of the standard options used to compile		*
*	GageScope and its utilities (compiler definition __GAGESCOPE__)	*
*	or GSINST for the drivers (compiler definition __GSINST_DRV__)	*
*	and the drivers (neither of these above compiler definitions).	*
*																	*
\*******************************************************************/

#ifdef	__GAGESCOPE__
#define	__WHICHDRV__T1__	1
#else
#define	__WHICHDRV__T1__	0
#endif

#ifdef	__GSINST_DRV__
#define	__WHICHDRV__T2__	0
#else
#define	__WHICHDRV__T2__	1
#endif

#if	((__WHICHDRV__T1__+__WHICHDRV__T2__)==2)

	#ifdef	ALLOW_MULTIPLE_SYSTEMS
		#undef	ALLOW_MULTIPLE_SYSTEMS
	#endif
	#ifdef	ALLOW_MIN_MAX_CODE
		#undef	ALLOW_MIN_MAX_CODE
	#endif
	#ifdef	ALLOW_CS1012_DIRECT_ISR_CODE
		#undef	ALLOW_CS1012_DIRECT_ISR_CODE
	#endif

#else

	#ifdef	ALLOW_MASTER_SLAVE_BOARDS
		#undef	ALLOW_MASTER_SLAVE_BOARDS
	#endif

#endif

#undef	__WHICHDRV__T1__
#undef	__WHICHDRV__T2__

#ifndef	ALLOW_CS250_CODE
	#ifdef	ALLOW_MIN_MAX_CODE
		#undef	ALLOW_MIN_MAX_CODE
	#endif
#endif

/***********************************************************************\
*																		*
*	If gated capture is required with master slave then the trigger		*
*	address for each board is required instead of only the master		*
*	boards trigger address which is then inturn applied to all cards	*
*	in the master slave system (this is not true for all boards, but	*
*	is for some).														*
*																		*
\***********************************************************************/

#ifdef	ALLOW_GATED_MASTER_SLAVE

#ifdef	ALLOW_MASTER_SLAVE_BOARDS
#undef	ALLOW_MASTER_SLAVE_BOARDS
#endif

#endif

/***********************************************************************\
*																		*
*	Support for only master/slave operation (ALLOW_MASTER_SLAVE_BOARDS	*
*	is defined) excludes multiple independant CompuScope cards.  This	*
*	results in a smaller driver.  If ALLOW_MASTER_SLAVE_BOARDS is		*
*	undefined then both master/slave operation and multiple independant	*
*	operation is possible but the driver is larger.						*
*																		*
*	To switch between the two types of operation requires a call to		*
*	"gage_set_independant_operation".  By default the					*
*	"gage_independant_operation" variable is cleared.  This allows the	*
*	driver to start working in the master/slave operation mode.			*
*	"gage_set_independant_operation" must be called prior to calling	*
*	"gage_driver_initialize".  If the driver is already initialized,	*
*	then a call to "gage_set_independant_operation" can still be done,	*
*	however, the "gage_driver_initialize" routine must be called again	*
*	to re-initialize the driver.										*
*																		*
\***********************************************************************/

#ifndef	ALLOW_MASTER_SLAVE_BOARDS

#define	ALLOW_INDEPENDANT_OPERATION

#endif

#define	nSPECIAL_6012_8012_CODE		/*	CS6012E.	*/

#ifdef	ALLOW_CS2125_CODE
#define	nALLOW_CS2125_EIB_CODE_RANGES
#endif

#define	UNSIGNED_SAMPLE_RESOLUTION

#ifdef	ALLOW_CS2125_EIB_CODE_RANGES
#ifdef	UNSIGNED_SAMPLE_RESOLUTION
#undef	UNSIGNED_SAMPLE_RESOLUTION
#endif
#endif

#define	USE_UNSIGNED_MEMORY_REQUIRED_FOR_DMB
#ifdef	USE_UNSIGNED_MEMORY_REQUIRED_FOR_DMB
#else	/*	USE_UNSIGNED_MEMORY_REQUIRED_FOR_DMB	*/
#endif	/*	USE_UNSIGNED_MEMORY_REQUIRED_FOR_DMB	*/

//#define	USE_CS85G_INTERRUPT_CODE


// Enable this to debug Input/Output from the Windows drivers.
// Disable this when build the drivers for release to improve the drivers performance.
// #define GAGEDRV_DEBUG_IO

#endif //__WHICHDRV_H__
/*	End of WHICHDRV.H.  */
