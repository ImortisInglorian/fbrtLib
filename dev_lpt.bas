/' LPTx device '/

#include "fb.bi"

extern "C"
private function fb_DevLptFindDeviceByName( iPort as long, filename as ubyte ptr, no_redir as long ) as FB_FILE ptr
	dim as size_t i
	/' Test if the printer is already open. '/
	for i = 0 to FB_MAX_FILES
		dim as FB_FILE ptr handle = @__fb_ctx.fileTB(i)
		if ( handle->type = FB_FILE_TYPE_PRINTER ) then
			if( no_redir = FALSE or handle->redirection_to = NULL ) then
				dim as DEV_LPT_INFO ptr devInfo = cast(DEV_LPT_INFO ptr, handle->opaque)
				if ( devInfo <> 0 ) then
					if ( iPort = 0 or iPort = devInfo->iPort ) then
						if ( strcmp(devInfo->pszDevice, filename) = 0 ) then
								/' bugcheck '/
								DBG_ASSERT( handle <> FB_HANDLE_PRINTER and handle <> FB_HANDLE_PRINTER )
								return handle
						end if
					end if
				end if
			end if
		end if
	next
	return NULL
end function

private function fb_DevLptMakeDeviceName( lpt_proto as DEV_LPT_PROTOCOL ptr ) as ubyte ptr
	if ( lpt_proto <> 0 ) then
		dim as ubyte ptr p = calloc( strlen(lpt_proto->proto) + strlen(lpt_proto->name) + 3, 1 )
		strcpy( p, lpt_proto->proto )
		strcat( p, sadd(":") )
		strcat( p, lpt_proto->name )
		return p
	end if
	return NULL
end function

dim shared as FB_FILE_HOOKS hooks_dev_lpt = ( _
    NULL, _
    @fb_DevLptClose, _
    NULL, _
    NULL, _
    NULL, _
    NULL, _
    @fb_DevLptWrite, _
    @fb_DevLptWriteWstr, _
    NULL, _
    NULL, _
    NULL, _
    NULL, _
    NULL, _
    NULL)

/':::::'/
function fb_DevLptOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
	dim as DEV_LPT_PROTOCOL ptr lpt_proto
    dim as DEV_LPT_INFO ptr devInfo
    dim as FB_FILE ptr redir_handle = NULL
	dim as FB_FILE ptr tmp_handle = NULL
    dim as long res

    if (fb_DevLptParseProtocol( @lpt_proto, filename, filename_len , TRUE) = 0 ) then
		if ( lpt_proto <> 0 ) then
			free( lpt_proto )
		end if
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    FB_LOCK()

    /' Determine the port number and a normalized device name '/
    devInfo = cast(DEV_LPT_INFO ptr, calloc(1, sizeof(DEV_LPT_INFO)))
    devInfo->uiRefCount = 1
	devInfo->iPort = lpt_proto->iPort
	devInfo->pszDevice = fb_DevLptMakeDeviceName( lpt_proto )
	devInfo->driver_opaque = NULL

    /' Test if the printer is already open. '/
	tmp_handle = fb_DevLptFindDeviceByName( devInfo->iPort, devInfo->pszDevice, FALSE )
	if ( tmp_handle <> 0 ) then
		free(devInfo)
		redir_handle = tmp_handle
		devInfo = cast(DEV_LPT_INFO ptr, tmp_handle->opaque)
		devInfo->uiRefCount += 1
	end if

    /' Open the printer if not opened already '/
    if ( devInfo->driver_opaque = NULL ) then
        res = fb_PrinterOpen( devInfo, devInfo->iPort, filename )
    else
        res = fb_ErrorSetNum( FB_RTERROR_OK )
        if ( FB_HANDLE_USED(redir_handle) <> 0 ) then
            /' We only allow redirection between OPEN "LPT1:" and LPRINT '/
            if ( handle = @FB_HANDLE_PRINTER ) then
                redir_handle->redirection_to = handle
                handle->width = redir_handle->width
                handle->line_length = redir_handle->line_length
            else
                handle->redirection_to = redir_handle
            end if
        else
            handle->width = 80
        end if
    end if

    if ( res = FB_RTERROR_OK ) then
        handle->hooks = @hooks_dev_lpt
        handle->opaque = devInfo
		handle->type = FB_FILE_TYPE_PRINTER
    else
        if( devInfo->pszDevice ) then
            free( devInfo->pszDevice )
		end if
        free( devInfo )
    end if

	if ( lpt_proto <> 0 ) then
		free( lpt_proto )
	end if

    FB_UNLOCK()

	return res
end function

function fb_DevPrinterSetWidth( pszDevice as ubyte const ptr, _width as long, default_width as long ) as long
	dim as FB_FILE ptr tmp_handle = NULL
    dim as long cur = iif((default_width = -1), 80, default_width)
    dim as ubyte ptr pszDev
	dim as DEV_LPT_PROTOCOL ptr lpt_proto

    if (fb_DevLptParseProtocol( @lpt_proto, pszDevice, strlen(pszDevice), TRUE) = 0 ) then
		if ( lpt_proto ) then
			free( lpt_proto )
		end if
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	pszDev = fb_DevLptMakeDeviceName( lpt_proto )

    /' Test all printers. '/
	tmp_handle = fb_DevLptFindDeviceByName( lpt_proto->iPort, pszDev, TRUE )
	if ( tmp_handle <> 0 ) then
		if( _width <> -1 ) then
			tmp_handle->width = _width
		end if
		cur = tmp_handle->width
	end if

	if ( lpt_proto <> 0 ) then
		free( lpt_proto )
	end if	
    free(pszDev)

    return cur
end function

function fb_DevPrinterGetOffset( pszDevice as ubyte const ptr ) as long
	dim as FB_FILE ptr tmp_handle = NULL
    dim as long cur = 0
    dim as ubyte ptr pszDev
	dim as DEV_LPT_PROTOCOL ptr lpt_proto

    if ( fb_DevLptParseProtocol( @lpt_proto, pszDevice, strlen(pszDevice), TRUE) <> 0 ) then
		if ( lpt_proto <> 0 ) then
			free( lpt_proto )
		end if
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	pszDev = fb_DevLptMakeDeviceName( lpt_proto )

    /' Test all printers. '/
	tmp_handle = fb_DevLptFindDeviceByName( lpt_proto->iPort, pszDev, TRUE )
	if ( tmp_handle <> 0 ) then
		cur = tmp_handle->line_length
	end if
	
	if ( lpt_proto <> 0 ) then
		free( lpt_proto )
	end if

    free(pszDev)

    return cur
end function
end extern