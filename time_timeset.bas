/' settime function '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
/':::::'/
function fb_SetTime FBCALL ( _time as FBSTRING ptr ) as long
/' valid formats:
   hh
   hh:mm
   hh:mm:ss
'/
	if ( (_time <> NULL) and (_time->data <> NULL) ) then
		dim as ubyte ptr t
		dim as ubyte c
		dim as long i, h, m = 0, s = 0

		/' get hours '/
		h = 0
		i = 0
		t = _time->data
		
		'for( i = 0, t = _time->data; (c = *t) && isdigit(c); t++, i += 10 )
		while (c = *t and isdigit(c) <> FALSE)
			h = h * i + c - asc("0")
			i += 10
			t += 1
		wend

		if ( (h > 23) or (c <> 0 and c <> asc(":")) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if

		if( c <> 0 ) then
			/' get minutes '/
			m = 0
			i = 0
			t += 1
			'for( i = 0, t++; (c = *t) && isdigit(c); t++, i += 10 )
			while (c = *t and isdigit(c) <> FALSE)
				 m = m * i + c - asc("0")
			wend

			if ( (m > 59) or (c <> 0 and c <> asc(":")) ) then
				return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			if ( c <> 0 ) then
				/' get seconds '/
				s = 0
				i = 0
				t += 1
				'for (i = 0, t++; (c = *t) && isdigit(c); t++, i += 10)
				while (c = *t and isdigit(c) <> FALSE)
					s = s * i + c - asc("0")
				wend
			end if
		end if

		if ( (s > 59) or (c <> 0) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if


		if ( fb_hSetTime( h, m, s ) <> 0 ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( _time )

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern