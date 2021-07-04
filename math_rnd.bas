/' rnd# function '/

#include "fb.bi"

#if defined (HOST_WIN32)
	#include "windows.bi"
	#include "win\wincrypt.bi"
#elseif defined (HOST_LINUX)
	#include "crt\fcntl.bi"
	#include "crt\unistd.bi"
#endif

extern "C"
/' rtlib is initialzied so that RND & RND32 call the
   startup routines.  This allows calling RND without
   first call RANDOMIZE.  After the startup routine is
   called, the functions are remapped to the actual PRNG
   functions.
'/

declare function hRnd_Startup32 (  ) as uint32_t
declare function hRnd_Startup ( n as single ) as double

declare sub hRndCtxInitCRT32    ( byval seed as uint32_t )
declare sub hRndCtxInitFAST32   ( byval seed as uint32_t )
declare sub hRndCtxInitMTWIST32 ( byval seed as uint64_t )
declare sub hRndCtxInitQB32     ( byval seed as uint32_t )
#if defined( HOST_WIN32 ) orelse defined( HOST_LINUX )
declare sub hRndCtxInitREAL32   ( byval seed as uint64_t )
#endif

#define INITIAL_SEED	327680

/' MAX_STATE is number of 32-bit unsigned integers '/
/' used by FB_RND_MTWIST & FB_RND_REAL '/
#define MAX_STATE     (FB_RND_MAX_STATE)
#define PERIOD        397

dim shared as FB_RNDSTATE ctx => ( _
	FB_RND_AUTO,       /' generator '/       _
	0,                 /' length of state '/ _
	@hRnd_Startup,     /' fb_Rnd() '/        _          
	@hRnd_Startup32,   /' fb_Rnd32() '/      _
	(0),               /' iseed64 '/         _
	NULL,              /' index pointer '/   _
	/' state32[] - state for FB_RND_MTWIST 
	   and buffer for FB_RND_REAL follows '/  _
	{0} _
)

/' last number as returned by RND(0.0) 
	- is updated by fb_Rnd() only
	- is never reset
	- is not updated by fb_Rnd32() or any of the other PRNG procedures
 '/
dim shared as double last_num = 0.0

/' FB_RND_CRT '/
private function hRnd_CRT32 ( ) as uint32_t
	return rand( )
end function

private function hRnd_CRT ( byval n as single ) as double
	if( n = 0.0 ) then
		return last_num
	end if

	/' return between 0 and 1 (but never 1) '/
	return cast( double, hRnd_CRT32() * ( 1.0 / ( cast( double, RAND_MAX ) + 1.0 ) ) )
end function

private sub hRndCtxInitCRT32 ( byval seed as uint32_t )
	ctx.algorithm = FB_RND_CRT
	ctx.length = 0
	ctx.index32 = NULL
	ctx.rndproc = @hRnd_CRT
	ctx.rndproc32 = @hRnd_CRT32

	srand( cast( ulong, seed ) )
end sub

/' FB_RND_FAST '/
private function hRnd_FAST32 ( ) as uint32_t
	ctx.iseed32 = FBRNDFAST32( ctx.iseed32 )
	return ctx.iseed32 
end function

private function hRnd_FAST ( byval n as single ) as double
	/' return last value if argument is 0.0 '/
	if( n = 0.0 ) then
		return cast( double, ctx.iseed32 ) / cast( double, 4294967296ULL )
	end if

	/' return between 0 and 1 (but never 1) '/
	return cast( double, hRnd_FAST32() ) / cast( double, 4294967296ULL )
end function

private sub hRndCtxInitFAST32 ( byval seed as uint32_t )
	ctx.algorithm = FB_RND_FAST
	ctx.length = 0
	ctx.index32 = NULL
	ctx.iseed32 = seed
	ctx.rndproc = @hRnd_FAST
	ctx.rndproc32 = @hRnd_FAST32
end sub

/' FB_RND_MTWIST '/
private function hRnd_MTWIST32 ( ) as uint32_t 
	dim as uint32_t i, v, xor_mask(0 to 1) = { 0, &h9908B0DF }

	if( ctx.index32 = NULL ) then
		/' initialize state starting with an initial seed '/
		hRndCtxInitMTWIST32( INITIAL_SEED )
	end if

	if( ctx.index32 >= @ctx.state32(0) + MAX_STATE ) then
		/' generate another array of 624 numbers '/
		i = 0
		while( i < MAX_STATE - PERIOD )
			v = ( ctx.state32(i) and &h80000000 ) or ( ctx.state32(i + 1) and &h7FFFFFFF )
			ctx.state32(i) = ctx.state32(i + PERIOD) xor ( v shr 1 ) xor xor_mask(v and &h1)
			i += 1
		wend
		while( i < MAX_STATE - 1 )
			v = ( ctx.state32(i) and &h80000000 ) or ( ctx.state32(i + 1) and &h7FFFFFFF )
			ctx.state32(i) = ctx.state32(i + PERIOD - MAX_STATE) xor ( v shr 1 ) xor xor_mask(v and &h1)
			i +=1
		wend
		v = ( ctx.state32(MAX_STATE - 1) and &h80000000 ) or ( ctx.state32(0) and &h7FFFFFFF )
		ctx.state32(MAX_STATE - 1) = ctx.state32(PERIOD - 1) xor ( v shr 1 ) xor xor_mask(v and &h1)
		ctx.index32 = @ctx.state32(0)
	end if

	v = *ctx.index32
	ctx.index32 += 1
	v xor= ( v shr 11 )
	v xor= ( ( v shl 7 ) and &h9D2C5680 )
	v xor= ( ( v shl 15 ) and &hEFC60000 )
	v xor= ( v shr 18 )

	return v
end function

private function hRnd_MTWIST ( byval n as single ) as double
	if( n = 0.0 ) then
		return last_num
	end if

	return cast(double, hRnd_MTWIST32() ) / cast( double, 4294967296ULL )
end function

private sub hRndCtxInitMTWIST32 ( byval seed as uint64_t )
	ctx.algorithm = FB_RND_MTWIST
	ctx.length = MAX_STATE
	ctx.index32 = @ctx.state32(0) + MAX_STATE
	ctx.rndproc = @hRnd_MTWIST
	ctx.rndproc32 = @hRnd_MTWIST32

	hRnd_FillFAST32( @ctx.state32(0), MAX_STATE, cast(uint32_t, seed) )
end sub

/' FB_RND_QB '/
private function hRnd_QB32 ( ) as uint32_t
	ctx.iseed32 = ( ( ctx.iseed32 * &hFD43FD ) + &hC39EC3 ) and &hFFFFFF
	return ctx.iseed32
end function

private function hRnd_QB ( byval n as single ) as double
	union _ftoi
		as single f
		as uint32_t i
	end union
	dim ftoi as _ftoi = any 

	if( n = 0.0 ) then
		return cast(single, ctx.iseed32) / cast(single, &h1000000)
	end if

	if( n < 0.0 ) then
		ftoi.f = n
		dim as uint32_t s = ftoi.i
		ctx.iseed32 = s + ( s shr 24 )
	end if

	return cast( single, hRnd_QB32() ) / cast( single, &h1000000 )
end function

private sub hRndCtxInitQB32 ( byval seed as uint32_t )
	ctx.algorithm = FB_RND_QB
	ctx.length = 0
	ctx.index32 = NULL
	ctx.iseed32 = seed
	ctx.rndproc = @hRnd_QB
	ctx.rndproc32 = @hRnd_QB32
end sub

/' FB_RND_REAL '/

#if defined( HOST_WIN32 ) orelse defined( HOST_LINUX )
private function hRefillRealRndNumber( ) as long
	dim as long success = 0
	
	const SIZEOF_STATE32 = (sizeof(ctx.state32(0)) * ( ubound(ctx.state32) - lbound(ctx.state32) + 1 )) 

#if defined( HOST_WIN32 )
	dim as HCRYPTPROV provider = 0
	if( CryptAcquireContext( @provider, NULL, 0, PROV_RSA_FULL, 0 ) = TRUE ) then
		success = CryptGenRandom( provider, SIZEOF_STATE32, cast(BYTE ptr, @ctx.state32(0)) )
		CryptReleaseContext( provider, 0 )
	end if

#elseif defined( HOST_LINUX )
	dim as long urandom = open_( "/dev/urandom", O_RDONLY )
	if( urandom <> -1 ) then
		success = ( read_( urandom, @ctx.state32(0), SIZEOF_STATE32 ) = SIZEOF_STATE32 )
		close_( urandom )
	end if
#endif
	if( success ) then
		ctx.index32 = @ctx.state32(0)
	end if
	return success 
end function

private function hRnd_REAL32( ) as uint32_t
	dim as uint32_t v = any
	if( ctx.index32 = ( @ctx.state32(0) + MAX_STATE ) ) then
		/' get new random numbers, if not available, redirect to MTwist as per docs '/
		if( hRefillRealRndNumber() = 0 ) then
			fb_Randomize( -1.0, FB_RND_MTWIST )
			return hRnd_MTWIST32()
		end if
	end if
	v = *ctx.index32
	ctx.index32 += 1
	return v
end function

private function hRnd_REAL( byval n as single ) as double
	if( n = 0.0 ) then
		return last_num
	endif

	return cast( double, hRnd_REAL32() ) / cast( double, 4294967296ULL )
end function

private sub hRndCtxInitREAL32 ( byval seed as uint64_t )
	ctx.algorithm = FB_RND_REAL
	ctx.length = MAX_STATE
	ctx.index32 = @ctx.state32(0) + MAX_STATE
	ctx.rndproc = @hRnd_REAL
	ctx.rndproc32 = @hRnd_REAL32

	/' initialize starting state - used by hRefillRealRndNumber() '/
	hRnd_FillFAST32( @ctx.state32(0), MAX_STATE, cast(uint32_t, seed ) )
end sub
#endif

/' RND Startup code '/

private sub hStartup( )
	select case __fb_ctx.lang
	case FB_LANG_QB
		hRndCtxInitQB32( INITIAL_SEED )
	case FB_LANG_FB_FBLITE, FB_LANG_FB_DEPRECATED 
		hRndCtxInitCRT32( 1 )
	case else
		fb_Randomize( 0.0, FB_RND_AUTO )
	end select
end sub

private function hRnd_Startup32 ( ) as uint32_t
	hStartup()
	return fb_Rnd32()
end function

private function hRnd_Startup ( byval n as single ) as double
	hStartup()
	return fb_Rnd( n )
end function

private function getAlogrithm( byval algorithm as long ) as long
	if( algorithm = FB_RND_AUTO ) then
		select case __fb_ctx.lang
		case FB_LANG_QB
			algorithm = FB_RND_QB
		case FB_LANG_FB_FBLITE, FB_LANG_FB_DEPRECATED
			algorithm = FB_RND_CRT
		case else
			algorithm = FB_RND_MTWIST
		end select
	end if
	return algorithm
end function

/' Public API for the built-in PRNGs '/

/' declare sub randomize alias "fb_Randomize" ( byval seed as double = -1.0, byval algorithm as long = FB.FB_RND_AUTO ) '/
sub fb_Randomize FBCALL ( byval seed as double, byval algorithm as long )

	union _dtoi
		as double d
		as uint32_t i(0 to 1)
	end union
	
	dim dtoi as _dtoi = any

	FB_MATH_LOCK()

	if( seed = -1.0 ) then
		/' Take value of Timer to ensure a non-constant seed.  The seeding
		algorithms (with the exception of the QB one) take the integer value
		of the seed, so make a value that will change more than once a second '/

		dtoi.d = fb_Timer()
		seed = cast(double, (dtoi.i(0) xor dtoi.i(1)) )
	end if

	ctx.algorithm = getAlogrithm( algorithm )

	select case ctx.algorithm
	case FB_RND_CRT
		hRndCtxInitCRT32( cast(uint32_t, seed ) )
		fb_Rnd32()

	case FB_RND_FAST
		hRndCtxInitFAST32( cast(uint32_t, seed ) )

	case FB_RND_QB
		dtoi.d = seed
		dim as uint32_t s = dtoi.i(1)
		s xor= ( s shr 16 )
		s = ( ( s and &hFFFF ) shl 8 ) or ( ctx.iseed32 and &hFF )
		hRndCtxInitQB32( cast(uint32_t, s ) )

#if defined( HOST_WIN32 ) orelse defined( HOST_LINUX )
	case FB_RND_REAL
		hRndCtxInitREAL32( cast(uint32_t, seed ) )
#endif
	case else '' FB_RND_MTWIST
		hRndCtxInitMTWIST32( cast(uint32_t, seed ) )
	end select

	FB_MATH_UNLOCK()
end sub

/' declare function rnd alias "fb_Rnd" ( byval n as single = 1.0 ) as double '/
function fb_Rnd FBCALL ( byval n as single ) as double
	FB_MATH_LOCK()
	last_num = ctx.rndproc( n )
	FB_MATH_UNLOCK()
	return last_num
end function

/' declare function rnd32 alias "fb_Rnd32" ( ) as ulong '/
function fb_Rnd32 FBCALL ( ) as uint32_t 
	dim as uint32_t result = any
	FB_MATH_LOCK()
	result = ctx.rndproc32()
	FB_MATH_UNLOCK()
	return result
end function

/' declare function rndGetState alias "fb_RndGetState" ( ) as FB_RNDSTATE ptr '/
function fb_RndGetState FBCALL ( ) as FB_RNDSTATE ptr
	return @ctx
end function

end extern
