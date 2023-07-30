/' dir() '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "crt/sys/stat.bi"
#include "dirent.bi"

Type FB_DIRCTX
	as long attrib
	as dir DIR ptr
	as ubyte(0 to MAX_PATH - 1) filespec_data
	as ubyte(0 to MAX_PATH - 1) dirname_data
	as ubyte ptr filespec
	as ubyte ptr dirname
	as Boolean in_use
End Type

private sub close_dir( byval ctx as FB_DIRCTX ptr )
	closedir( ctx->dir )
	ctx->in_use = FALSE
end sub

private sub FB_DIRCTX_destructor ( byval _data as any ptr )
	dim as FB_DIRCTX ptr ctx = cast( FB_DIRCTX ptr, _data )
	if( ctx->in_use ) then
		close_dir( ctx )
	end if
	Delete ctx
end sub

private function get_thread_dir_data ( ) as FB_DIRCTX Ptr
	dim thread As FBTHREAD Ptr = fb_GetCurrentThread( )
	dim ctx As FB_DIRCTX ptr = cast( FB_DIRCTX ptr, thread->GetData( FB_TLSKEY_DIR ) )
        If( ctx = Null ) Then
		ctx = New FB_DIRCTX
		thread->SetData( FB_TLSKEY_DIR, ctx, @FB_DIRCTX_destructor )
		ctx->filespec = @ctx->filespec_data(0)
		ctx->dirname = @ctx->dirname_data(0)
        End If
	Return ctx

End Function

Private Function get_attrib ( name_ as ubyte ptr, info as stat ptr ) as long

	dim attrib as long = 0
	dim mask as long

	/' read only '/
	if( info->st_uid = geteuid() ) then
		mask = S_IWUSR
	elseif( info->st_gid = getegid() ) then
		mask = S_IWGRP
	else
		mask = S_IWOTH
	end if

	if( (info->st_mode And mask) = 0 ) then
		attrib Or= &h1
	end if

	if( name_[0] = '.' ) then
		attrib Or= &h2	/' hidden '/
	end if

	if( S_ISCHR( info->st_mode ) OrElse S_ISBLK( info->st_mode ) OrElse S_ISFIFO( info->st_mode ) OrElse S_ISSOCK( info->st_mode ) ) then
		attrib Or= &h4	/' system '/
	end if

	if( S_ISDIR( info->st_mode ) ) then
		attrib Or= &h10 /' directory '/
	else
		attrib Or= &h20 /' archive '/
	end if

	return attrib
End Function

Private Function match_spec( name as ubyte ptr, ctx as FB_DIRCTX ptr ) as long

	dim any_ as ubyte ptr
	dim spec as ubyte ptr = ctx->filespec

	while( ( *spec ) OrElse ( *name ) )
	
		select case ( *spec )
		
			case asc("*")
				any_ = spec;
				spec += 1
				while( ( *name <> *spec ) AndAlso ( *name ) )
					name += 1
				wend

			case asc("?")
				spec += 1
				if( *name ) then
					name += 1
				end if

			case else
				if( *spec <> *name ) then
				
					if( ( any_ ) AndAlso ( *name ) ) then
						spec = any_
					else
						return FALSE
					end if
				else
					spec += 1
					name += 1
				end if
		end select
	wend

	return TRUE
End Function

Private Function find_next ( attrib as long ptr, ctx as FB_DIRCTX ptr ) as ubyte ptr

	dim name_ as ubyte ptr = NULL
	dim info as stat
	dim entry as dirent ptr
	dim buffer(0 To MAX_PATH-1) as ubyte

	do
		entry = readdir( ctx->dir )
		if( entry = Null ) then
		
			close_dir( )
			return NULL
		end if
		name = entry->d_name
		strncpy( @buffer(0), ctx->dirname, MAX_PATH )
		buffer(MAX_PATH-1) = 0
		strncat( @buffer(0), name, MAX_PATH - strlen( @buffer(0) ) - 1 )
		buffer(MAX_PATH-1) = 0

		if( stat( buffer, @info ) ) then
			continue do
		end if

		*attrib = get_attrib( name, @info )
	
	while( ( *attrib And Not ctx->attrib ) OrElse (match_spec( name, ctx ) = 0 ))

	return name
End Function

Extern "c"
Function fb_Dir FBCALL( filespec as FBSTRING ptr, attrib as long, out_attrib as long ptr ) as FBSTRING ptr

	dim ctx as FB_DIRCTX ptr
	dim res as FBSTRING ptr
	dim len as ssize_t
	dim tmp_attrib as long
	dim name as ubyte ptr
	dim p as ubyte ptr
	dim info as stat
	
	if( out_attrib = NULL ) then
		out_attrib = @tmp_attrib
	end if

	len = FB_STRSIZE( filespec )
	name = NULL

	ctx = get_thread_dir_data ( )

	if( len > 0 ) then
	
		/' findfirst '/

		if( ctx->in_use ) then
			close_dir( )
		end if

		if( ( strchr( filespec->data, asc("*") <> Null ) OrElse ( strchr( filespec->data, asc("?") ) <> Null ) ) then
		
			/' we have a pattern '/

			p = strrchr( filespec->data, asc("/") )
			if( p <> null ) then
			
				strncpy( ctx->filespec, p + 1, MAX_PATH )
				ctx->filespec[MAX_PATH-1] = 0
				len = (p - filespec->data) + 1
				if( len > MAX_PATH - 1 ) then
					len = MAX_PATH - 1
				end if
				memcpy( ctx->dirname, filespec->data, len )
				ctx->dirname[len] = 0
			
			else
			
				strncpy( ctx->filespec, filespec->data, MAX_PATH )
				ctx->filespec[MAX_PATH - 1] = 0
				strcpy( ctx->dirname, "./")
			end if

			/' Make sure these patterns work just like on Win32/DOS '/
			if( (strcmp( ctx->filespec, "*.*" ) = 0) OrElse (strcmp( ctx->filespec, "*." ) = 0) ) then
				strcpy( ctx->filespec, "*" )
			end if

			if( (attrib And &h10) = 0 ) then
				attrib Or= &h20
			end if
			ctx->attrib = attrib
			ctx->dir = opendir( ctx->dirname )
			if( ctx->dir ) then
			
				name = find_next( out_attrib, ctx )
				if( name ) then
					ctx->in_use = TRUE
				end if
			end if		
		else		
			/' no pattern, use stat on single file '/
			if( stat( filespec->data, @info ) = 0 ) then
			
				tmp_attrib = get_attrib( filespec->data, @info )
				if( (tmp_attrib And Not attrib ) = 0 ) then
				
					name = strrchr( filespec->data, asc("/") )
					if( name = Null ) then
						name = filespec->data
					else
						name += 1
					end if
					*out_attrib = tmp_attrib
				end if
			end if
		end if
	else	
		/' findnext '/
		if( ctx->in_use ) then
			name = find_next( out_attrib, ctx )
		end if
	end if

	FB_STRLOCK()

	/' store filename if found '/
	if( name <> Null ) then
		len = strlen( name )
		res = fb_hStrAllocTemp_NoLock( NULL, len )
		if( res <> Null ) then
			fb_hStrCopy( res->data, name, len )
		else
			res = @__fb_ctx.null_desc
		end if
	else
		res = @__fb_ctx.null_desc
		*out_attrib = 0
	end if

	fb_hStrDelTemp_NoLock( filespec )

	FB_STRUNLOCK()

	return res
End Function
