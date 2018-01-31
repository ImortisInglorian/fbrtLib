/' chain function '/

#include "fb.bi"

extern "C"
function fb_Chain FBCALL ( program as FBSTRING ptr ) as long
    return fb_ExecEx( program, NULL, TRUE )
end function
end extern