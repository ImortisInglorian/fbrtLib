/' console line input function for wstrings '/

#include "fb.bi"

dim shared as ubyte ptr pszDefaultQuestion = sadd("? ")

extern "C"
#if defined( HOST_WIN32 ) or defined( HOST_DOS )

function fb_ConsoleLineInputWstr( text as FB_WCHAR const ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long
    dim as FBSTRING ptr tmp_result

    /' !!!FIXME!!! no support for unicode input '/

    FB_LOCK()

    fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )

    if ( text <> NULL ) then
        fb_PrintWstr( 0, text, 0 )

        if ( addquestion <> FB_FALSE ) then
            fb_PrintFixString( 0, pszDefaultQuestion, 0 )
		end if
    end if

    FB_UNLOCK()

    tmp_result = fb_ConReadLine( FALSE )

    if ( addnewline ) then
		fb_PrintVoid( 0, FB_PRINT_NEWLINE )
	end if

    if ( tmp_result = NULL ) then
    	return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
	end if

	fb_WstrAssignFromA( dst, max_chars, tmp_result, -1 )

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

#else

private function hWrapper( buffer as ubyte ptr, count as size_t, fp as FILE ptr ) as ubyte ptr
    return fb_ReadString( buffer, count, fp )
end function

function fb_ConsoleLineInputWstr( text as FB_WCHAR const ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long
	dim as size_t _len
	dim as res, old_x, old_y

    /' !!!FIXME!!! no support for unicode input '/

    fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )
    fb_GetXY( @old_x, @old_y )

	FB_LOCK()

    if ( text <> NULL ) then
		fb_PrintWstr( 0, text, 0 )

        if ( addquestion <> FB_FALSE ) then
            fb_PrintFixString( 0, pszDefaultQuestion, 0 )
		end if
    end if

    scope
        dim as FBSTRING str_result = ( 0, 0, 0 )

        res = fb_DevFileReadLineDumb( stdin, @str_result, hWrapper )

        _len = FB_STRSIZE(@str_result)

        if ( addnewline = 0 ) then
            dim as long cols, rows, old_y

            fb_GetSize( @cols, @rows )
            fb_GetXY( NULL, @old_y )

            old_x += _len - 1
            old_x mod= cols
            old_x += 1
            old_y -= 1

            fb_Locate( old_y, old_x, -1, 0, 0 )
        end if

        fb_WstrAssignFromA( dst, max_chars, cast(any ptr, @str_result), -1 )

        fb_StrDelete( @str_result )
    end scope

	FB_UNLOCK()

    return res
end function

#endif
end extern