/' rnd# function '/

#include "fb.bi"

#if defined (HOST_WIN32)
	#include "windows.bi"
	#include "win\wincrypt.bi"
#elseif defined (HOST_LINUX)
	#include "crt\fcntl.bi"
	#include "crt\unistd.bi"
#endif

#define RND_AUTO		0
#define RND_CRT			1
#define RND_FAST		2
#define RND_MTWIST		3
#define RND_QB			4
#define RND_REAL		5

#define INITIAL_SEED	327680

#define MAX_STATE		624
#define PERIOD			397

extern "C"
declare function hRnd_Startup cdecl ( n as single ) as double
declare function hRnd_CRT cdecl ( n as single ) as double
declare function hRnd_QB cdecl ( n as single ) as double
Dim shared rnd_func as function cdecl ( as single ) as double = @hRnd_Startup
dim shared as uint32_t iseed = INITIAL_SEED
dim shared as uint32_t state(0 to MAX_STATE-1)
dim shared as uint32_t ptr p = NULL
dim shared as double last_num = 0.0

function hRnd_Startup cdecl ( n as single ) as double	
	select case __fb_ctx.lang
		case FB_LANG_QB:
			rnd_func = @hRnd_QB
			iseed = INITIAL_SEED
		case FB_LANG_FB_FBLITE or FB_LANG_FB_DEPRECATED:
			rnd_func = @hRnd_CRT
		case else
			fb_Randomize( 0.0, 0 )
	end select
	return fb_Rnd( n )
end function

function hRnd_CRT cdecl ( n as single ) as double
	if ( n = 0.0 ) then
		return last_num
	end if
	/' return between 0 and 1 (but never 1) '/
	return cast(double,rand( )) * ( 1.0 / ( cast(double, RAND_MAX) + 1.0 ) )
end function

function hRnd_FAST cdecl ( n as single ) as double
	/' return between 0 and 1 (but never 1) '/
	/' Constants from 'Numerical recipes in C' chapter 7.1 '/
	if ( n <> 0.0 ) then
		iseed = ( ( 1664525 * iseed ) + 1013904223 )
	end if

	return cast(double, iseed) / cast(double,4294967296ULL)
end function

function hRnd_MTWIST cdecl ( n as single ) as double
	if ( n = 0.0 ) then
		return last_num
	end if
	
	dim as uint32_t i, v, xor_mask(0 to 1) = { 0, &h9908B0DF }

	if ( p = NULL ) then
		/' initialize state starting with an initial seed '/
		fb_Randomize( INITIAL_SEED, RND_MTWIST )
	end if

	if ( p >= state(0) + MAX_STATE ) then
		/' generate another array of 624 numbers '/
		for i = 0 to MAX_STATE - PERIOD
			v = ( state(i) and &h80000000 ) or ( state(i + 1) and &h7FFFFFFF )
			state(i) = state(i + PERIOD) xor ( v shr 1 ) xor xor_mask(v and &h1)
		next
		
		for j as long =i to MAX_STATE - 1
			v = ( state(i) and &h80000000 ) or ( state(i + 1) and &h7FFFFFFF )
			state(i) = state(i + PERIOD - MAX_STATE) xor ( v shr 1 ) xor xor_mask(v and &h1)
		next
		v = ( state(MAX_STATE - 1) and &h80000000 ) or ( state(0) and &h7FFFFFFF  )
		state(MAX_STATE - 1) = state(PERIOD - 1) xor ( v shr 1 ) xor xor_mask(v and &h1)
		p = @state(0)
	end if

	v = *p + 1
	v xor= ( v shr 11 )
	v xor= ( ( v shl 7 ) and &h9D2C5680 )
	v xor= ( ( v shl 15 ) and &hEFC60000 )
	v xor= ( v shr 18 )

	return cast(double, v) / cast(double, 4294967296ULL)
end function

function hRnd_QB cdecl ( n as single ) as double
	union ftoi
		f as single
		i as uint32_t
	end union

	dim _ftoi as ftoi
	
	if ( n <> 0.0 ) then
		if ( n < 0.0 ) then
			_ftoi.f = n
			dim as uint32_t s = _ftoi.i
			iseed = s + ( s shr 24 )
		end if
		iseed = ( ( iseed * &hFD43FD ) + &hC39EC3 ) and &hFFFFFF
	end if
	
	return cast(single, iseed) / cast(single, &h1000000)
end function

#if defined (HOST_WIN32) or defined (HOST_LINUX)
function hGetRealRndNumber cdecl ( ) as uinteger
	union _number
		as uinteger i
		as ubyte b(sizeof(uinteger))
	end union
	
	dim number as _number
	number.i = 0

	#if defined (HOST_WIN32)
	dim as HCRYPTPROV provider = 0
	if ( CryptAcquireContext( @provider, NULL, 0, PROV_RSA_FULL, 0 ) = TRUE ) then
		if ( CryptGenRandom( provider, sizeof(number), @number.b(0) ) = FALSE ) then
			number.i = 0
		end if
		CryptReleaseContext( provider, 0 )
	end if

	#elseif defined (HOST_LINUX)
	dim as long urandom = open_( "/dev/urandom", O_RDONLY )
	if ( urandom <> -1 ) then
		if ( read_( urandom, @number.b(0), sizeof(number) ) <> sizeof(number) ) then
			number.i = 0
		end if
		close_( urandom )
	end if
	#endif

	return number.i
end function

function hRnd_REAL cdecl ( n as single ) as double
	static as uinteger count = 0
	static as uinteger v
	dim as double mtwist

	mtwist = hRnd_MTWIST(n)
	if ( (count mod 256) = 0 ) then
		count = 1

		/' get new random number '/
		v = hGetRealRndNumber( )
	else
		count += 1
	end if

	if ( v = 0 ) then
		return mtwist
	end if
	v *= mtwist

	v xor= (v shr 11)
	v xor= ((v shl 7) and &h9D2C5680)
	v xor= ((v shl 15) and &hEFC60000)
	v xor= (v shr 18)

	return cast(double, v) / cast(double, 4294967296ULL)
end function
#endif

function fb_Rnd FBCALL ( n as single ) as double
	last_num = rnd_func( n )
	return last_num
end function

sub fb_Randomize FBCALL ( seed as double, algorithm as long )
	dim as long i

	union _dtoi
		as double d
		as uint32_t i(0 to 1)
	end union
	
	dim dtoi as _dtoi

	if ( algorithm = RND_AUTO ) then
		select case __fb_ctx.lang
			case FB_LANG_QB:
				algorithm = RND_QB
			case FB_LANG_FB_FBLITE or FB_LANG_FB_DEPRECATED:
				algorithm = RND_CRT
			case FB_LANG_FB:
				algorithm = RND_MTWIST
		end select
	end if

	if ( seed = -1.0 ) then
		/' Take value of Timer to ensure a non-constant seed.  The seeding
		algorithms (with the exception of the QB one) take the long value
		of the seed, so make a value that will change more than once a second '/

		dtoi.d = fb_Timer( )
		seed = cast(double, (dtoi.i(0) xor dtoi.i(1)))
	end if

	select case algorithm
		case RND_CRT:
			rnd_func = @hRnd_CRT
			srand( cast(uinteger, seed) )
			rand( )
			
		case RND_FAST:
			rnd_func = @hRnd_FAST
			iseed = cast(uint32_t, seed)

		case RND_QB:
			rnd_func = @hRnd_QB
			dtoi.d = seed
			dim as uint32_t s = dtoi.i(1)
			s xor= ( s shr 16 )
			s = ( ( s and &hFFFF ) shl 8 ) or ( iseed and &hFF )
			iseed = s

		#if defined (HOST_WIN32) or defined (HOST_LINUX)
		case RND_REAL:
			rnd_func = @hRnd_REAL
			state(0) = cast(uinteger,seed)
			for i = 1 to MAX_STATE
				state(i) = ( state(i - 1) * 1664525 ) + 1013904223
			next
			p = @state(0) + MAX_STATE
		#endif
		case RND_MTWIST:
			rnd_func = @hRnd_MTWIST
			state(0) = cast(uinteger, seed)
			for i = 1 to MAX_STATE
				state(i) = ( state(i - 1) * 1664525 ) + 1013904223
			next
			p = @state(0) + MAX_STATE
	end select
end sub
end extern
