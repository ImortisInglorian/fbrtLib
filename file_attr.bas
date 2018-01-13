/' file open mode and attribs '/

#include "fb.bi"
#ifdef HOST_WIN32
	#include "win32/io_printer_private.bi"
#endif
#include "dev_com_private.bi"
#include "io_serial_private.bi"

dim shared as long file_mode_map(0 to 4) = { FB_FILE_ATTR_MODE_BINARY, _   /' FB_FILE_MODE_BINARY = 0 '/
											 FB_FILE_ATTR_MODE_RANDOM, _   /' FB_FILE_MODE_RANDOM = 1 '/
											 FB_FILE_ATTR_MODE_INPUT, _    /' FB_FILE_MODE_INPUT  = 2 '/
											 FB_FILE_ATTR_MODE_OUTPUT, _   /' FB_FILE_MODE_OUTPUT = 3 '/
											 FB_FILE_ATTR_MODE_APPEND }    /' FB_FILE_MODE_APPEND = 4 '/

extern "C"
function fb_FileAttr FBCALL ( handle as long, returntype as long ) as ssize_t
	dim as ssize_t ret = 0
	dim as long _err = 0
	dim as FB_FILE ptr file

	file = FB_FILE_TO_HANDLE( handle )

	if ( file <> 0 ) then
		ret = 0
		_err = FB_RTERROR_ILLEGALFUNCTIONCALL
	else
		select case ( returntype )
			case FB_FILE_ATTR_MODE:
				ret = file_mode_map(file->mode)
				_err = FB_RTERROR_OK

			case FB_FILE_ATTR_HANDLE:
				select case ( file->type )
					case FB_FILE_TYPE_PRINTER:
						scope
							dim as DEV_LPT_INFO ptr lptinfo = file->opaque
							if ( lptinfo <> 0 ) then
								#ifdef HOST_WIN32
									dim as W32_PRINTER_INFO ptr printerinfo = lptinfo->driver_opaque
									if ( printerinfo <> 0 ) then
										/' Win32: HANDLE '/
										ret = cast(ssize_t, printerinfo->hPrinter)
										_err = FB_RTERROR_OK
									end if
								#else
									/' Unix/DOS: CRT FILE* '/
									ret = cast(ssize_t, lptinfo->driver_opaque)
									_err = FB_RTERROR_OK
								#endif
							end if
						end scope

					case FB_FILE_TYPE_SERIAL:
						scope
							dim as DEV_COM_INFO ptr cominfo = file->opaque
							if ( cominfo <> 0 ) then
								#ifdef HOST_WIN32
									dim as W32_SERIAL_INFO ptr serialinfo = cominfo->hSerial
									if ( serialinfo <> 0 ) then
										ret = cast(ssize_t, serialinfo->hDevice)
										_err = FB_RTERROR_OK
									end if
								#elseif defined (HOST_LINUX)
									dim as LINUX_SERIAL_INFO ptr serialinfo = cominfo->hSerial
									if ( serialinfo <> 0 ) then
										ret = serialinfo->sfd
										_err = FB_RTERROR_OK
									end if
								#elseif defined (HOST_DOS)
									dim as DOS_SERIAL_INFO ptr serialinfo = cominfo->hSerial
									if ( serialinfo <> 0 ) then
										ret = serialinfo->com_num
										_err = FB_RTERROR_OK
									end if
								#endif
							end if
						end scope

					case else:
						ret = cast(ssize_t, file->opaque) /' CRT FILE* '/
						_err = FB_RTERROR_OK
				end select

			case FB_FILE_ATTR_ENCODING:
				ret = file->encod
				_err = FB_RTERROR_OK

			case else:
				ret = 0
				_err = FB_RTERROR_ILLEGALFUNCTIONCALL
		end select
	end if

	fb_ErrorSetNum( _err )
	return ret
end function
end extern