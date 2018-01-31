/' UTF to zstring conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"


extern as ubyte __fb_utf8_trailingTb(0 to 255)
extern as UTF_32 __fb_utf8_offsetsTb(0 to 5)
extern "C"
function fb_hUTF8ToChar( src as UTF_8 const ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_32 c
	dim as ssize_t extbytes, charsleft
	dim as ubyte ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do 
			extbytes = __fb_utf8_trailingTb(cast(ulong, *src))
	
			c = 0
			select case ( extbytes )
				case 5:
					c += *src + 1
					c shl= 6
				case 4:
					c += *src + 1
					c shl= 6
				case 3:
					c += *src + 1
					c shl= 6
				case 2:
					c += *src + 1
					c shl= 6
				case 1:
					c += *src + 1
					c shl= 6
				case 0:
					c += *src + 1
			end select
	
			c -= __fb_utf8_offsetsTb(extbytes)
	
			if ( c > 255 ) then
				c = asc("?")
			end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				buffer = realloc( buffer, dst_size )
				dst = buffer + dst_size - charsleft
			end if
			dst += 1
			*dst = c

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
			select case( extbytes )
				case 5:
					c += *src + 1
					c shl= 6
				case 4:
					c += *src + 1 
					c shl= 6
				case 3:
					c += *src + 1
					c shl= 6
				case 2:
					c += *src + 1
					c shl= 6
				case 1:
					c += *src + 1
					c shl= 6
				case 0:
					c += *src + 1
			end select
	
			c -= __fb_utf8_offsetsTb(extbytes)

			if ( c > 255 ) then
				c = asc("?")
			end if
			
			dst += 1
			*dst = c

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_hUTF16ToChar( src as UTF_16 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_16 c
	dim as ssize_t charsleft
	dim as ubyte ptr buffer = dst

    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do 
	    	c = *src + 1
			if ( c > 255 ) then
				if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
	    			src += 1
				end if
	    		c = asc("?")
	    	end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				buffer = realloc( buffer, dst_size )
				dst = buffer + dst_size - charsleft
			end if
			
			dst += 1
			*dst = c

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
	    	c = *src + 1
			if ( c > 255 ) then
				if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
	    			src += 1
				end if
				c = asc("?")
			end if
			
			dst += 1
			*dst = c

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_hUTF32ToChar( src as UTF_32 const ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
	dim as UTF_32 c
	dim as ssize_t charsleft
	dim as ubyte ptr buffer = dst

    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
	    	c = *src + 1
			if ( c > 255 ) then
				c = asc("?")
			end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				buffer = realloc( buffer, dst_size )
				dst = buffer + dst_size - charsleft
			end if
			
			dst += 1
			*dst = c

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
	    	c = *src + 1
			if ( c > 255 ) then
				c = asc("?")
			end if

			dst += 1
			*dst = c

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

function fb_UTFToChar( encod as FB_FILE_ENCOD, src as any const ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
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