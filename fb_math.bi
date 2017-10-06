#ifdef fb_CVDFROMLONGINT
	#undef fb_CVDFROMLONGINT
	#undef fb_CVSFROML
	#undef fb_CVLFROMS
	#undef fb_CVLONGINTFROMD
#endif

extern "C"
declare function fb_Rnd             FBCALL ( n as single ) as double
declare sub      fb_Randomize       FBCALL ( seed as double, algorithm as long )
declare function fb_SGNSingle       FBCALL ( x as single ) as long
declare function fb_SGNDouble       FBCALL ( x as double ) as long
declare function fb_FIXSingle       FBCALL ( x as single ) as single
declare function fb_FIXDouble       FBCALL ( x as double ) as double

declare function fb_CVDFROMLONGINT  FBCALL ( l as longint ) as double
declare function fb_CVSFROML        FBCALL ( l as long ) as single
declare function fb_CVLFROMS        FBCALL ( f as single ) as long
declare function fb_CVLONGINTFROMD  FBCALL ( d as double ) as longint

declare function fb_IntLog10_32 	FBCALL ( x as ulong ) as long
declare function fb_IntLog10_64 	FBCALL ( x as ulongint ) as long
end extern