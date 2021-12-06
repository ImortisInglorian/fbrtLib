/' Linux printer driver '/

#include "../fb.bi"

/' DEV_LPT_INFO->driver_opaque := (FILE *) file_handle '/

static shared lp_buf(0 to 255) as ubyte

Private Function exec_lp_cmd( cmd as const ubyte ptr, test_default as long ) as long

	dim have_default as Boolean = TRUE ' Assume a default printer
	dim result as long = -1

	dim fp as FILE ptr = popen( cast(ubyte ptr, cmd), "r" )
	if( fp ) then
		while( feof( fp ) = 0 )
			if( fgets( @lp_buf(0), 256, fp ) = 0 ) then
				if( (test_default <> 0) AndAlso (have_default) AndAlso (strlen( @lp_buf(0) ) > 2) ) then
					dim lp_bufptr as ubyte ptr = @lp_buf(0)
					if( (lp_bufptr[0] = asc("n") OrElse lp_bufptr[0] = asc("N")) AndAlso _
					    (lp_bufptr[1] = asc("o") OrElse lp_bufptr[1] = asc("O")) ) then
						have_default = FALSE
					end if
				end if
			end if
		wend

		result = pclose( fp ) Shr 8

		if( (test_default <> 0) AndAlso ( have_default = False )) then
			result = -1
		end if
	end if

	return result
End Function

Extern "c"
Function fb_PrinterOpen( devInfo as DEV_LPT_INFO ptr, iPort as long, pszDeviceRaw as const ubyte ptr ) as long

	dim result as long
	dim filename as ubyte ptr = NULL
	dim fp as FILE ptr
	dim lpt_proto as DEV_LPT_PROTOCOL ptr
	dim devNameLen as size_t = strlen(cast(ubyte ptr, pszDeviceRaw))

	if ( fb_DevLptParseProtocol( @lpt_proto, pszDeviceRaw, devNameLen, TRUE ) = 0 ) then
	
		DeAllocate(lpt_proto)
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	devInfo->iPort = iPort

	if( devInfo->iPort=0 ) then
		/' Use spooler '/

		/' create a buffer for our commands '/
		dim bufferlen as size_t = devNameLen + 64
		dim deviceNameBuffer(0 to bufferlen) as ubyte
		filename = @deviceNameBuffer(0)

		/' set destination, if not default '/
		if( (lpt_proto->name <> Null) AndAlso *lpt_proto->name ) then	
		
			/' does printer exist '/
			strcpy(filename, !"lpstat -v \"")
			strcat(filename, lpt_proto->name)
			strcat(filename, !"\" 2>&1 ")
			if( exec_lp_cmd( filename, FALSE ) <> 0 ) then
			
				DeAllocate(lpt_proto)
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if

			/' build command for spooler '/
			strcpy(filename, "lp ")
			strcat(filename, !"-d \"")
			strcat(filename, lpt_proto->name)
			strcat(filename, !"\" ")	
		
		else
		
			/' is there a default printer '/
			strcpy(filename, "lpstat -d 2>&1")
			if( exec_lp_cmd( filename, TRUE ) <> 0 ) then
			
				DeAllocate(lpt_proto)
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if
			/' build command for spooler '/
			strcpy(filename, "lp ")
		end if

		/' set title, if not default '/
		if( *lpt_proto->title ) then
		
			strcat(filename, !"-t \"")
			strcat(filename, lpt_proto->title)
			strcat(filename, !"\"")
		
		else
		
			strcat(filename, !"-t \"FreeBASIC document\"")
		end if

		/' do not print job id '/
		strcat(filename, " -s -")

		Scope
			dim ptr_ as ubyte ptr = filename
			while ((ptr_ = strpbrk(ptr_, !"`&;|>^$\\")) <> NULL)
				*ptr_ = asc("_")
			wend
		End Scope

		/' do not print error messages '/
		strcat(filename, " &> /dev/null")

		fp = popen( filename, "w" )

	else
		dim directportbuf(0 to (7 + 11)) as ubyte
		/' use direct port io '/
		filename = @directportbuf(0)
		sprintf(filename, "/dev/lp%d", (devInfo->iPort-1))
		fp = fopen(filename, "wb")
	end if

	if( fp=NULL ) then
		devInfo->driver_opaque = NULL
		result = fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
	else
		devInfo->driver_opaque = fp
		result = fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	DeAllocate(lpt_proto)

	return result
End Function

Function fb_PrinterWrite( devInfo as DEV_LPT_INFO ptr, data_ as const any ptr, length as size_t ) as long

	dim fp as FILE ptr = cast(FILE ptr, devInfo->driver_opaque)
	dim writeresult as long = fwrite( cast(any ptr, data_), length, 1, fp )
	dim errnum as long = Iif(writeresult <> 1, FB_RTERROR_FILEIO, FB_RTERROR_OK)
	return fb_ErrorSetNum( errnum )
End Function

Function fb_PrinterWriteWstr( devInfo as DEV_LPT_INFO ptr, buffer as const FB_WCHAR ptr, chars as size_t ) as long

	dim fp as FILE ptr = cast(FILE ptr, devInfo->driver_opaque)

	/' !!!FIXME!!! is this ok? '/
	dim temp(0 to (chars * 4)) as ubyte
	dim tempptr as ubyte ptr = @temp(0)
	dim bytes as ssize_t

	fb_WCharToUTF( FB_FILE_ENCOD_UTF8, buffer, chars, tempptr, @bytes )
	/' add null-term '/
	tempptr[bytes] = 0

	dim writeresult as long = fwrite( tempptr, bytes, 1, fp )
	dim errnum as long = Iif(writeresult <> 1, FB_RTERROR_FILEIO, FB_RTERROR_OK)
	return fb_ErrorSetNum( errnum )
End Function


Function fb_PrinterClose( devInfo as DEV_LPT_INFO ptr ) as long

	dim fp as FILE ptr = cast(FILE ptr, devInfo->driver_opaque)
	if( devInfo->iPort = 0 ) then
	
		/' close spooler '/
		dim result as long = ( pclose( fp ) Shr 8 )
		devInfo->driver_opaque = NULL
		if( result <> 0 ) then
			return fb_ErrorSetNum( FB_RTERROR_FILEIO )
		end if
	else
		/' close direct port io '/
		fclose( fp )
		devInfo->driver_opaque = NULL
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
End Function
End Extern