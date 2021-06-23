/' print text data - using TTY (teletype) interpretation '/

#ifndef OUTPUT_BUFFER_SIZE
#define OUTPUT_BUFFER_SIZE 1024
#endif

extern "C"
sub FB_CONPRINTTTY_( handle as fb_ConHooks ptr, pachText as FB_TCHAR ptr, TextLength as size_t, is_text_mode as long )
	static as FB_TCHAR achTabSpaces(0 to 7) = { 32, 32, 32, 32, 32, 32, 32, 32 }
	dim as FB_TCHAR OutputBuffer(0 to OUTPUT_BUFFER_SIZE - 1)
	dim as size_t OutputBufferLength = 0, OutputBufferChars = 0
	dim as fb_Rect ptr pBorder = @handle->Border
	dim as fb_Coord ptr pCoord = @handle->Coord

	dim as fb_Coord dwCurrentCoord
	dim as size_t IndexText
	dim as long fGotNewCoordinate = FALSE
	dim as long BorderWidth = pBorder->Right - pBorder->Left + 1

	/' Do nothing (and prevent division by zero below) if width == 0.
       (can happen with tiny gfxlib2 screens at least) '/
    if ( BorderWidth = 0 ) then
        exit sub
    end if

    memcpy( @dwCurrentCoord, pCoord, sizeof( fb_Coord ) )

    dim as fb_Coord dwMoveCoord = ( 0, 0 )
    for IndexText = 0 to TextLength - 1
        dim as FB_TCHAR ptr pachOutputData = pachText
        dim as size_t OutputDataLength = 0, OutputDataChars = 0
        dim as long fDoFlush = FALSE
        dim as long fSetNewCoord = FALSE
        dim as FB_TCHAR ch = FB_TCHAR_GET( pachOutputData )

        select case ( ch )
			case 7:
				/' ALARM '/
				fb_Beep()

			case 8:
				/' BACKSPACE '/
				fSetNewCoord = TRUE
				if ( dwCurrentCoord.X > pBorder->Left ) then
					dwMoveCoord.X = -1
				else
					dwMoveCoord.X = 0
				end if
				dwMoveCoord.Y = 0

			case asc(!"\n"):
				/' LINE FEED / NEW LINE '/
				fSetNewCoord = TRUE
				if ( is_text_mode <> 0 ) then
					dwMoveCoord.X = pBorder->Left - dwCurrentCoord.X
					dwMoveCoord.Y = 1
				else
					dwMoveCoord.X = 0
					dwMoveCoord.Y = 1
				end if

			case asc(!"\r"):
				/' CARRIAGE RETURN '/
				fSetNewCoord = TRUE
				dwMoveCoord.X = pBorder->Left - dwCurrentCoord.X
				dwMoveCoord.Y = 0

			case asc(!"\t"):
				/' TAB '/
				pachOutputData = @achTabSpaces(0)
				OutputDataChars = ((dwCurrentCoord.X - pBorder->Left + 8) and not(7)) - (dwCurrentCoord.X - pBorder->Left)
				OutputDataLength = OutputDataChars

			case else:
				OutputDataLength = FB_TCHAR_GET_CHAR_SIZE( pachOutputData )
				OutputDataChars = 1
        end select

        if ( OutputDataLength + OutputBufferLength > OUTPUT_BUFFER_SIZE ) then
            fDoFlush = TRUE
        elseif ( fSetNewCoord <> 0 ) then
            fDoFlush = TRUE
        end if

        if ( fDoFlush <> NULL ) then
            fDoFlush = FALSE
            if ( OutputBufferLength <> 0 ) then
                FB_CONPRINTRAW_( handle, @OutputBuffer(0), OutputBufferChars )
                OutputBufferLength = OutputBufferChars = 0
                fGotNewCoordinate = FALSE
            end if
        end if

        if ( fSetNewCoord <> 0 ) then
            fSetNewCoord = FALSE
            pCoord->X += dwMoveCoord.X
            pCoord->Y += dwMoveCoord.Y
            memcpy( @dwCurrentCoord, pCoord, sizeof( fb_Coord ) )
            fGotNewCoordinate = TRUE
        end if

        if ( OutputDataLength <> 0 ) then
            dwCurrentCoord.X += OutputDataChars
            if ( dwCurrentCoord.X > pBorder->Right ) then
                dim as long NormalX = dwCurrentCoord.X - pBorder->Left
                dwCurrentCoord.X = (NormalX mod BorderWidth) + pBorder->Left
                dwCurrentCoord.Y += NormalX / BorderWidth
            end if
            while ( OutputDataLength <> 0 ) 
                OutputBuffer(OutputBufferLength) = *pachOutputData
				OutputBufferLength += 1
				pachOutputData += 1
				OutputDataLength -= 1
            wend
            OutputBufferChars += OutputDataChars
        end if

        FB_TCHAR_ADVANCE( pachText, 1 )
    next

    if ( OutputBufferLength <> 0 ) then
        FB_CONPRINTRAW_( handle, @OutputBuffer(0), OutputBufferChars )
    elseif ( fGotNewCoordinate <> NULL ) then
        fb_hConCheckScroll( handle )
    end if
end sub
end extern