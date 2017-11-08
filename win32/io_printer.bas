/' printer access for Windows '/

#include "../fb.bi"
#include "io_printer_private.bi"
#include "crt/ctype.bi"

type FnGetDefaultPrinter as function ( pszBuffer as LPTSTR, pcchBuffer as LPDWORD) as BOOL

/' Entry for the list of available printers '/
type DEV_PRINTER_DEVICE
    as FB_LISTELEM     elem
    as ubyte ptr       device
    as ubyte ptr       printer_name
end type

/' Information about a single printer emulation mode '/
type DEV_PRINTER_EMU_MODE
    as ubyte const ptr pszId
    as FnEmuPrint      pfnPrint
end type

declare sub EmuBuild_LOGFONT( lf as LOGFONT ptr, pInfo as W32_PRINTER_INFO ptr, uiCPI as ulong )
declare sub EmuUpdateInfo( pInfo as W32_PRINTER_INFO ptr )
declare sub EmuPrint_RAW( pInfo as W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long )
declare sub EmuPrint_TTY( pInfo as W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long )
#if 0
static
declare sub EmuPrint_ESC_P2( pInfo as W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long )
#endif

/' List of all known printer emulation modes '/
dim shared as DEV_PRINTER_EMU_MODE aEmulationModes(0 to 1) = { ( sadd("RAW"), @EmuPrint_RAW ), ( sadd("TTY"), @EmuPrint_TTY ) /', { sadd("ESC/P2"), EmuPrint_ESC_P2 } '/ } 

extern "C"
/'' Initialize the list of device info nodes.
 '/
private sub fb_hListDevInit( list as FB_LIST ptr )
    fb_hListDynInit( list )
end sub

/'' Allocate a new device info node.
 *
 * @return pointer to the new node
 '/

private function fb_hListDevElemAlloc ( list as FB_LIST ptr, device as ubyte const ptr, printer_name as ubyte const ptr ) as DEV_PRINTER_DEVICE ptr
    dim as DEV_PRINTER_DEVICE ptr node = cast(DEV_PRINTER_DEVICE ptr, calloc( 1, sizeof(DEV_PRINTER_DEVICE) ))
    node->device = strdup(device)
    node->printer_name = strdup(printer_name)
    fb_hListDynElemAdd( list, @node->elem )
    return node
end function

/'' Remove the device info node and release its memory.
 '/
private sub fb_hListDevElemFree  ( list as FB_LIST ptr, node as DEV_PRINTER_DEVICE ptr )
    fb_hListDynElemRemove( list, @node->elem )
    free(node->device)
    free(node->printer_name)
    free(node)
end sub

/'' Clear the list of device info nodes.
 '/
private sub fb_hListDevClear( list as FB_LIST ptr )
    while( list->head <> NULL )
        fb_hListDevElemFree( list, cast(DEV_PRINTER_DEVICE ptr, list->head) )
    wend
end sub

/'' Find the node containing the requested device.
 '/
private function fb_hListDevFindDevice( list as FB_LIST ptr, pszDevice as ubyte const ptr ) as DEV_PRINTER_DEVICE ptr
    dim as DEV_PRINTER_DEVICE ptr node = cast(DEV_PRINTER_DEVICE ptr, list->head)
    while (node <> NULL)
        if( strcasecmp( pszDevice, node->device ) = 0 ) then
            return node
		end if
		
		node = cast(DEV_PRINTER_DEVICE ptr, node->elem.next)
    wend
    return NULL
end function

/'' Find the node containing the requested printer name.
 '/
private function fb_hListDevFindName  ( list as FB_LIST ptr, pszPrinterName as ubyte const ptr ) as DEV_PRINTER_DEVICE ptr
    dim as DEV_PRINTER_DEVICE ptr node = cast(DEV_PRINTER_DEVICE ptr, list->head)
    while ( node <> NULL )
        if( strcasecmp( pszPrinterName, node->printer_name ) = 0 ) then 
            return node
		end if
		
		node = cast(DEV_PRINTER_DEVICE ptr, node->elem.next)
    wend
    return NULL
end function

private function GetDefaultPrinters( pCount as long ptr ) as PRINTER_INFO_5 ptr
    dim as DWORD dwNeeded = 0, dwReturned = 0
    dim as PRINTER_INFO_5 ptr result = NULL
    dim as DWORD dwFlags = PRINTER_ENUM_DEFAULT

    DBG_ASSERT(pCount <> NULL)

    *pCount = 0

    dim as BOOL fResult = EnumPrinters(dwFlags, NULL, 5, NULL, 0, @dwNeeded, @dwReturned)

    while ( not(fResult) )
        if (GetLastError() <> ERROR_INSUFFICIENT_BUFFER) then
            exit while
		end if

		dim as PRINTER_INFO_5 ptr oldResult = result
        result = cast(PRINTER_INFO_5 ptr, realloc( result, dwNeeded ))
        if ( result = NULL ) then
            free(oldResult)
            exit while
        end if

        fResult = EnumPrinters(dwFlags, NULL, 5, cast(byte ptr, result), dwNeeded, @dwNeeded, @dwReturned)
    wend

    *pCount = dwReturned

    return result
end function

private function GetPrinters( pCount as long ptr ) as PRINTER_INFO_2 ptr
    dim as DWORD dwNeeded = 0, dwReturned = 0
    dim as PRINTER_INFO_2 ptr result = NULL
    dim DWORD dwFlags = PRINTER_ENUM_LOCAL or PRINTER_ENUM_CONNECTIONS

    DBG_ASSERT(pCount <> NULL)

    *pCount = 0

    dim as BOOL fResult = EnumPrinters(dwFlags, NULL, 2, NULL, 0, @dwNeeded, @dwReturned)

    while ( not(fResult) )
        if (GetLastError() <> ERROR_INSUFFICIENT_BUFFER) then
            exit while
		end if

		dim as PRINTER_INFO_2 ptr oldResult = result
        result = cast(PRINTER_INFO_2 ptr, realloc( result, dwNeeded ))
        if ( result = NULL ) then
            free(oldResult)
            exit while
        end if

        fResult = EnumPrinters(dwFlags, NULL, 2, cast(BYTE ptr, result), dwNeeded, @dwNeeded, @dwReturned)
    wend

    *pCount = dwReturned

    return result
end function

private function GetDefaultPrinterName( ) as ubyte ptr
    dim as ubyte ptr result = NULL
    dim as long count
    dim as PRINTER_INFO_5 ptr printers = GetDefaultPrinters(@count)
    if ( count = 0 ) then
        dim as HMODULE hMod = LoadLibrary(TEXT("winspool.drv")) '?????????
        if (hMod <> NULL) then
#ifdef UNICODE
            dim as LPCTSTR pszPrinterId = TEXT("GetDefaultPrinterW")
#else
            dim as LPCTSTR pszPrinterId = TEXT("GetDefaultPrinterA")
#endif
            FnGetDefaultPrinter pfnGetDefaultPrinter = cast(FnGetDefaultPrinter, GetProcAddress(hMod, pszPrinterId))
            if (pfnGetDefaultPrinter <> NULL) then
                dim as TCHAR ptr buffer = NULL
                dim as DWORD dwSize = 0
                dim as BOOL fResult = pfnGetDefaultPrinter(NULL, @dwSize)
                while ( not(fResult) )
                    if (GetLastError() <> ERROR_INSUFFICIENT_BUFFER) then
                        exit while
					end if
                    
                    dim as TCHAR ptr oldBuffer = buffer
                    buffer = cast(TCHAR ptr, realloc(buffer, dwSize * sizeof(TCHAR)))
                    if (buffer = NULL) then
                        free(oldBuffer)
					end if
                    fResult = pfnGetDefaultPrinter(buffer, @dwSize)
                wend
				
                if ( dwSize > 1) then
                    result = buffer
                end if

            end if
            FreeLibrary(hMod) '???????
        end if
    else
        result = strdup(printers->pPrinterName)
    end if
    free(printers)
    return result
end function

private sub fb_hPrinterBuildListLocal( list as FB_LIST ptr)
    dim as long i, count
    dim as PRINTER_INFO_2 ptr printers = GetPrinters(@count)
    for i = 0 to count - 1
        dim as PRINTER_INFO_2 ptr printer = printers + i
        if( printer->pServerName = NULL ) then
            /' get the port from local printers only '/
            dim as LPTSTR pPortName = printer->pPortName
            dim as LPTSTR pFoundPos = strchr(pPortName, 44) ' ,
            while (pFoundPos)
                dim as DEV_PRINTER_DEVICE ptr node
                *pFoundPos = 0

                /' We only add printers to the list that are attached to
                 * an LPTx: port '/
                if ( strncasecmp( pPortName, sadd("LPT"), 3 ) = 0 ) then
                    node = fb_hListDevFindDevice( list, pPortName )
                    if ( node = NULL ) then
                        fb_hListDevElemAlloc ( list, pPortName, printer->pPrinterName )
                    end if
                end if

                pPortName = pFoundPos + 1
                while( isspace( *pPortName ) )
                    pPortName += 1
				wend
                pFoundPos = strchr(pPortName, 44) ' ,
            wend
            if ( strncasecmp( pPortName, (sadd"LPT"), 3 ) = 0 ) then
                dim as DEV_PRINTER_DEVICE ptr node = fb_hListDevFindDevice( list, pPortName )
                if ( node = NULL ) then
                    fb_hListDevElemAlloc ( list, pPortName, printer->pPrinterName )
                end if
            end if
        end if
    next
    free(printers)
end sub

private function fb_hPrinterBuildListDefault( list as FB_LIST ptr, iStartPort as long ) as long
    dim as ubyte Buffer(0 to 31)
    dim as long iPort = iStartPort - 1
    dim as ubyte ptr printer_name = GetDefaultPrinterName( )

    if ( printer_name <> NULL ) then
        if ( fb_hListDevFindName( list, printer_name ) = NULL ) then
            dim as DEV_PRINTER_DEVICE ptr node

            do
                iPort += 1
                sprintf( Buffer, "LPT%d", iPort )
                node = fb_hListDevFindDevice( list, Buffer )
            loop while( node <> NULL )

            fb_hListDevElemAlloc ( list, Buffer, printer_name )
        end if
        free( printer_name )
    end if

    return iPort + 1
end function

private function fb_hPrinterBuildListOther( list as FB_LIST ptr, iStartPort as long ) as long
    dim as ubyte Buffer(0 to 31)
    dim as long i, count, iPort = iStartPort - 1
    dim as PRINTER_INFO_2 ptr printers = GetPrinters(@count)

    for i = 0 to count - 1
        dim as PRINTER_INFO_2 ptr printer = printers + i
        if ( fb_hListDevFindName( list, printer->pPrinterName ) = NULL ) then
            dim as DEV_PRINTER_DEVICE ptr node
            do
                iPort += 1
                sprintf( Buffer, "LPT%d", iPort )
                node = fb_hListDevFindDevice( list, Buffer )
            loop while( node <> NULL )

            fb_hListDevElemAlloc ( list, Buffer, printer->pPrinterName )
        end if
    next
    free(printers)

    return iPort + 1
end function

private sub fb_hPrinterBuildList( list as FB_LIST ptr )
    fb_hPrinterBuildListLocal( list )

    /' The default printer should be mapped to LPT1: if no other local printer
     * is mapped to LPT1: '/
    fb_hPrinterBuildListDefault( list, 1 )

    /' Other printers that aren't local or attached to an LPTx: port
     * are mapped to LPT128: and above. '/
    fb_hPrinterBuildListOther( list, 128 )
end sub

function fb_PrinterOpen( devInfo as DEV_LPT_INFO ptr, iPort as long, pszDevice as ubyte const ptr ) as long
    dim as long result = fb_ErrorSetNum( FB_RTERROR_OK )
    dim as DEV_PRINTER_EMU_MODE ptr pFoundEmu = NULL
    dim as DWORD dwJob = 0
    dim as BOOL fResult
    dim as HANDLE hPrinter = NULL
    dim as HDC hDc = NULL

	dim as ubyte ptr printer_name = NULL
	dim as ubyte ptr doc_title = NULL

		dim as DEV_LPT_PROTOCOL ptr lpt_proto
		if ( not(fb_DevLptParseProtocol( @lpt_proto, pszDevice, strlen(pszDevice), TRUE )) ) then
			if ( lpt_proto <> NULL ) then
				free(lpt_proto)
			end if
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if

    /' Allow only valid emulation modes '/
    if ( *lpt_proto->emu <> 0 ) then
        dim as long i
        for i = 0 to sizeof(aEmulationModes)/sizeof(aEmulationModes(0)) - 1
            dim as DEV_PRINTER_EMU_MODE ptr pEmu = aEmulationModes + i
            if ( strcasecmp( lpt_proto->emu, pEmu->pszId ) = 0 ) then
                pFoundEmu = pEmu
                exit for
			end if
        next
        if ( not(pFoundEmu) ) then
			if ( lpt_proto <> NULL ) then
				free(lpt_proto)
			end if	
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
    end if

    if ( iPort = 0 ) then
      /' LPT:[PrinterName] '/
		if ( *lpt_proto->name ) then
			printer_name = strdup( lpt_proto->name )
		else
			printer_name = GetDefaultPrinterName()
		end if
	else
        /' LPTx: '/
        dim as FB_LIST dev_printer_devs
        dim as DEV_PRINTER_DEVICE ptr node;

        fb_hListDevInit( @dev_printer_devs )
        fb_hPrinterBuildList( @dev_printer_devs )

        /' Find printer attached to specified device '/
        node = fb_hListDevFindDevice( @dev_printer_devs, lpt_proto->proto )
        if ( node <> NULL ) then
            printer_name = strdup( node->printer_name )
        end if

        fb_hListDevClear( @dev_printer_devs )
    end if

    if ( printer_name = NULL ) then
        result = fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
    else
        if ( lpt_proto->emu <> 0 ) then
            /' When EMULATION is used, we have to use the DC instead of
             * the PRINTER directly '/
            hDc = CreateDCA( "WINSPOOL", printer_name, NULL, NULL )
            fResult = (hDc <> NULL)
        else
            /' User PRINTER directly '/
            fResult = OpenPrinter(printer_name, @hPrinter, NULL)
        end if
        if ( not(fResult) ) then
            result = fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
        end if
    end if

    if ( lpt_proto->title and *lpt_proto->title ) then
		doc_title = strdup( lpt_proto->title )
	else
		doc_title = strdup( "FreeBASIC document" )
	end if

    if ( result <> FB_RTERROR_OK ) then
        if ( *lpt_proto->emu <> 0 ) then
            dim as long iJob
            dim as DOCINFO docInfo
            memset( @docInfo, 0, sizeof(DOCINFO) )
            docInfo.cbSize = sizeof(DOCINFO)
            docInfo.lpszDocName = doc_title
            iJob = StartDoc( hDc, @docInfo )
            if ( iJob <= 0 ) then
                result = fb_ErrorSetNum( FB_RTERROR_FILEIO )
            else
                dwJob = cast(DWORD, iJob)
            end if
        else
            dim as DOC_INFO_1 DocInfo
            DocInfo.pDocName = doc_title
            DocInfo.pOutputFile = NULL
            DocInfo.pDatatype = TEXT("RAW")

            dwJob = StartDocPrinter( hPrinter, 1, cast(BYTE ptr, @DocInfo) )
            if ( dwJob = 0 ) then
                result = fb_ErrorSetNum( FB_RTERROR_FILEIO )
            end if
        end if
    end if

    if ( result = FB_RTERROR_OK ) then
        dim as W32_PRINTER_INFO ptr pInfo = calloc( 1, sizeof(W32_PRINTER_INFO) )
        if ( pInfo = NULL ) then
            result = fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
        else
            devInfo->driver_opaque = pInfo
            pInfo->hPrinter = hPrinter
            pInfo->dwJob = dwJob
            pInfo->hDc = hDc
            if ( hDc <> NULL ) then
                dim as LOGFONT lf

                pInfo->Emu.dwFullSizeX = GetDeviceCaps( hDc, PHYSICALWIDTH )
                pInfo->Emu.dwFullSizeY = GetDeviceCaps( hDc, PHYSICALHEIGHT )
                pInfo->Emu.dwSizeX = GetDeviceCaps( hDc, HORZRES )
                pInfo->Emu.dwSizeY = GetDeviceCaps( hDc, VERTRES )
                pInfo->Emu.dwOffsetX = GetDeviceCaps( hDc, PHYSICALOFFSETX )
                pInfo->Emu.dwOffsetY = GetDeviceCaps( hDc, PHYSICALOFFSETY )
                pInfo->Emu.dwDPI_X = GetDeviceCaps( hDc, LOGPIXELSX )
                pInfo->Emu.dwDPI_Y = GetDeviceCaps( hDc, LOGPIXELSY )
#if 0
                pInfo->Emu.dwCurrentX = pInfo->Emu.dwOffsetX
                pInfo->Emu.dwCurrentY = pInfo->Emu.dwOffsetY
#else
                pInfo->Emu.dwCurrentX = 0
                pInfo->Emu.dwCurrentY = 0
#endif
                pInfo->Emu.clFore = RGB(0,0,0)
                pInfo->Emu.clBack = RGB(255,255,255)

                /' Start in 12 CPI monospace mode '/
                EmuBuild_LOGFONT( @lf, pInfo, 12 )

                /' Should never fail - except when some default fonts were
                 * removed by hand (which is very unlikely) '/
                pInfo->Emu.hFont = CreateFontIndirect( @lf )
                DBG_ASSERT( pInfo->Emu.hFont <> NULL )

                /' Register PRINT function '/
                pInfo->Emu.pfnPrint = pFoundEmu->pfnPrint

                /' Should not be necessary because this is the default '/
                SetTextAlign( hDc, TA_TOP or TA_LEFT or TA_NOUPDATECP )

                EmuUpdateInfo( pInfo )
            end if
        end if
    end if

    if ( result <> FB_RTERROR_OK ) then
        if ( dwJob <> 0 ) then
            if ( *lpt_proto->emu <> 0 ) then
                EndDoc( hDc )
            else
                EndDocPrinter( hPrinter )
            end if
        end if
        if ( hPrinter <> NULL ) then
            ClosePrinter( hPrinter )
        end if
        if ( hDc <> NULL ) then
            DeleteDC( hDc )
        end if
    end if

    if ( printer_name <> NULL ) then
        free( printer_name )
	end if
    if ( doc_title <> NULL ) then
        free( doc_title )
		if ( lpt_proto <> NULL ) then
			free(lpt_proto)
		end if
	end if
    return result
end function

private sub EmuBuild_LOGFONT( lf as LOGFONT ptr, pInfo as W32_PRINTER_INFO ptr, uiCPI as ulong )
    memset( lf, 0, sizeof( LOGFONT ) )
    lf->lfHeight = pInfo->Emu.dwDPI_Y * 10 / 72         /' default height '/
    lf->lfWeight = FW_NORMAL
    lf->lfCharSet = OEM_CHARSET
    lf->lfOutPrecision = OUT_DEFAULT_PRECIS
    lf->lfClipPrecision = CLIP_DEFAULT_PRECIS
    lf->lfQuality = DRAFT_QUALITY
    if ( uiCPI <> 0 ) then
        lf->lfWidth = pInfo->Emu.dwDPI_X / uiCPI
        lf->lfPitchAndFamily = FIXED_PITCH or FF_MODERN
        strcpy( lf->lfFaceName, "System" )
    else
        lf->lfWidth = 0
        lf->lfPitchAndFamily = VARIABLE_PITCH or FF_SWISS
        strcpy( lf->lfFaceName, "MS Sans Serif" )
    end if
end sub

private sub EmuUpdateInfo( pInfo as W32_PRINTER_INFO ptr )
    dim as TEXTMETRIC tm

    SelectObject( pInfo->hDc, pInfo->Emu.hFont )

    GetTextMetrics( pInfo->hDc, @tm )
    pInfo->Emu.dwFontSizeX = tm.tmMaxCharWidth
    pInfo->Emu.dwFontSizeY = tm.tmHeight
end sub

private sub EmuPageStart( pInfo as W32_PRINTER_INFO ptr )
    if ( pInfo->Emu.iPageStarted ) then
        exit sub
	end sub

    StartPage( pInfo->hDc )
    pInfo->Emu.iPageStarted = TRUE

    EmuUpdateInfo( pInfo )

    SetTextColor( pInfo->hDc, pInfo->Emu.clFore )
    SetBkColor( pInfo->hDc, pInfo->Emu.clBack )
end sub

private sub EmuPrint_RAW( pInfo as W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long )
    while( uiLength )
		if ( not(isunicode) ) then
			dim as ubyte ptr ch = cast(ubyte ptr, pText)
			pText += sizeof(char)

			EmuPageStart( pInfo )
			TextOut( pInfo->hDc, pInfo->Emu.dwCurrentX, pInfo->Emu.dwCurrentY, @ch, 1 )
		else
			dim as FB_WCHAR ch = *cast(FB_WCHAR ptr, pText)
			pText += sizeof(FB_WCHAR)
			
			EmuPageStart( pInfo )
			TextOutW( pInfo->hDc, pInfo->Emu.dwCurrentX, pInfo->Emu.dwCurrentY, @ch, 1 )
		end if

        pInfo->Emu.dwCurrentX += pInfo->Emu.dwFontSizeX

        if ( pInfo->Emu.dwCurrentX>=pInfo->Emu.dwSizeX ) then
            pInfo->Emu.dwCurrentX = 0
            pInfo->Emu.dwCurrentY += pInfo->Emu.dwFontSizeY
            if ( pInfo->Emu.dwCurrentY>=pInfo->Emu.dwSizeY ) then
                pInfo->Emu.dwCurrentY = 0
                EndPage( pInfo->hDc )
                pInfo->Emu.iPageStarted = FALSE
            end if
        end if
		uiLength -= 1
    wend
end sub

private sub fb_hHookConPrinterScroll( handle as _fb_ConHooks ptr, x1 as long, y1 as long, x2 as long, y2 as long, rows as long)
    dim as W32_PRINTER_INFO ptr pInfo = handle->Opaque
    dim as long page_rows = (pInfo->Emu.dwSizeY + pInfo->Emu.dwFontSizeY - 1) / pInfo->Emu.dwFontSizeY
    if ( not(pInfo->Emu.iPageStarted) ) then
        StartPage( pInfo->hDc )
    end if
    EndPage( pInfo->hDc )
    while( rows >= page_rows ) 
        StartPage( pInfo->hDc )
        EndPage( pInfo->hDc )
        rows -= page_rows
    wend
    pInfo->Emu.iPageStarted = FALSE
    if ( rows <> 0 ) then
        rows -= 1
	end if
    handle->Coord.Y = rows
end sub

private function fb_hHookConPrinterWrite ( handle as _fb_ConHooks ptr, buffer as any const ptr, length as size_t ) as long
    dim as W32_PRINTER_INFO ptr pInfo = handle->Opaque
    pInfo->Emu.dwCurrentX = handle->Coord.X * pInfo->Emu.dwFontSizeX
    pInfo->Emu.dwCurrentY = handle->Coord.Y * pInfo->Emu.dwFontSizeY
    EmuPrint_RAW( pInfo, buffer, length, FALSE )
    return TRUE
end function

private function fb_hHookConPrinterWriteWstr ( handle as _fb_ConHooks ptr, buffer as any const ptr, length as size_t ) as long
    dim as W32_PRINTER_INFO ptr pInfo = handle->Opaque
    pInfo->Emu.dwCurrentX = handle->Coord.X * pInfo->Emu.dwFontSizeX
    pInfo->Emu.dwCurrentY = handle->Coord.Y * pInfo->Emu.dwFontSizeY
    EmuPrint_RAW( pInfo, buffer, length, TRUE )
    return TRUE
end function

private subs EmuPrint_TTY( pInfo as W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long )
    dim as fb_ConHooks hooks

    hooks.Opaque        = pInfo
    hooks.Scroll        = fb_hHookConPrinterScroll
    hooks.Write         = iif(isunicode, fb_hHookConPrinterWriteWstr, fb_hHookConPrinterWrite)
    hooks.Border.Left   = 0
    hooks.Border.Top    = 0
    hooks.Border.Right  = ( pInfo->Emu.dwSizeX - pInfo->Emu.dwFontSizeX + 1 ) / pInfo->Emu.dwFontSizeX
    hooks.Border.Bottom = ( pInfo->Emu.dwSizeY - pInfo->Emu.dwFontSizeX + 1 ) / pInfo->Emu.dwFontSizeY

    hooks.Coord.X = pInfo->Emu.dwCurrentX / pInfo->Emu.dwFontSizeX
    hooks.Coord.Y = pInfo->Emu.dwCurrentY / pInfo->Emu.dwFontSizeY

		if ( not(isunicode) ) then
			while( uiLength <> 0 )
				dim as ubyte ptr chControl = 0
				dim as ulong uiLengthTTY = uiLength, ui
				/' Check for additional control characters '/
				for ui = 0 uiLength - 1
					dim as long iFound = FALSE
					dim as char ch = (cast(ubyte ptr, pText))[ui]
					select case ch
						case 12:
							/' FormFeed '/
							iFound = TRUE
					end select
					if ( iFound ) then
						chControl = ch
						uiLengthTTY = ui
						exit for
					end if
				next
				fb_ConPrintTTY( @hooks, cast(ubyte ptr, pText), uiLengthTTY, TRUE )
				if( uiLength <> uiLengthTTY ) then
					/' Found a control character that's not handled by the TTY output
					 * routines '/
					uiLengthTTY += 1
					select case chControl
						case 12:
							/' FormFeed '/
							fb_hHookConPrinterScroll( @hooks, 0, 0, 0, 0, 0 )
					exit select
					
				end if
				pText += uiLengthTTY * sizeof(char)
				uiLength -= uiLengthTTY
			wend
		else
			while( uiLength <> 0 )
					dim as ubyte ptr chControl = 0
					dim as ulong uiLengthTTY = uiLength, ui
					/' Check for additional control characters '/
					for ui = 0 uiLength - 1
						dim as long iFound = FALSE
						dim as ubyte ptr ch = (cast(FB_WCHAR ptr, pText))[ui]
						select case ch
							case 12:
								/' FormFeed '/
								iFound = TRUE
						end select
						if ( iFound ) then
							chControl = ch
							uiLengthTTY = ui
							exit for
						end if
					next
					fb_ConPrintTTYWstr( @hooks, cast(FB_WCHAR ptr, pText), uiLengthTTY, TRUE )
					if ( uiLength <> uiLengthTTY ) then
						/' Found a control character that's not handled by the TTY output
						 * routines '/
						uiLengthTTY += 1
						select case chControl
							case 12:
								/' FormFeed '/
								fb_hHookConPrinterScroll( @hooks, 0, 0, 0, 0, 0 )
						end select
					end if
					pText += uiLengthTTY * sizeof(FB_WCHAR)
					uiLength -= uiLengthTTY
			wend
		end if

    if ( hooks.Coord.X <> hooks.Border.Left or hooks.Coord.Y <> (hooks.Border.Bottom+1) ) then
        fb_hConCheckScroll( @hooks )
    end if

    pInfo->Emu.dwCurrentX = hooks.Coord.X * pInfo->Emu.dwFontSizeX
    pInfo->Emu.dwCurrentY = hooks.Coord.Y * pInfo->Emu.dwFontSizeY
end function

#if 0
private sub EmuPrint_ESC_P2( devInfo as DEV_LPT_INFO ptr, pachText as ubyte const ptr, uiLength as size_t )
		dim as W32_PRINTER_INFO ptr pInfo = cast(W32_PRINTER_INFO ptr, devInfo->driver_opaque)
end sub
#endif

function fb_PrinterWrite( devInfo as DEV_LPT_INFO ptr, _data as any const ptr, length as size_t ) as long
	dim as W32_PRINTER_INFO ptr pInfo = cast(W32_PRINTER_INFO ptr, devInfo->driver_opaque)
    dim as DWORD dwWritten

    if ( not(pInfo->hPrinter) ) then
        pInfo->Emu.pfnPrint( pInfo, _data, length, FALSE )
	elseif( !WritePrinter( pInfo->hPrinter, cast(LPVOID, _data), length, @dwWritten ) ) then
        return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	elseif ( dwWritten <> length ) then
        return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_PrinterWriteWstr( devInfo as DEV_LPT_INFO ptr, _data as FB_WCHAR const ptr, length as size_t ) as long
	dim as W32_PRINTER_INFO ptr pInfo = cast(W32_PRINTER_INFO ptr, devInfo->driver_opaque)
    dim as DWORD dwWritten

    if ( not(pInfo->hPrinter) ) then
        pInfo->Emu.pfnPrint( pInfo, _data, length, TRUE)
    elseif ( not(WritePrinter( pInfo->hPrinter, cast(LPVOID, _data), length * sizeof( FB_WCHAR ), @dwWritten )) ) then
        return fb_ErrorSetNum( FB_RTERROR_FILEIO )
    elseif ( dwWritten <> length * sizeof( FB_WCHAR )) then
        return fb_ErrorSetNum( FB_RTERROR_FILEIO )
    end if

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_PrinterClose( devInfo as DEV_LPT_INFO ptr ) as long
	dim as W32_PRINTER_INFO ptr pInfo = cast(W32_PRINTER_INFO ptr, devInfo->driver_opaque)

    if ( pInfo->hDc <> NULL ) then
        if ( pInfo->Emu.iPageStarted ) then
            EndPage( pInfo->hDc )
		end if
        EndDoc( pInfo->hDc )
        DeleteDC( pInfo->hDc )
    else
        EndDocPrinter( pInfo->hPrinter )
        ClosePrinter( pInfo->hPrinter )
    end if

	if ( devInfo->driver_opaque ) then
	    free(devInfo->driver_opaque)
	end if
		
	devInfo->driver_opaque = NULL

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern