/' write [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteInt FBCALL ( fnum as long, _val as long, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%d" )
end sub

/':::::'/
sub fb_WriteUInt FBCALL ( fnum as long, _val as ulong, mask as long )
    FB_WRITENUM( fnum, _val, mask, "%u" )
end sub
end extern