/' string/descriptor allocation, deletion, assignament, etc
 *
 * string is interpreted depending on the size argument passed:
 * -1 = var-len
 *  0 = fixed-len, size unknown (ie, returned from a non-FB function)
 * >0 = fixed-len, size known (this size isn't used tho, as string will
 *      have garbage after the null-term, ie: spaces)
 *      destine string size can't be 0, as it is always known
 '/

#include "fb.bi"
#include "crt\stddef.bi"

/' alloc every 32-bytes '/
#define hStrRoundSize( size ) (((size) + 31) and Not(31))

function fb_hStrAlloc FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
	dim as ssize_t newsize = hStrRoundSize( size ) + 1

	_str->data = Allocate( newsize )
	/' failed? try the original request '/
	if ( _str->data = NULL ) then
		_str->data = Allocate( size + 1 )
		if ( _str->data = NULL ) then
			_str->len = 0 
			_str->size = 0
			return NULL
		end if

		newsize = size
	end if

	_str->size = newsize
	_str->len = size

	Assert( ( newSize <> 0 ) AndAlso ( "Size of 0 means static string that won't be freed, this is a memory leak" <> ""))

    return _str
end function

function fb_hStrRealloc FBCALL ( _str as FBSTRING ptr, size as ssize_t, _preserve as long ) as FBSTRING ptr
	dim as ssize_t newsize = hStrRoundSize( size )
	/' plus 12.5% more '/
	newsize += (newsize shr 3)

	if ( (_str->data = NULL) orelse (size > _str->size) orelse (newsize < (_str->size - (_str->size shr 3))) ) then
		if ( _preserve = FB_FALSE ) then
			fb_StrDelete( _str )

			_str->data = Allocate( newsize + 1 )
			/' failed? try the original request '/
			if ( _str->data = NULL ) then
				_str->data = Allocate( size + 1 )
				newsize = size
			end if
		else
			dim as ubyte ptr pszOld = _str->data
			_str->data = ReAllocate( pszOld, newsize + 1 )
			/' failed? try the original request '/
			if ( _str->data = NULL ) then
				_str->data = ReAllocate( pszOld, size + 1 )
				newsize = size
				if ( _str->data = NULL ) then
					/' restore the old memory block '/
					_str->data = pszOld
					return NULL
				end if
			end if
		end if

		if ( _str->data = NULL ) then
			_str->len = 0
			_str->size = 0
			return NULL
		end if

		_str->size = newsize
	end if

	Assert( ( _str->size <> 0 ) AndAlso ( "Size of 0 means static string that won't be freed, this is a memory leak" <> ""))
	fb_hStrSetLength( _str, size )

	return _str
end function

sub fb_hStrCopy FBCALL ( dst as ubyte ptr, src as const ubyte ptr, bytes as ssize_t )
	if ( (src <> NULL) and (bytes > 0) ) then
		dst = cast(ubyte ptr, FB_MEMCPYX( dst, src, bytes ))
	end if

	/' add the null-term '/
	*dst = asc(!"\000") '' NUL CHAR
end sub
