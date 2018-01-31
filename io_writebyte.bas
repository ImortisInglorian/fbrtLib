/' write [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteByte FBCALL ( fnum as long, _val as ubyte, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%d" )
end sub

/':::::'/
sub fb_WriteUByte FBCALL ( fnum as long, _val as ubyte , mask as long )
    FB_WRITENUM( fnum, _val, mask, "%u" )
end sub
end extern