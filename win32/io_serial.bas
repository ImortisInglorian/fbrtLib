/' serial port access for Windows '/

#include "../fb.bi"
#include "../io_serial_private.bi"

#define GET_MSEC_TIME() (cast(DWORD, (fb_Timer() * 1000.0)))

extern "C"
private function fb_hSerialWaitSignal( hDevice as HANDLE, dwMask as DWORD, dwResult as DWORD, dwTimeout as DWORD ) as long
	dim as DWORD dwStartTime = GET_MSEC_TIME()
	dim as DWORD dwModemStatus = 0

	if ( GetCommModemStatus( hDevice, @dwModemStatus ) = NULL ) then
		return FALSE
	end if

	while ( ((GET_MSEC_TIME() - dwStartTime) <= dwTimeout) and ((dwModemStatus and dwMask) <> dwResult) )
		if( GetCommModemStatus( hDevice, @dwModemStatus ) = NULL ) then
			return FALSE
		end if
	wend
	return ((dwModemStatus and dwMask) = dwResult)
end function

private function fb_hSerialCheckLines( hDevice as HANDLE, pOptions as FB_SERIAL_OPTIONS ptr ) as long
	DBG_ASSERT( pOptions <> NULL )
	if ( pOptions->DurationCD <> 0 ) then
		if ( not(fb_hSerialWaitSignal( hDevice, MS_RLSD_ON, MS_RLSD_ON, pOptions->DurationCD )) ) then
			return FALSE
		end if
	end if

	if ( pOptions->DurationDSR <> 0 ) then
		if ( not(fb_hSerialWaitSignal( hDevice, MS_DSR_ON, MS_DSR_ON, pOptions->DurationDSR )) ) then
			return FALSE
		end if
	end if
	return TRUE
end function

function fb_SerialOpen( handle as FB_FILE ptr, iPort as long, options as FB_SERIAL_OPTIONS ptr, pszDevice as ubyte ptr, ppvHandle as any ptr ptr ) as long
	dim as DWORD dwDefaultTxBufferSize = 16384
	dim as DWORD dwDefaultRxBufferSize = 16384
	dim as DWORD dwDesiredAccess = 0
	dim as ubyte ptr pszDev, p
	dim as HANDLE hDevice
	dim as long res

	/' The IRQ stuff is not supported on Windows ... '/
	if ( options->IRQNumber <> 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	res = fb_ErrorSetNum( FB_RTERROR_OK )

	select case handle->access
		case FB_FILE_ACCESS_READ:
			dwDesiredAccess = GENERIC_READ
		case FB_FILE_ACCESS_WRITE:
			dwDesiredAccess = GENERIC_WRITE
		case FB_FILE_ACCESS_READWRITE, FB_FILE_ACCESS_ANY:
			dwDesiredAccess = GENERIC_READ or GENERIC_WRITE
	end select

	/' Get device name without ":" '/
	pszDev = calloc(strlen( pszDevice ) + 5, 1)
	if ( iPort = 0 ) then
		iPort = 1
		strcpy( pszDev, "COM1:" )
	else
		if ( iPort > 9 ) then
			strcpy(pszDev, "\\.\")
		else
			*pszDev = 0
		end if

		strcat(pszDev, pszDevice)
		p = strchr( pszDev, asc(":"))
		if ( p <> NULL ) then
			*p = 0
		end if
	end if

	#if 0
	/' FIXME: Use default COM properties by default '/
	dim as COMMCONFIG cc
	if ( GetDefaultCommConfig( pszDev, @cc, @dwSizeCC ) = NULL ) then
		'Empty
   end if
	#endif

	/' Open device '/
	hDevice = CreateFileA( pszDev, dwDesiredAccess, 0 /' dwShareMode: must be zero (exclusive access) for COM port according to MSDN '/, NULL, OPEN_EXISTING, 0, NULL )

	free( pszDev )

	if ( hDevice = INVALID_HANDLE_VALUE ) then
		return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
	end if

	/' Set rx/tx buffer sizes '/
	if ( res = FB_RTERROR_OK ) then
		dim as COMMPROP prop
		if ( GetCommProperties( hDevice, @prop ) = NULL ) then
			res = fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
		else
			if ( prop.dwCurrentTxQueue <> NULL ) then
				dwDefaultTxBufferSize = prop.dwCurrentTxQueue
			elseif ( prop.dwMaxTxQueue <> NULL ) then
				dwDefaultTxBufferSize = prop.dwMaxTxQueue
			end if

			if ( prop.dwCurrentRxQueue <> NULL ) then
				dwDefaultRxBufferSize = prop.dwCurrentRxQueue
			elseif ( prop.dwMaxRxQueue <> NULL ) then
				dwDefaultRxBufferSize = prop.dwMaxRxQueue
			end if

			if ( options->TransmitBuffer <> NULL ) then
				dwDefaultTxBufferSize = options->TransmitBuffer
			end if

			if ( options->ReceiveBuffer <> NULL ) then
				dwDefaultRxBufferSize = options->ReceiveBuffer
			end if

			if ( SetupComm( hDevice, dwDefaultRxBufferSize, dwDefaultTxBufferSize ) = NULL ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if
		end if
	end if

	/' set timeouts '/
	if ( res = FB_RTERROR_OK ) then
		dim as COMMTIMEOUTS timeouts
		if ( GetCommTimeouts( hDevice, @timeouts ) = NULL ) then
			res = fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
		else
			if ( options->DurationCTS <> 0 ) then
				timeouts.ReadIntervalTimeout = options->DurationCTS
				timeouts.ReadTotalTimeoutMultiplier = 0
				timeouts.ReadTotalTimeoutConstant = 0
			end if
			if ( SetCommTimeouts( hDevice, @timeouts ) = NULL ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if
		end if
	end if

	/' setup generic COM port configuration '/
	if ( res = FB_RTERROR_OK ) then
		dim as DCB _dcb
		_dcb.DCBlength = sizeof( _dcb )
		if ( GetCommState( hDevice, @_dcb ) = NULL ) then
			res = fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
		else
			_dcb.BaudRate = options->uiSpeed
			_dcb.fBinary = not(options->AddLF) /' FIXME: Windows only supports binary mode '/
			_dcb.fParity = options->CheckParity
			_dcb.fOutxCtsFlow = options->DurationCTS <> 0
			_dcb.fDtrControl = iif( options->KeepDTREnabled, DTR_CONTROL_ENABLE, DTR_CONTROL_DISABLE )

			/' Not sure about this one ... '/
			_dcb.fDsrSensitivity = (options->DurationDSR <> 0)
			_dcb.fOutxDsrFlow = FALSE

			/' No XON/XOFF '/
			_dcb.fOutX = FALSE
			_dcb.fInX = FALSE
			_dcb.fNull = FALSE

			/' Not sure about this one ... '/
			_dcb.fRtsControl = iif( options->SuppressRTS, RTS_CONTROL_DISABLE, RTS_CONTROL_HANDSHAKE )

			_dcb.fAbortOnError = FALSE
			_dcb.ByteSize = cast(BYTE, options->uiDataBits)

			select case options->Parity
				case FB_SERIAL_PARITY_NONE:
					_dcb.Parity = NOPARITY
				case FB_SERIAL_PARITY_EVEN:
					_dcb.Parity = EVENPARITY
				case FB_SERIAL_PARITY_ODD:
					_dcb.Parity = ODDPARITY
				case FB_SERIAL_PARITY_SPACE:
					_dcb.Parity = SPACEPARITY
				case FB_SERIAL_PARITY_MARK:
					_dcb.Parity = MARKPARITY
			end select

			select case options->StopBits
				case FB_SERIAL_STOP_BITS_1:
					_dcb.StopBits = ONESTOPBIT
				case FB_SERIAL_STOP_BITS_1_5:
					_dcb.StopBits = ONE5STOPBITS
				case FB_SERIAL_STOP_BITS_2:
					_dcb.StopBits = TWOSTOPBITS
			end select

			if ( SetCommState( hDevice, @_dcb ) = NULL ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			else
				EscapeCommFunction( hDevice, SETDTR )
			end if
		end if
	end if

	if ( fb_hSerialCheckLines( hDevice, options ) = NULL ) then
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if ( res <> FB_RTERROR_OK ) then
		CloseHandle( hDevice )
	else
		dim as W32_SERIAL_INFO ptr pInfo = calloc( 1, sizeof(W32_SERIAL_INFO) )
		DBG_ASSERT( ppvHandle <> NULL )
		*ppvHandle = pInfo
		pInfo->hDevice = hDevice
		pInfo->iPort = iPort
		pInfo->pOptions = options
	end if

	return res
end function

function fb_SerialGetRemaining( handle as FB_FILE ptr, pvHandle as any ptr, pLength as fb_off_t ptr ) as long
	dim as W32_SERIAL_INFO ptr pInfo = cast(W32_SERIAL_INFO ptr, pvHandle)
	dim as DWORD dwErrors
	dim as COMSTAT Status
	if ( ClearCommError( pInfo->hDevice, @dwErrors, @Status ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
	if ( pLength <> NULL ) then
		*pLength = cast(long, Status.cbInQue)
	end if
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_SerialWrite( handle as FB_FILE ptr, pvHandle as any ptr, _data as any const ptr, length as size_t ) as long
	dim as W32_SERIAL_INFO ptr pInfo = cast(W32_SERIAL_INFO ptr, pvHandle)
	dim as DWORD dwWriteCount

	if ( fb_hSerialCheckLines( pInfo->hDevice, pInfo->pOptions ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	if ( WriteFile( pInfo->hDevice, _data, length, @dwWriteCount, NULL ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	if ( length <> cast(size_t, dwWriteCount) ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_SerialRead( handle as FB_FILE ptr, pvHandle as any ptr, _data as any ptr, pLength as size_t ptr ) as long
	dim as W32_SERIAL_INFO ptr pInfo = cast(W32_SERIAL_INFO ptr, pvHandle)
	dim as DWORD dwReadCount
	DBG_ASSERT( pLength <> NULL )

	if ( fb_hSerialCheckLines( pInfo->hDevice, pInfo->pOptions ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	if( ReadFile( pInfo->hDevice, _data, *pLength, @dwReadCount, NULL ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if
	*pLength = cast(size_t, dwReadCount)

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_SerialClose( handle as FB_FILE ptr, pvHandle as any ptr ) as long
	dim as W32_SERIAL_INFO ptr pInfo = cast(W32_SERIAL_INFO ptr, pvHandle)
	CloseHandle( pInfo->hDevice )
	free(pInfo)
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern
