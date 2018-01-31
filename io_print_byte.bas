/' print [#] function (byte) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintByte FBCALL ( fnum as long, _val as ubyte, mask as long )
    FB_PRINTNUM( fnum, cast(long, _val), mask, "% ", "d" )
end sub

/':::::'/
sub fb_PrintUByte FBCALL ( fnum as long, _val as ubyte, mask as long )
    FB_PRINTNUM( fnum, cast(ulong, _val), mask, "%", "u" )
end sub
end extern