/' print [#] function (floating point) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintSingle FBCALL ( fnum as long, _val as single, mask as long )
	dim as ubyte buffer(0 to 8+1+9) '[8+1+9+1]

    fb_LPrintInit()
    fb_PrintFixString( fnum, fb_hFloat2Str( cast(double, _val), @buffer(0), 7, FB_F2A_ADDBLANK ), FB_PRINT_CONVERT_BIN_NEWLINE(mask) )
end sub

/':::::'/
sub fb_LPrintDouble FBCALL ( fnum as long, _val as double, mask as long )
	dim as ubyte buffer(0 to 16+1+9) '[16+1+9+1]

    fb_LPrintInit()
    fb_PrintFixString( fnum, fb_hFloat2Str( _val, @buffer(0), 16, FB_F2A_ADDBLANK ), FB_PRINT_CONVERT_BIN_NEWLINE(mask) )
end sub
end extern