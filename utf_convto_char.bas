/' UTF to zstring conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"

extern "C"

extern as const ubyte __fb_utf8_trailingTb(0 to 255)
extern as const UTF_32 __fb_utf8_offsetsTb(0 to 5)

/'
char * fb_hUTF8ToChar( const UTF_8 *src, char *dst, ssize_t *chars )
char * fb_hUTF16ToChar( const UTF_8 *src, char *dst, ssize_t *chars )
char * fb_hUTF32ToChar( const UTF_8 *src, char *dst, ssize_t *chars )

if 'dst' is null

	src 
		- 'src' is the address of the source utf-8 encoded string
		- must not be null
		- must have a null terminating character

	dst
		- ignored

	chars
		- 'chars' must not be null
		- 'chars' value is ignored on entry
		- on return, 'chars' is set to the number of characters 
		  converted not including the null terminator

	return value
		- the pointer to the newly allocated (realloc) memory
		  containing the converted string which includes a
		  terminating null character, or NULL pointer if
		  unable to allocate memory
		- 'chars' contains the number of characters 
		  converted not including the null terminator

	NOTE: caller is responsible to free the memory


if 'dst' is not null

	src
		- 'src' is the address of the source utf-8 encoded string
		- must not be null
		- may have null terminating character

	dst
		- 'dst' is the destination buffer for the ascii string

	chars
		- 'chars' must not be null
		- caller must set 'chars' to the maximum number of
		  characters to convert which may include the 
		  terminating null character
		- on return, 'chars' is set to the number characters
		  converted not including the terminating null
		  character
	
	NOTE: the caller will not know if a terminating null
	character was written based on the value of 'chars'.  The 
	value of 'chars' will be the same if the conversion ended
	on a terminating null character or the character
	immediately before it.  In either case, the terminating
	null character is not written.

'/

function fb_hUTF8ToChar( src as const UTF_8 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_32 c
	dim as ssize_t extbytes, charsleft
	dim as ubyte ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do 
			extbytes = __fb_utf8_trailingTb(cast(ulong, *src))
	
			c = 0
			on (extbytes+1) goto caseA0, caseA1, caseA2, caseA3, caseA4, caseA5
			goto defaultA
			'' switch ( extbytes )
				caseA5:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseA4:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseA3:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseA2:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseA1:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseA0:
					c += *src
					src += 1
				defaultA:
			'' end switch
	
			c -= __fb_utf8_offsetsTb(extbytes)
	
			if ( c > 255 ) then
				c = asc("?")
			end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				dim as ubyte ptr newbuffer = realloc( buffer, dst_size )
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if 
				buffer = newbuffer
				dst = buffer + dst_size - charsleft
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
			extbytes = __fb_utf8_trailingTb(*src)
	
			c = 0
			on (extbytes+1) goto caseB0, caseB1, caseB2, caseB3, caseB4, caseB5
			goto defaultB
			'' switch ( extbytes )
				caseB5:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseB4:
					c += *src
					src += 1 
					c shl= 6
					/' fall through '/
				caseB3:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseB2:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseB1:
					c += *src
					src += 1
					c shl= 6
					/' fall through '/
				caseB0:
					c += *src
					src += 1
				defaultB:
			'' end switch
	
			c -= __fb_utf8_offsetsTb(extbytes)

			if ( c > 255 ) then
				c = asc("?")
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_hUTF16ToChar( src as const UTF_16 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_16 c
	dim as ssize_t charsleft
	dim as ubyte ptr buffer = dst

    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do 
	    	c = *src
			src += 1
			if ( c > 255 ) then
				if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
	    			src += 1
				end if
	    		c = asc("?")
	    	end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				dim as ubyte ptr newbuffer = realloc( buffer, dst_size )
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if
				buffer = newbuffer
				dst = buffer + dst_size - charsleft
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
	    	c = *src
	    	src += 1
			if ( c > 255 ) then
				if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
	    			src += 1
				end if
				c = asc("?")
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_hUTF32ToChar( src as const UTF_32 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_32 c
	dim as ssize_t charsleft
	dim as ubyte ptr buffer = dst

    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
	    	c = *src
			src += 1
			if ( c > 255 ) then
				c = asc("?")
			end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				dim as ubyte ptr newbuffer = realloc( buffer, dst_size )
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if
				buffer = newbuffer 
				dst = buffer + dst_size - charsleft
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
	    	c = *src
	    	src += 1
			if ( c > 255 ) then
				c = asc("?")
			end if

			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_UTFToChar( encod as FB_FILE_ENCOD, src as const any ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	select case( encod )
		case FB_FILE_ENCOD_UTF8:
			return fb_hUTF8ToChar( src, dst, chars )
		case FB_FILE_ENCOD_UTF16:
			return fb_hUTF16ToChar( src, dst, chars )
		case FB_FILE_ENCOD_UTF32:
			return fb_hUTF32ToChar( src, dst, chars )
		case else:
			return NULL
	end select
end function
end extern