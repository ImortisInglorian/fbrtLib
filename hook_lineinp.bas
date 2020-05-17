/' console line input function '/

#include "fb.bi"

extern "C"
function fb_LineInput FBCALL ( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
    dim as FB_LINEINPUTPROC lineinputproc

    FB_LOCK()
    lineinputproc = __fb_ctx.hooks.lineinputproc
    FB_UNLOCK()

    if ( lineinputproc <> NULL ) then
        return lineinputproc( text, dst, dst_len, fillrem, addquestion, addnewline )
    else
        return fb_ConsoleLineInput( text, dst, dst_len, fillrem, addquestion, addnewline )
	end if
end function
end extern