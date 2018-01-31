/' print [#] function (longint) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintLongint FBCALL ( fnum as long, _val as longint, mask as long )
	FB_PRINTNUM( fnum, _val, mask, "% ", FB_LL_FMTMOD "d" )
end sub

/':::::'/
sub fb_PrintULongint FBCALL ( fnum as long, _val as ulongint, mask as long )
    FB_PRINTNUM( fnum, _val, mask, "%", FB_LL_FMTMOD "u" )
end sub
end extern