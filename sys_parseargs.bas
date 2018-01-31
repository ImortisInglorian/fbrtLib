#include "fb.bi"

/' dst     - preallocated buffer to hold processed args
   src     - source string for arguments, may contain embedded null chars
   length  - length of src
   returns -1 on error, or number of arguments '/

extern "C"
function fb_hParseArgs( dst as ubyte ptr, src as ubyte const ptr, length as ssize_t ) as long
	dim as long in_quote = 0, argc = 0
	dim as ssize_t bs_count = 0, i = 0
	dim as ubyte ptr s = cast(ubyte ptr, src)
	dim as ubyte ptr p = dst

	/' s  - next char to read from src
	   p  - next char to write in dst '/

	/' return -1 to indicate error '/
	if ( src = NULL or dst = NULL or length < 0 ) then
		return -1
	end if

	/' skip leading white space '/
	while ( i < length and (*s = asc(" ") or *s = 0) )
		i += 1
		s += 1
	wend

	/' scan for arguments. ' ' and '\0' are delimiters '/
	while( i < length )
		bs_count = 0

		do
			if ( *s = asc(!"\\") ) then
				P += 1
				*p = *s
				bs_count += 1
			else
				if ( *s = asc(!"\"")) then
					if ( (bs_count and 1) <> 0 ) then
						p -= ((bs_count - 1) shr 1) + 1
						P += 1
						*p = *s
					else
						p -= ( bs_count shr 1 )
						in_quote = not(in_quote)
					end if
				elseif ( *s = asc(" ") or *s = 0 ) then
					if ( in_quote <> 0 ) then
						p += 1
						*p = asc(" ")
					else
						p += 1
						*p = 0
						exit do
					end if
				else
					p += 1
					*p = *s
				end if

				bs_count = 0
			end if

			i += 1
			s += 1

		loop while ( i < length )

		argc += 1

		/' skip trailing white space '/
		while( i < length and ( *s = asc(" ") or *s = 0 ) )
			i += 1
			s += 1
		wend
	wend

	*p = 0

	/' return arguments found '/
	return argc
end function
end extern