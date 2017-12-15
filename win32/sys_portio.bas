/' ports I/O functions '/

#include "../fb.bi"
#include "fb_private_console.bi"
#include "fbportio.bi"
#include "windows.bi"
#include "win/winioctl.bi"

#ifdef HOST_X86

#include "fbportio_inline.bi"

dim shared as long inited = FALSE

extern "C"
private sub remove_driver( )
	dim as SC_HANDLE manager, service
	dim as SERVICE_STATUS status

	manager = OpenSCManager( NULL, NULL, GENERIC_ALL )
	if ( manager <> NULL ) then
		service = OpenService( manager, sadd("fbportio"), SERVICE_ALL_ACCESS )
		if ( service <> NULL ) then
			ControlService( service, SERVICE_CONTROL_STOP, @status )
			DeleteService( service )
			CloseServiceHandle( service )
		end if
		CloseServiceHandle( manager )
	end if
end sub

private function install_driver( manager as SC_HANDLE ) as SC_HANDLE
	dim as SC_HANDLE service = NULL
	dim as ubyte ptr driver_filename(0 to MAX_PATH - 1)

	remove_driver( )

	if ( GetSystemDirectory( @driver_filename(0), MAX_PATH ) ) then
		strncat( @driver_filename(0), sadd("\\Drivers\\fbportio.sys"), MAX_PATH - strlen( @driver_filename(0) ) - 1 )
		driver_filename(MAX_PATH-1) = 0

		dim as FILE ptr f = fopen( @driver_filename(0), sadd("wb") )
		fwrite( @fbportio_driver(0), FBPORTIO_DRIVER_SIZE, 1, f )
		fclose( f )

		service = CreateService( manager, sadd("fbportio"), sadd("fbportio"), _
			SERVICE_ALL_ACCESS, SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START, SERVICE_ERROR_NORMAL, _
			sadd("System32\\Drivers\\fbportio.sys"), NULL, NULL, NULL, NULL, NULL )
	end if
	return service
end function

private sub start_driver( )
	dim as SC_HANDLE manager, service

	manager = OpenSCManager( NULL, NULL, GENERIC_ALL )
	if ( manager = NULL ) then
		manager = OpenSCManager( NULL, NULL, GENERIC_READ )
	end if
	if ( manager <> NULL ) then
		service = OpenService( manager, sadd("fbportio"), SERVICE_ALL_ACCESS )
		if ( (service = NULL ) or (StartService( service, 0, NULL ) ) = NULL ) then
			if ( service <> NULL ) then
				CloseServiceHandle( service )
			end if
			service = install_driver( manager )
			StartService( service, 0, NULL )
		end if
		CloseServiceHandle( service )
		CloseServiceHandle( manager )
	end if
end sub

private function init_ports( ) as long
	dim as OSVERSIONINFO ver_info
	dim as HANDLE driver
	dim as DWORD pid, bytes_written
	dim as WORD driver_version
	dim as long status, started = FALSE

	memset( @ver_info, 0, sizeof(OSVERSIONINFO) )
	ver_info.dwOSVersionInfoSize = sizeof(OSVERSIONINFO)
	if ( GetVersionEx( cast(OSVERSIONINFO ptr, @ver_info) ) = NULL ) then
		return FALSE
	end if
	
	select case (ver_info.dwPlatformId)
		
		case VER_PLATFORM_WIN32_WINDOWS:
			'do nothing?
		
		case VER_PLATFORM_WIN32_NT:
			while ( driver = INVALID_HANDLE_VALUE )
				driver = CreateFile( sadd("\\\\.\\fbportio"), GENERIC_READ or GENERIC_WRITE, 0, NULL, _
					OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL )
				if ( driver = INVALID_HANDLE_VALUE ) then
					if ( started = NULL ) then
						start_driver( )
						started = TRUE
					else
						return FALSE
					end if
				else
					if( DeviceIoControl( driver, IOCTL_GET_VERSION, NULL, 0, @driver_version, 2, @bytes_written, NULL ) = NULL or _
							( driver_version <> FBPORTIO_VERSION ) ) then
						/' Not our driver or an old version of it; reinstall '/
						CloseHandle( driver )
						remove_driver( )
						start_driver( )
						started = TRUE
						driver = INVALID_HANDLE_VALUE
					else
						exit select
					end if
				end if
			wend
			
			/' Ok, we got our driver loaded; grant I/O ports access to our own process '/
			pid = GetCurrentProcessId( )
			status = DeviceIoControl( driver, IOCTL_GRANT_IOPM, @pid, 4, NULL, 0, @bytes_written, NULL )
			CloseHandle( driver )
			
			/' Give up our timeslice to ensure process kernel state is updated '/
			Sleep(1)
			
			if ( status = NULL ) then
				return FALSE
			end if
			
	end select

	return TRUE
end function

function fb_hIn( port as ushort ) as long
	dim as ubyte ptr value

	if ( inited = NULL ) then
		inited = init_ports( )
	end if
	if( inited = NULL ) then
		return -fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
	end if
	
	asm
		mov dx, [port]
		in al, dx
		mov [value], al
	end asm
	
	return cast(long, value)
end function

function fb_hOut( port as ushort, value as ubyte ptr ) as long
	if ( inited = NULL ) then
		inited = init_ports( )
	end if
	if ( inited = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
	end if
	
	asm
		mov dx, [port]
		mov al, [value]
		out dx, al
	end asm

	return FB_RTERROR_OK
end function
end extern

#else

extern "C"
function fb_hIn( port as ushort ) as long
	return -fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

function fb_hOut( port as ushort, value as ubyte ptr ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern
#endif
