/' console line input function '/

#include "fb.bi"

dim shared as ZString Ptr pszDefaultQuestion = sadd("? ")

extern "C"
#if defined( HOST_WIN32 ) or defined( HOST_DOS ) or defined( HOST_LINUX )

function fb_ConsoleLineInput( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
    dim as FBSTRING ptr tmp_result

    FB_LOCK()

    fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )

    if ( text <> NULL ) then
        if ( text->data <> NULL ) then
            fb_PrintString( 0, text, 0 )
    	end if

        if ( addquestion <> FB_FALSE ) then
            fb_PrintFixString( 0, pszDefaultQuestion, 0 )
        end if
    end if

    FB_UNLOCK()

    tmp_result = fb_ConReadLine( FALSE )

    if ( addnewline <> NULL ) then
		fb_PrintVoid( 0, FB_PRINT_NEWLINE )
    end if

    if ( tmp_result <> NULL ) then
        fb_StrAssign( dst, dst_len, tmp_result, -1, fillrem )
        return fb_ErrorSetNum( FB_RTERROR_OK )
    end if

    return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
end function

#else

private function hWrapper( buffer as ubyte ptr, count as size_t, fp as FILE ptr ) as ubyte ptr
    return fb_ReadString( buffer, count, fp )
end function

function fb_ConsoleLineInput( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
	dim as long res, old_x, old_y
	dim as size_t _len

    fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )
    fb_GetXY( @old_x, @old_y )

	FB_LOCK()

    if ( text <> NULL ) then
        if( text->data <> NULL ) then
            fb_PrintString( 0, text, 0 )
    	end if

        if ( addquestion <> FB_FALSE ) then
            fb_PrintFixString( 0, pszDefaultQuestion, 0 )
        end if
    end if

    scope
        /' create temporary string '/
        dim as FBSTRING str_result = ( 0 )

        res = fb_DevFileReadLineDumb( stdin, @str_result, hWrapper )

        _len = FB_STRSIZE(@str_result)

        /' We have to handle the NEWLINE stuff here because we *REQUIRE*
         * the *COMPLETE* temporary input string for the correct position
         * adjustment. '/
        if ( addnewline = 0 ) then
            /' This is the easy and dumb method to do the position adjustment.
             * The problem is that it doesn't take TAB's into account. '/
            dim as long cols, rows, old_y

            fb_GetSize( @cols, @rows )
            fb_GetXY( NULL, &old_y )

            old_x += _len - 1
            old_x mod= cols
            old_x += 1
            old_y -= 1

            fb_Locate( old_y, old_x, -1, 0, 0 )
        end if


        /' add contents of tempporary string to result buffer '/
        fb_StrAssign( dst, dst_len, cast(any ptr, @str_result), -1, fillrem )

        fb_StrDelete( @str_result )
    end scope

	FB_UNLOCK()

    return res
end function

#endif
end extern