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

/''''''''''
 * temp string descriptors (string lock is assumed to be held in the thread-safe rlib version)
 *********'/

Dim shared as FB_LIST tmpdsList = Type( 0, NULL, NULL, NULL )

Dim shared as FB_STR_TMPDESC fb_tmpdsTB( 0 to FB_STR_TMPDESCRIPTORS - 1)

extern "C"
function fb_hStrAllocTmpDesc FBCALL ( ) as FBSTRING ptr
	dim as FB_STR_TMPDESC ptr dsc

	if ( (tmpdsList.fhead = NULL) andalso (tmpdsList.head = NULL) ) then
		fb_hListInit( @tmpdsList, @fb_tmpdsTB(0), sizeof(FB_STR_TMPDESC), FB_STR_TMPDESCRIPTORS )
	end if

	dsc = cast(FB_STR_TMPDESC ptr, fb_hListAllocElem( @tmpdsList ))
	if ( dsc = NULL ) then
		return NULL
	end if

	/'  '/
	dsc->desc.data = NULL
	dsc->desc.len  = 0
	dsc->desc.size = 0

	return @dsc->desc
end function

sub fb_hStrFreeTmpDesc cdecl ( dsc as FB_STR_TMPDESC ptr )
	fb_hListFreeElem( @tmpdsList,  @dsc->elem )

	/'  '/
	dsc->desc.data = NULL
	dsc->desc.len  = 0
	dsc->desc.size = 0
end sub

function fb_hStrDelTempDesc FBCALL( _str as FBSTRING ptr ) as long
	dim as FB_STR_TMPDESC ptr item = cast(FB_STR_TMPDESC ptr, ( cast(ubyte ptr, _str) - offsetof( FB_STR_TMPDESC, desc ) ))

	/' is this really a temp descriptor? '/
	if ( (item < @fb_tmpdsTB(0)) orelse (item > @fb_tmpdsTB(FB_STR_TMPDESCRIPTORS - 1)) ) then
		return -1
	end if

	fb_hStrFreeTmpDesc( item )
	return 0
end function

/''''''''''
 * internal helper routines
 *********'/

/' alloc every 32-bytes '/
#define hStrRoundSize( size ) (((size) + 31) and Not(31))

function fb_hStrAlloc FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
	dim as ssize_t newsize = hStrRoundSize( size )

	_str->data = Allocate( newsize + 1 )
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
				_str->data = cast(ubyte ptr, malloc( size + 1 ))
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

	fb_hStrSetLength( _str, size )

    return _str
end function

function fb_hStrAllocTemp_NoLock FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
	dim as long try_alloc = (_str = NULL)

    if ( try_alloc ) then
        _str = fb_hStrAllocTmpDesc( )
        if ( _str=NULL ) then
            return NULL
		end if
    end if

    if ( fb_hStrRealloc( _str, size, FB_FALSE ) = NULL ) then
        if ( try_alloc ) then
            fb_hStrDelTempDesc( _str )
		end if
        return NULL
    else
        _str->len or= FB_TEMPSTRBIT
	end if

    return _str
end function

function fb_hStrAllocTemp FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
    dim as FBSTRING ptr res

    FB_STRLOCK( )

    res = fb_hStrAllocTemp_NoLock( _str, size )

    FB_STRUNLOCK( )

    return res
end function

function fb_hStrDelTemp_NoLock FBCALL ( _str as FBSTRING ptr ) as long
	if ( _str = NULL ) then
		return -1
	end if

	/' is it really a temp? '/
	if ( FB_ISTEMP( _str ) ) then
        fb_StrDelete( _str )
	end if

    /' del descriptor (must be done by last as it will be cleared) '/
    return fb_hStrDelTempDesc( _str )
end function

function fb_hStrDelTemp FBCALL ( _str as FBSTRING ptr ) as long
	dim as long res

	FB_STRLOCK( )

	res = fb_hStrDelTemp_NoLock( _str )

	FB_STRUNLOCK( )

	return res
end function

sub fb_hStrCopy FBCALL ( dst as ubyte ptr, src as const ubyte ptr, bytes as ssize_t )
	if ( (src <> NULL) and (bytes > 0) ) then
		dst = cast(ubyte ptr, FB_MEMCPYX( dst, src, bytes ))
	end if

	/' add the null-term '/
	*dst = asc(!"\000") '' NUL CHAR
end sub
end extern