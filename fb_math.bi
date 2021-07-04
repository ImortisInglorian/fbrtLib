#ifdef fb_CVDFROMLONGINT
	#undef fb_CVDFROMLONGINT
	#undef fb_CVSFROML
	#undef fb_CVLFROMS
	#undef fb_CVLONGINTFROMD
#endif

extern "C"

enum _FB_RND_ALGORITHMS
	FB_RND_AUTO = 0
	FB_RND_CRT
	FB_RND_FAST
	FB_RND_MTWIST
	FB_RND_QB
	FB_RND_REAL
end enum

/' single instance global state '/
declare sub      fb_Randomize FBCALL ( byval seed as double, byval algorithm as long )
declare function fb_Rnd       FBCALL ( byval n as single ) as double
declare function fb_Rnd32     FBCALL ( ) as uint32_t 

#define FB_RND_MAX_STATE 624

type FB_RNDSTATE
	as uint32_t algorithm        /' see FB_RND_ALGORITHMS '/
	as uint32_t length           /' length of state vector (# of uint32_t) '/

	/' function pointers to internal rnd() and rnd32() called by fb_Rnd() and fb_Rnd32() '/
	rndproc   as function ( byval n as single  ) as double
	rndproc32 as function ( ) as uint32_t

	union
		as uint64_t iseed64      /' initial seed and state 64-bit '/
		as uint32_t iseed32      /' initial seed and state 32-bit '/
	end union
	as uint32_t ptr index32      /' pointer to index in state vector, if length != 0 '/
	
	/' state vector '/
	as uint32_t state32(FB_RND_MAX_STATE - 1)
end type

declare function fb_RndGetState FBCALL ( ) as FB_RNDSTATE ptr

/' Constants from 'Numerical recipes in C' chapter 7.1 '/
#define FBRNDFAST32(arg) ( ( (arg) * 1664525 ) + 1013904223 )

private sub hRnd_FillFAST32 ( byval buffer as uint32_t ptr, byval length32 as uint32_t , byval iseed32 as uint32_t )
	dim as uint32_t i
	buffer[0] = iseed32
	i = 1
	while( i < length32 )
		buffer[i] = FBRNDFAST32( buffer[i - 1] )
		i += 1
	wend
end sub

declare function fb_SGNSingle       FBCALL ( byval x as single ) as long
declare function fb_SGNDouble       FBCALL ( byval x as double ) as long
declare function fb_FIXSingle       FBCALL ( byval x as single ) as single
declare function fb_FIXDouble       FBCALL ( byval x as double ) as double

declare function fb_CVDFROMLONGINT  FBCALL ( byval l as longint ) as double
declare function fb_CVSFROML        FBCALL ( byval l as long ) as single
declare function fb_CVLFROMS        FBCALL ( byval f as single ) as long
declare function fb_CVLONGINTFROMD  FBCALL ( byval d as double ) as longint

declare function fb_IntLog10_32 	FBCALL ( byval x as ulong ) as long
declare function fb_IntLog10_64 	FBCALL ( byval x as ulongint ) as long

end extern
