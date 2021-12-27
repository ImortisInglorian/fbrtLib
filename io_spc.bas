/' spc and tab functions '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
sub fb_PrintTab FBCALL ( fnum as long, newcol as long )
    dim as FB_FILE ptr handle
    dim as long col, row, cols, rows

    fb_DevScrnInit_NoOpen( )

    FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)
    if (handle = NULL) then
        FB_UNLOCK()
        exit sub
    end if

	if ( FB_HANDLE_IS_SCREEN(handle) or handle->type = FB_FILE_TYPE_CONSOLE ) then
        if ( handle->type = FB_FILE_TYPE_CONSOLE ) then
            if( handle->hooks <> NULL andalso handle->hooks->pfnFlush <> NULL ) then
                handle->hooks->pfnFlush( handle )
			end if
        end if

        /' Ensure that we get the "real" cursor position - this quirk is
         * required for cursor positions at the right bottom of the screen '/
        fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )
		fb_GetXY( @col, @row )
		fb_GetSize( @cols, @rows )

    	if ( newcol > cols ) then
    		newcol mod= cols
		end if

        if ( col > newcol ) then
            fb_PrintVoidEx ( handle, FB_PRINT_NEWLINE )
			fb_Locate( 0, newcol, -1, 0, 0 )
        elseif ( newcol < 1 ) then
    		fb_Locate( 0, 1, -1, 0, 0 )
    	else
            fb_Locate( 0, newcol, -1, 0, 0 )
		end if
    else

        if ( handle->type = FB_FILE_TYPE_PIPE ) then
            fb_PrintPadEx ( handle, 0 )
        else
            dim as destructable_string tmp
            if ( (newcol >= 0) and (cast(ulong, newcol) > handle->line_length) ) then
                fb_PrintStringEx( handle, fb_StrFill1( newcol - handle->line_length - 1, asc(" "), @tmp ), 0 )
            else
                if ( handle->mode = FB_FILE_MODE_BINARY ) then
                    fb_PrintStringEx( handle, fb_StrAllocDescF( @FB_BINARY_NEWLINE, sizeof( FB_BINARY_NEWLINE ), @tmp ), 0 )
                else
                    fb_PrintStringEx( handle, fb_StrAllocDescF( @FB_NEWLINE, sizeof( FB_NEWLINE ), @tmp ), 0 )
                end if

                if ( newcol > 0 ) then
                    fb_PrintStringEx( handle, fb_StrFill1( newcol - 1, asc(" "), @tmp ), 0 )
                end if

            end if

        end if

    end if

    FB_UNLOCK()
end sub

sub fb_PrintSPC FBCALL ( fnum as long, n as ssize_t )
    dim as FB_FILE ptr handle
    dim as long col, row, cols, rows, newcol

    if ( n = 0 ) then
        exit sub
	end if

    fb_DevScrnInit_NoOpen( )

    FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)
    if ( handle = NULL ) then
        FB_UNLOCK()
        exit sub
    end if

	if ( FB_HANDLE_IS_SCREEN(handle) or handle->type = FB_FILE_TYPE_CONSOLE ) then
        if ( handle->type = FB_FILE_TYPE_CONSOLE ) then
            if ( handle->hooks <> NULL andalso handle->hooks->pfnFlush <> NULL ) then
                handle->hooks->pfnFlush( handle )
			end if
        end if

        /' Ensure that we get the "real" cursor position - this quirk is
         * required for cursor positions at the right bottom of the screen '/
        fb_PrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )
		fb_GetXY( @col, @row )
		fb_GetSize( @cols, @rows )

        /' Skip as many spaces as requested. We may even skip entire lines. '/
    	newcol = col + n
        while( newcol > cols )
            fb_PrintVoidEx ( handle, FB_PRINT_NEWLINE )
            newcol -= cols
        wend

        fb_Locate( 0, newcol, -1, 0, 0 )
    else
        dim as destructable_string tmp
        fb_PrintStringEx( handle, fb_StrFill1( n, asc(" "), @tmp ), 0 )
    end if

    FB_UNLOCK()
end sub
end extern