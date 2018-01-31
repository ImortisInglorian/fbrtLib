#include "fb.bi"

extern "C"
function fb_Exec FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as long
    return fb_ExecEx( program, args, TRUE )
end function
end extern