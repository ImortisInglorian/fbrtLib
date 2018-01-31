/' ports I/O hooks, default to system implementations '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_In FBCALL( port as ushort ) as long
	dim as long res = -1
	
	FB_LOCK()
	
	if ( __fb_ctx.hooks.inproc <> NULL ) then
		res = __fb_ctx.hooks.inproc( port )
	end if
	if ( res < 0 ) then
		res = fb_hIn( port )
	end if
	
	FB_UNLOCK()
	
	return res
end function

/':::::'/
function fb_Out FBCALL ( port as ushort, value as ubyte ) as long
	dim as long res = -1
	
	FB_LOCK()
	
	if ( __fb_ctx.hooks.outproc <> NULL ) then
		res = __fb_ctx.hooks.outproc( port, value )
	end if
	if ( res < 0 ) then
		res = fb_hOut( port, value )
	end if
	
	FB_UNLOCK()
	
	return res
end function

/':::::'/
function fb_Wait FBCALL ( port as ushort, _and as long, _xor as long ) as long
	dim as long res
	
	do
		res = fb_In( port )
		if ( res < 0 ) then
			return res
		end if
		res ^= _xor
	loop while( ( res and _and ) = 0 )
	
	return FB_RTERROR_OK
end function
end extern