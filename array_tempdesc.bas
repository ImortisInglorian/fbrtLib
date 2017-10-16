/' !!!REMOVEME!!! '/
/' temp descriptor core, for array fields passed by descriptor '/

#include "fb.bi"
#include "crt/stddef.bi"

/' *********
 * temp array descriptors
 **********'/

dim shared as FB_LIST tmpdsList = Type( 0, 0, 0, 0 )

dim shared as FB_ARRAY_TMPDESC fb_tmpdsTB(0 to FB_ARRAY_TMPDESCRIPTORS - 1)

extern "C"
/':::::'/
function fb_hArrayAllocTmpDesc cdecl( ) as FBARRAY ptr
	dim as FB_ARRAY_TMPDESC ptr dsc

	if ( (tmpdsList.fhead = NULL) and (tmpdsList.head = NULL) ) then
		fb_hListInit( @tmpdsList, cast(any ptr, @fb_tmpdsTB(0)), sizeof(FB_ARRAY_TMPDESC), FB_ARRAY_TMPDESCRIPTORS )
	end if

	dsc = cast(FB_ARRAY_TMPDESC ptr, fb_hListAllocElem( @tmpdsList ))
	if ( dsc = NULL ) then
		return NULL
	end if
	return cast(FBARRAY ptr, @dsc->array)
end function

/':::::'/
sub fb_hArrayFreeTmpDesc cdecl ( src as FBARRAY ptr )
	dim as FB_ARRAY_TMPDESC ptr dsc

	dsc = cast(FB_ARRAY_TMPDESC ptr, (cast(ubyte ptr, src)- offsetof(FB_ARRAY_TMPDESC, array)))

	fb_hListFreeElem( @tmpdsList, cast(FB_LISTELEM ptr, dsc) )
end sub

function fb_ArrayAllocTempDesc cdecl ( pdesc as FBARRAY ptr ptr, arraydata as any ptr, element_len as size_t, dimensions as size_t, ... ) as FBARRAY ptr
    dim as va_list ap
	dim as size_t i, elements
	dim as ssize_t diff
    dim as FBARRAY ptr array
    dim as FBARRAYDIM ptr _dim
	dim as ssize_t lbTB(0 to FB_MAXDIMENSIONS - 1)
	dim as ssize_t ubTB(0 to FB_MAXDIMENSIONS - 1)

	FB_LOCK()
    array = fb_hArrayAllocTmpDesc( )
    FB_UNLOCK()

    *pdesc = array

    if ( array = NULL ) then
    	return NULL
	end if
    	
   	if ( dimensions = 0) then
   		/' special case for GET temp arrays '/
   		array->size = 0
		return array
   	end if

    'va_start( ap, dimensions )
	ap = va_first()

	_dim = @array->dimTB(0)

    for i = 0 to dimensions
		lbTB(i) = cast(ssize_t, va_next( ap, ssize_t ))
		ubTB(i) = cast(ssize_t, va_next( ap, ssize_t ))

    	_dim->elements = (ubTB(i) - lbTB(i)) + 1
    	_dim->lbound = lbTB(i)
    	_dim->ubound = ubTB(i)
    	_dim += 1
    next

    'va_end( ap )

    elements = fb_hArrayCalcElements( dimensions, @lbTB(0), @ubTB(0) )
    diff = fb_hArrayCalcDiff( dimensions, @lbTB(0), @ubTB(0) ) * element_len

	array->data = (cast(ubyte ptr, arraydata)) + diff
	array->_ptr = arraydata
	array->size = elements * element_len
	array->element_len = element_len
	array->dimensions = dimensions

    return array
end function

sub fb_ArrayFreeTempDesc FBCALL( pdesc as FBARRAY ptr )
	FB_LOCK()
	fb_hArrayFreeTmpDesc( pdesc )
	FB_UNLOCK()
end sub
end extern