#ifdef fb_ArrayBoundChkEx
	#undef fb_ArrayBoundChkEx
	#undef fb_ArraySngBoundChkEx
	#undef fb_ArrayDimensionChk
	#undef fb_ArrayDestructObj
	#undef fb_ArrayDestructStr
	#undef fb_ArrayClear
	#undef fb_ArrayClearObj
	#undef fb_ArrayErase
	#undef fb_ArrayEraseObj
	#undef fb_ArrayFill
	#undef fb_ArrayStrErase
	#undef fb_ArrayRedimEx
	#undef fb_ArrayRedimObj
	#undef fb_ArrayRedimPresvEx
	#undef fb_ArrayRedimPresvObj
	#undef fb_ArrayRedimTo
	#undef fb_ArrayLBound
	#undef fb_ArrayUBound
#endif

type FBARRAYDIM 
	as size_t elements
	as ssize_t lbound
	as ssize_t ubound
end type

enum _FBARRAY_FLAGS
	FBARRAY_FLAGS_DIMENSIONS = &h0000000f
	FBARRAY_FLAGS_FIXED_DIM  = &h00000010
	FBARRAY_FLAGS_FIXED_LEN  = &h00000020
	FBARRAY_FLAGS_RESERVED   = &hffffffc0
end enum

type FBARRAY
	as any ptr           data        /' ptr + diff, must be at ofs 0! '/
	as any ptr           _ptr
	as size_t          size
	as size_t          element_len
	as size_t          dimensions
	as size_t          flags       /' FBARRAY_FLAGS '/
	as FBARRAYDIM      dimTB(0)    /' dimtb[dimensions] '/
end type

extern "C"

type FB_DEFCTOR as sub ( this_ as any ptr )
type FB_DTORMULT as sub ( array as FBARRAY ptr, dtor as FB_DEFCTOR, base_idx as size_t )

declare function fb_ArrayBoundChkEx FBCALL _
	( _
		idx as ssize_t, _
		lbound as ssize_t, _
		ubound as ssize_t, _
		linenum as long, _
		filename as const ubyte ptr, _
		variablename as const ubyte ptr _
	) as any ptr

declare function fb_ArraySngBoundChkEx FBCALL _
	( _
		sidx as size_t, _
		ubound as size_t, _
		linenum as long, _
		filename as const ubyte ptr, _
		variablename as const ubyte ptr _
	) as any ptr

declare function fb_ArrayDimensionChk FBCALL _ 
	( _
		idx as ssize_t, _
		array as FBARRAY ptr, _
		linenum as long, _
		filename as const ubyte ptr, _
		variablename as const ubyte ptr _
	) as any ptr

declare function fb_ArrayLen            FBCALL ( array as FBARRAY ptr ) as size_t
declare function fb_ArraySize           FBCALL ( array as FBARRAY ptr ) as size_t
declare sub 	 fb_hArrayCtorObj 			   ( array as FBARRAY ptr, ctor as FB_DEFCTOR )
declare sub 	 fb_hArrayDtorObj 			   ( array as FBARRAY ptr, dtor as FB_DEFCTOR, keep_idx as size_t )
declare sub 	 fb_hArrayDtorStr 			   ( array as FBARRAY ptr, dtor as FB_DEFCTOR, heep_idx as size_t )
declare sub 	 fb_ArrayDestructObj 	FBCALL ( array as FBARRAY ptr, dtor as FB_DEFCTOR )
declare sub 	 fb_ArrayDestructStr 	FBCALL ( array as FBARRAY ptr )
declare function fb_ArrayClear 			FBCALL ( array as FBARRAY ptr ) as long
declare function fb_ArrayClearObj 		FBCALL ( array as FBARRAY ptr, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long
declare function fb_ArrayErase 			FBCALL ( array as FBARRAY ptr ) as long
declare function fb_ArrayEraseObj 		FBCALL ( array as FBARRAY ptr, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long
declare function fb_ArrayFill           FBCALL ( array as FBARRAY ptr, byval fillchar as long ) as long
declare function fb_ArrayGetDesc        FBCALL ( array as FBARRAY ptr ) as FBARRAY ptr
declare sub 	 fb_ArrayStrErase 		FBCALL ( array as FBARRAY ptr )
declare function fb_ArrayRedim 				   ( array as FBARRAY ptr, element_len as size_t, preserve as long, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimEx 			   ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimObj 			   ( array as FBARRAY ptr, element_len as size_t, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimPresv 		   ( array as FBARRAY ptr, element_len as size_t, preserve as long, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimPresvEx 		   ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimPresvObj 	 	   ( array as FBARRAY ptr, element_len as size_t, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR, dimensions as size_t, ... ) as long
declare function fb_ArrayRedimTo 		FBCALL ( dest as FBARRAY ptr, source as const FBARRAY ptr, isvarlen as long, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long
declare sub 	 fb_ArrayResetDesc 		FBCALL ( array as FBARRAY ptr )
declare function fb_ArrayLBound 		FBCALL ( array as FBARRAY ptr, dimension as ssize_t ) as ssize_t
declare function fb_ArrayUBound 		FBCALL ( array as FBARRAY ptr, dimension as ssize_t ) as ssize_t
declare function fb_hArrayCalcElements 	 	   ( dimensions as size_t, lboundTB as const ssize_t ptr, uboundTB as const ssize_t ptr ) as size_t
declare function fb_hArrayCalcDiff 			   ( dimensions as size_t, lboundTB as const ssize_t ptr, uboundTB as const ssize_t ptr ) as ssize_t

declare function fb_hArrayAlloc 			   ( array as FBARRAY ptr, element_len as size_t, doclear as long, ctor as FB_DEFCTOR, dimensions as size_t, ap as va_list ) as long

declare function fb_hArrayRealloc 			   ( array as FBARRAY ptr, element_len as size_t, doclear as long, ctor as FB_DEFCTOR, dtor_mult as FB_DTORMULT, dtor as FB_DEFCTOR, dimensions as size_t, ap as va_list ) as long

end extern