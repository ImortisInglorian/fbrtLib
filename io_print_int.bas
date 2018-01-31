/' print [#] function (int) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintInt FBCALL ( fnum as long, _val as long, mask as long )
    FB_PRINTNUM( fnum, _val, mask, "% ", "d" )
end sub

/':::::'/
sub fb_PrintUInt FBCALL ( fnum as long, _val as ulong, mask as long )
    FB_PRINTNUM( fnum, _val, mask, "%", "u" )
end sub
end extern