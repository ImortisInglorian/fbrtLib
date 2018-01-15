/' LPTx device '/

#include "fb.bi"
#include "crt\ctype.bi"

/'  Tests for the right file name for LPT access.
 *
 * Allowed file names are:
 *
 * - PRN:
 * - LPT:
 * - LPTx: with x>=1
 * - LPT:printer_name,EMU=?,TITLE=?,OPT=?, ...
 '/

extern "C"
function fb_DevLptParseProtocol( lpt_proto_out as DEV_LPT_PROTOCOL ptr ptr, proto_raw as ubyte const ptr, proto_raw_len as size_t,  subst_prn as long ) as long
	dim as ubyte ptr p, ptail, pc, pe
	dim as DEV_LPT_PROTOCOL ptr lpt_proto

	if ( proto_raw = NULL ) then
		return FALSE
	end if

	if ( lpt_proto_out = NULL ) then
		return FALSE
	end if

	*lpt_proto_out = calloc( sizeof( DEV_LPT_PROTOCOL ) + proto_raw_len + 2, 1 )
	lpt_proto = *lpt_proto_out

	if ( lpt_proto = NULL ) then
		return FALSE
	end if

	strncpy( lpt_proto->raw, proto_raw, proto_raw_len )
	lpt_proto->raw[proto_raw_len] = 0

	p = lpt_proto->raw
	ptail = p + strlen( lpt_proto->raw )

	lpt_proto->iPort = 0
	lpt_proto->proto = ptail
	lpt_proto->name = ptail
	lpt_proto->title = ptail
	lpt_proto->emu = ptail

	/' "PRN:" '/

	if ( strcasecmp( p, "PRN:" ) = 0) then
		if ( subst_prn <> 0 ) then
			strcpy( p, "LPT1:" )
		end if

		lpt_proto->proto = p
		lpt_proto->iPort = 1
		return TRUE
	end if

	/' "LPTx:" '/
	
	if ( strncasecmp( p, "LPT", 3) <> 0) then
		return FALSE
	end if

	pc = strchr( p, asc(":") )
	if ( pc = 0 ) then
		return FALSE
	end if

	lpt_proto->proto = p
	p = pc + 1
	
	pc[-1] = 0

	/' Get port number if any '/
	while ( *pc >= asc("0") and *pc <= asc("9") )
		pc -= 1
	wend
	pc += 1
	lpt_proto->iPort = atoi( pc )

	/' Name, TITLE=?, EMU=? '/

	while( *p )
		if ( isspace( *p ) <> 0 or *p = asc(",") ) then
			p += 1
		else
			dim as ubyte ptr pt

			pe = strchr(p, asc("="))
			pc = strchr(p, asc(","))

			if ( pc <> 0 and pe > pc ) then
				pe = NULL
			end if

			if ( pe = 0 ) then
				lpt_proto->name = p
			else
				/' remove spaces before '=' '/
				pt = pe - 1
				while( isspace( *pt ) <> 0 )
					pt[-1] = 0
				wend

				/' remove spaces after '=' or end '/
				pe[1] = 0
				while( isspace( *pe ) <> 0 )
					pe[1] = 0
				wend

				if( strcasecmp( p, "EMU" ) = 0) then
					lpt_proto->emu = pe
				elseif ( strcasecmp( p, "TITLE" ) = 0) then
					lpt_proto->title = pe
				end if
				/' just ignore options we don't understand to allow forward compatibility '/
			end if

			/' remove spaces before ',' or end '/
			pt = iif(pc <> 0, pc, ptail)
			pt -= 1
			while( isspace( *pt ) <> 0 )
				pt[-1] = 0
			wend

			if ( pc <> 0 ) then
				p = pc + 1
				*pc = 0
			else
				p = ptail
			end if
		end if
	wend

	return TRUE
end function

function fb_DevLptTestProtocol( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
	dim as DEV_LPT_PROTOCOL ptr lpt_proto
	dim as long ret = fb_DevLptParseProtocol( @lpt_proto, filename, filename_len, FALSE )
	if ( lpt_proto <> 0 ) then
		free( lpt_proto )
	end if
	return ret
end function
end extern
