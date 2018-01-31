/' console line input function '/

#include "fb.bi"

extern "C"
function fb_LineInputWstr FBCALL ( text as FB_WCHAR const ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long
    dim as FB_LINEINPUTWPROC fn

    FB_LOCK()
    fn = __fb_ctx.hooks.lineinputwproc
    FB_UNLOCK()

    if ( @fn <> NULL ) then
        return fn( text, dst, max_chars, addquestion, addnewline )
    else
        return fb_ConsoleLineInputWstr( text, dst, max_chars, addquestion, addnewline )
	end if
end function
end extern