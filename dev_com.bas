/' COMx device '/

#include "fb.bi"
#include "dev_com_private.bi"

extern "C"
private function fb_DevComClose( handle as FB_FILE ptr ) as long
    dim as long res
    dim as DEV_COM_INFO ptr pInfo

    FB_LOCK()

    pInfo = cast(DEV_COM_INFO ptr, handle->opaque)
    res = fb_SerialClose( handle, pInfo->hSerial )
    if ( res = FB_RTERROR_OK ) then
        free(pInfo->pszDevice)
        free(pInfo)
    end if

    FB_UNLOCK()

	return res
end function

private function fb_DevComWrite( handle as FB_FILE ptr, value as any const ptr,  valuelen as size_t ) as long
    dim as long res
    dim as DEV_COM_INFO ptr pInfo

    FB_LOCK()

    pInfo = cast(DEV_COM_INFO ptr, handle->opaque)
    res = fb_SerialWrite( handle, pInfo->hSerial, value, valuelen )

    FB_UNLOCK()

	return res
end function

private function fb_DevComWriteWstr( handle as FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
	return fb_DevComWrite( handle, cast(any ptr, value), valuelen * sizeof( FB_WCHAR ) )
end function

private function fb_DevComRead( handle as FB_FILE ptr, value as any ptr, pValuelen as size_t ptr ) as long
    dim as long res
    dim as DEV_COM_INFO ptr pInfo

    FB_LOCK()

    pInfo = cast(DEV_COM_INFO ptr, handle->opaque)
    res = fb_SerialRead( handle, pInfo->hSerial, value, pValuelen )

    FB_UNLOCK()

	return res
end function

private function fb_DevComReadWstr( handle as FB_FILE ptr, value as FB_WCHAR ptr, pValuelen as size_t ptr ) as long
	dim as size_t _len = *pValuelen * sizeof( FB_WCHAR )
	return fb_DevComRead( handle, cast(any ptr, value), @_len )
end function

private function fb_DevComTell( handle as FB_FILE ptr, pOffset as fb_off_t ptr ) as long
    dim as long res
    dim as DEV_COM_INFO ptr pInfo

    DBG_ASSERT( pOffset <> NULL )

    FB_LOCK()

    pInfo = cast(DEV_COM_INFO ptr, handle->opaque)
    res = fb_SerialGetRemaining( handle, pInfo->hSerial, pOffset )

    FB_UNLOCK()

	return res
end function

private function fb_DevComEof( handle as FB_FILE ptr ) as long
    dim as long res
    dim as fb_off_t offset
    dim as DEV_COM_INFO ptr pInfo

    FB_LOCK()

    pInfo = cast(DEV_COM_INFO ptr, handle->opaque)
    res = fb_SerialGetRemaining( handle, pInfo->hSerial, @offset )
    if ( res <> FB_RTERROR_OK ) then
        res = FB_TRUE
    else
        res = (offset = 0)
    end if

    FB_UNLOCK()

	return res
end function

dim shared as FB_FILE_HOOKS hooks_dev_com = ( _
    @fb_DevComEof, _
    @fb_DevComClose, _
    NULL, _
    @fb_DevComTell, _
    @fb_DevComRead, _
    @fb_DevComReadWstr, _ ' Warning here
    @fb_DevComWrite, _
    @fb_DevComWriteWstr, _
    NULL, _
    NULL, _
    NULL, _
    NULL, _
    NULL, _
    NULL)

function fb_DevComOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
    dim as DEV_COM_INFO ptr info
    dim as ubyte ptr achDev(0 to 127)
    dim as ubyte ptr pchPos
    dim as ubyte ptr pchPosTmp
    dim as size_t i, port, uiOption
    dim as long iStopBits = -1
    dim as long res = FB_RTERROR_OK

    if (fb_DevComTestProtocolEx( handle, filename, filename_len, @port ) <> 0) then
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    if ( port > 0 ) then
    	i = sprintf( @achDev(0), sadd("COM%u:"), cast(long, port) )
    else
    	i = strchr( filename, 58 ) - cast(zstring ptr, filename)
    	strncpy( @achDev(0), filename, i )
    end if
    achDev(i) = 0

    FB_LOCK()

    if ( handle->mode = FB_FILE_MODE_RANDOM ) then
        handle->mode = FB_FILE_MODE_BINARY
        handle->access = FB_FILE_ACCESS_READWRITE
    end if

    /' Determine the port number and a normalized device name '/
    info = cast(DEV_COM_INFO ptr, calloc(1, sizeof(DEV_COM_INFO)))
    info->iPort = port
    info->pszDevice = strdup( @achDev(0) )

    /' Set defaults '/
    info->Options.uiSpeed = 300
    info->Options.Parity = FB_SERIAL_PARITY_EVEN
    info->Options.uiDataBits = 7
    info->Options.DurationCTS = 1000
    info->Options.DurationDSR = 1000

    pchPos = strchr( filename, asc(":") )
    DBG_ASSERT( pchPos <> NULL )
    pchPos += 1

    /' Process all passed options '/
    uiOption = 0
    while ( res = FB_RTERROR_OK and *pchPos <> 0 )
        dim as size_t uiOptionLength
        dim as ubyte ptr pchPosEnd, pchPosNext
        dim as ubyte ptr pszOption

        /' skip white spaces '/
        while ( *pchPos = asc(" ") or *pchPos = asc(!"\t") )
            pchPos += 1
		wend

        if ( *pchPos = 0 ) then
            exit while
		end if

        if ( *pchPos = asc(",") ) then
            /' empty option ... ignore '/
			uiOption += 1
            pchPos += 1
            continue while
        end if

        /' Find end of option '/
        pchPosNext = strchr( pchPos, asc(",") )
        if ( pchPosNext = NULL ) then
            pchPosNext = filename + filename_len
            pchPosEnd = pchPosNext - 1
        else
            pchPosEnd = pchPosNext - 1
            pchPosNext += 1
        end if

        /' skip white spaces '/
        while( *pchPosEnd = asc(" ") or *pchPosEnd = asc(!"\t") )
            pchPosEnd -= 1
		wend
        pchPosEnd += 1

        /' copy option to temporary buffer '/
        uiOptionLength = pchPosEnd - pchPos
        pszOption = malloc( uiOptionLength + 1 )
        memcpy( pszOption, pchPos, uiOptionLength )
        pszOption[uiOptionLength] = 0

        /' process option '/
        select case ( uiOption )
			case 0:
				/' baud rate '/
				info->Options.uiSpeed = strtoul( pszOption, @pchPosTmp, 10 )
				if ( *pchPosTmp <> 0 ) then
					res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
				end if

			case 1:
				/' parity '/
				if ( strcasecmp( pszOption, "N" ) = 0 ) then
					info->Options.Parity = FB_SERIAL_PARITY_NONE
				elseif ( strcasecmp( pszOption, "E" ) = 0 ) then
					info->Options.Parity = FB_SERIAL_PARITY_EVEN
				elseif ( strcasecmp( pszOption, "PE" ) = 0 ) then
					/' QB quirk '/
					info->Options.CheckParity = TRUE
					info->Options.Parity = FB_SERIAL_PARITY_EVEN
				elseif ( strcasecmp( pszOption, "O" )= 0 ) then
					info->Options.Parity = FB_SERIAL_PARITY_ODD
				elseif ( strcasecmp( pszOption, "S" ) = 0 ) then
					info->Options.Parity = FB_SERIAL_PARITY_SPACE
				elseif ( strcasecmp( pszOption, "M" ) = 0 ) then
					info->Options.Parity = FB_SERIAL_PARITY_MARK
				else
					res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
				end if

			case 2:
				/' data bits '/
				info->Options.uiDataBits = strtoul( pszOption, @pchPosTmp, 10 )
				if ( *pchPosTmp <> 0 ) then
					res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
				end if

			case 3:
				/' stop bits '/
				scope
					dim as double dblStopBits = strtod( pszOption, @pchPosTmp )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					else
						if ( dblStopBits = 1.0 ) then
							iStopBits = FB_SERIAL_STOP_BITS_1
						elseif ( dblStopBits = 1.5 ) then
							iStopBits = FB_SERIAL_STOP_BITS_1_5
						elseif ( dblStopBits = 2.0 ) then
							iStopBits = FB_SERIAL_STOP_BITS_2
						else
							res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
						end if
					end if
				end scope

			case else:
				/' extended options '/
				if ( strncasecmp( pszOption, "CS", 2 ) = 0 ) then
					info->Options.DurationCTS = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strncasecmp( pszOption, "DS", 2 ) = 0 ) then
					info->Options.DurationDSR = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strncasecmp( pszOption, "CD", 2 ) = 0 ) then
					info->Options.DurationCD = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strncasecmp( pszOption, "OP", 2 ) = 0 ) then
					info->Options.OpenTimeout = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strncasecmp( pszOption, "TB", 2 ) = 0 ) then
					info->Options.TransmitBuffer = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strncasecmp( pszOption, "RB", 2 ) = 0 ) then
					info->Options.ReceiveBuffer = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				elseif ( strcasecmp( pszOption, "RS" ) = 0 ) then
					info->Options.SuppressRTS = TRUE
				elseif ( strcasecmp( pszOption, "LF" ) = 0 ) then
					/' PB compatible '/
					info->Options.AddLF = TRUE
				elseif ( strcasecmp( pszOption, "ASC" ) = 0 ) then
					info->Options.AddLF = TRUE
				elseif ( strcasecmp( pszOption, "BIN" ) = 0 ) then
					info->Options.AddLF = FALSE
				elseif ( strcasecmp( pszOption, "PE" ) = 0 ) then
					info->Options.CheckParity = TRUE
				elseif ( strcasecmp( pszOption, "DT" ) = 0 ) then
					info->Options.KeepDTREnabled = TRUE
				elseif ( strcasecmp( pszOption, "FE" ) = 0 ) then
					info->Options.DiscardOnError = TRUE
				elseif ( strcasecmp( pszOption, "ME" ) = 0 ) then
					info->Options.IgnoreAllErrors = TRUE
				elseif ( strncasecmp( pszOption, "IR", 2 ) = 0 ) then
					info->Options.IRQNumber = strtoul( pszOption+2, @pchPosTmp, 10 )
					if ( *pchPosTmp <> 0 ) then
						res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
					end if
				else
					res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
				end if
        end select

        pchPos = pchPosNext
        free(pszOption)
        uiOption += 1
    wend

    /' QB quirk '/
    if ( iStopBits = -1 ) then
        if ( info->Options.uiSpeed <= 110 ) then
            if ( info->Options.uiDataBits = 5 ) then
                iStopBits = FB_SERIAL_STOP_BITS_1_5
            else
                iStopBits = FB_SERIAL_STOP_BITS_2
            end if
        else
            iStopBits = FB_SERIAL_STOP_BITS_1
        end if
    end if
    info->Options.StopBits = cast(FB_SERIAL_STOP_BITS, iStopBits)

    if ( res = FB_RTERROR_OK ) then
        handle->width = 0
        res = fb_SerialOpen( handle, info->iPort, @info->Options, info->pszDevice, @info->hSerial )
    end if

    if ( res = FB_RTERROR_OK ) then
        handle->hooks = @hooks_dev_com
        handle->opaque = info
		handle->type = FB_FILE_TYPE_SERIAL
    else
        if ( info->pszDevice ) then
            free( info->pszDevice )
		end if
        free(info)
    end if

    FB_UNLOCK()

	return res
end function

function fb_DevSerialSetWidth( pszDevice as ubyte const ptr, _width as long, default_width as long ) as long
    dim as long cur = iif((default_width = -1), 0, default_width)
    dim as size_t i, port
    dim as ubyte ptr achDev(0 to 127)

    if ( fb_DevComTestProtocolEx( NULL, pszDevice, strlen(pszDevice), @port ) <> 0 ) then
        return 0
	end if

    i = sprintf( @achDev(0), sadd("COM%u:"), cast(long, port) )
    achDev(i) = 0

    /' Test all printers. '/
    for i = 0 to FB_MAX_FILES - 1
        dim as FB_FILE ptr tmp_handle = @__fb_ctx.fileTB(0) + i
        if ( tmp_handle->hooks = @hooks_dev_com and tmp_handle->redirection_to = NULL ) then
            dim as DEV_COM_INFO ptr tmp_info = cast(DEV_COM_INFO ptr, tmp_handle->opaque)
            if ( strcmp(tmp_info->pszDevice, @achDev(0)) = 0 ) then
                if ( _width <> -1 ) then
                    tmp_handle->width = _width
				end if
                cur = tmp_handle->width
                exit for
            end if
        end if
    next

    return cur
end function
end extern
