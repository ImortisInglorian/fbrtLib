/' write [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteLongint FBCALL ( fnum as long, _val as longint, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%" FB_LL_FMTMOD "d" )
end sub

/':::::'/
sub fb_WriteULongint FBCALL ( fnum as long, _val as ulongint, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%" FB_LL_FMTMOD "u" )
end sub
end extern