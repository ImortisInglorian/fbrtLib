/' string assigning function '/

#include "fb.bi"

extern "C"
function fb_StrAssignEx FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr, src_size as ssize_t, fill_rem as long, is_init as long ) as any ptr
	dim dstr as FBSTRING ptr
	dim src_ptr as ubyte ptr
	dim src_len as ssize_t

	FB_STRLOCK()

	if ( dst = NULL ) then
		if( src_size = -1 ) then
			fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, src) )
		end if
      
		FB_STRUNLOCK()
      
		return dst
	end if

	/' src '/
	FB_STRSETUP_FIX( src, src_size, src_ptr, src_len )

	/' is dst var-len? '/
	if ( dst_size = -1 ) then
		dstr = cast(FBSTRING ptr, dst)
      
		/' src NULL? '/
		if ( src_len = 0 ) then
			if ( is_init = FB_FALSE ) then
				fb_StrDelete( dstr )
			else
				dstr->data = NULL
				dstr->len = 0
				dstr->size = 0
			end if
		else
			/' if src is a temp, just copy the descriptor '/
			if ( (src_size = -1) and FB_ISTEMP(src) ) then
				if ( is_init = FB_FALSE ) then
					fb_StrDelete( dstr )
				end if
				
				dstr->data = cast(ubyte ptr, src_ptr)
				dstr->len = src_len
				dstr->size = cast(FBSTRING ptr, src)->size
            
				cast(FBSTRING ptr, src)->data = NULL
				cast(FBSTRING ptr, src)->len = 0
				cast(FBSTRING ptr, src)->size = 0
            
				fb_hStrDelTempDesc( cast(FBSTRING ptr, src) )
            
				FB_STRUNLOCK()
            
				return dst
			end if
         
        	/' else, realloc dst if needed and copy src '/
        	if ( is_init = FB_FALSE ) then
				if ( FB_STRSIZE( dst ) <> src_len ) then
					fb_hStrRealloc( dstr, src_len, FB_FALSE )
				end if
        	else
				fb_hStrAlloc( dstr, src_len )
        	end if
           
			fb_hStrCopy( dstr->data, src_ptr, src_len )
		end if
	/' fixed-len or zstring.. '/
	else
		/' src NULL? '/
		if ( src_len = 0 ) then
			*cast(ubyte ptr, dst) = 0
		else
			/' byte ptr? as in C, assume dst is large enough '/
			if ( dst_size = 0 ) then
				dst_size = src_len
			else
				dst_size -= 1 						/' less the null-term '/
				if ( dst_size < src_len ) then
					src_len = dst_size
				end if
			end if
         
			fb_hStrCopy( cast(ubyte ptr, dst) , src_ptr, src_len )
		end if
      
		/' fill reminder with null's '/
		if ( fill_rem <> 0 ) then
			dst_size -= src_len
			if ( dst_size > 0 ) then
				memset( @(cast(ubyte ptr, dst)[src_len]), 0, dst_size )
			end if
		end if
	end if


	/' delete temp? '/
	if ( src_size = -1 ) then
		fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, src) )
	end if
	FB_STRUNLOCK()

	return dst
end function

function fb_StrAssign FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr, src_size as ssize_t, fill_rem as long ) as any ptr
	return fb_StrAssignEx( dst, dst_size, src, src_size, fill_rem, FB_FALSE )
end function

function fb_StrInit FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr, src_size as ssize_t, fill_rem as long ) as any ptr
	return fb_StrAssignEx( dst, dst_size, src, src_size, fill_rem, FB_TRUE )
end function
end extern