/' print [#] function (short) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintShort FBCALL ( fnum as long, _val as short, mask as long )
    FB_PRINTNUM( fnum, _val, mask, "% ", "hd" )
end sub

/':::::'/
sub fb_PrintUShort FBCALL ( fnum as long, _val as ushort, mask as long )
    FB_PRINTNUM( fnum, _val, mask, "%", "hu" )
end sub
end extern