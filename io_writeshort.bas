/' write [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteShort FBCALL ( fnum as long, _val as short, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%hd" )
end sub

/':::::'/
sub fb_WriteUShort FBCALL ( fnum as long, _val as ushort, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%hu" )
end sub
end extern