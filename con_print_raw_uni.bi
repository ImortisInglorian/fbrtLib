/' print raw data - no interpretation is done '/

extern "C"
sub FB_CONPRINTRAW_( handle as fb_ConHooks ptr, pachText as FB_TCHAR ptr, textLength as size_t )
    dim as fb_Rect ptr pBorder = @handle->Border
    dim as fb_Coord ptr pCoord = @handle->Coord

    while ( textLength <> 0 )
        dim as size_t remainingWidth = pBorder->Right - pCoord->X + 1
        dim as size_t copySize = iif(textLength > remainingWidth, remainingWidth, textLength)

        fb_hConCheckScroll( handle )

        if ( handle->FB_CON_HOOK_TWRITE( handle, cast(ubyte const ptr, pachText),copySize ) <> TRUE ) then
            exit while
		end if

        textLength -= copySize
        FB_TCHAR_ADVANCE( pachText, copySize )
        pCoord->X += copySize

        if ( pCoord->X = (pBorder->Right + 1) ) then
            pCoord->X = pBorder->Left
            pCoord->Y += 1
        end if
    wend
end sub
end extern
