/' dynamic arrays core '/

#include "fb.bi"

extern "C"
function fb_hArrayCalcElements cdecl ( dimensions as size_t, lboundTB as ssize_t const ptr, uboundTB as ssize_t const ptr ) as size_t
	dim as size_t i, elements

    elements = (uboundTB[0] - lboundTB[0]) + 1
    for i = 1 to dimensions
    	elements *= (uboundTB[i] - lboundTB[i]) + 1
	next

    return elements
end function

function fb_hArrayCalcDiff cdecl ( dimensions as size_t, lboundTB as ssize_t const ptr, uboundTB as ssize_t const ptr ) as ssize_t
	dim as size_t i, elements
	dim as ssize_t diff = 0

	if ( dimensions <= 0 ) then
		return 0
	end if

    for i = 0 to dimensions - 1
    	elements = (uboundTB[i+1] - lboundTB[i+1]) + 1
    	diff = (diff + lboundTB[i]) * elements
    next

	diff += lboundTB[dimensions-1]

	return -diff
end function
end extern