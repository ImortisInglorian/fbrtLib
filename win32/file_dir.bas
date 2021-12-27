/' dir() '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "../destruct_string.bi"
#include "windows.bi"

type FB_DIRCTX
	as WIN32_FIND_DATA data
	as HANDLE handle
	as long in_use
	as long attrib
end type

private sub close_dir( byval ctx as FB_DIRCTX ptr )
	FindClose( ctx->handle )
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
        End If
	Return ctx

End Function

private function find_next ( attrib as long ptr, ctx as FB_DIRCTX ptr ) as ubyte ptr
	dim as ubyte ptr _name = NULL

	do
		if ( FindNextFile( ctx->handle, @ctx->data ) = 0 ) then
			close_dir( ctx )
			_name = NULL
			exit do
		end if
		_name = sadd(ctx->data.cFileName)
	loop while ( ctx->data.dwFileAttributes and not(ctx->attrib) )

	*attrib = ctx->data.dwFileAttributes and not(&hFFFFFF00)

	return _name
end function

extern "C"
function fb_Dir FBCALL ( filespec as FBSTRING ptr, attrib as long, out_attrib as long ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as FB_DIRCTX ptr ctx
	dim as destructable_string dst
	dim as ssize_t _len
	dim as long tmp_attrib
	dim as ubyte ptr _name
	dim as long handle_ok

	DBG_ASSERT( result <> NULL )

	if ( out_attrib = NULL ) then
		out_attrib = @tmp_attrib
	end if

	_len = FB_STRSIZE( filespec )
	_name = NULL

	ctx = get_thread_dir_data( )

	if ( _len > 0 ) then
		/' findfirst '/
		if ( ctx->in_use ) then
			close_dir( ctx )
		end if
		ctx->handle = FindFirstFile( filespec->data, @ctx->data )
		handle_ok = ctx->handle <> INVALID_HANDLE_VALUE
		
		if ( handle_ok ) then
			/' Handle any other possible bits different Windows versions could return '/
			ctx->attrib = attrib or &hFFFFFF00

			/' archive bit not set? set the dir bit at least.. '/
			if ( (attrib and &h10) = 0 ) then
				ctx->attrib or= &h20
			end if

			if ( ctx->data.dwFileAttributes and not(ctx->attrib) ) then 
				_name = find_next( out_attrib, ctx )
			else
				_name = sadd(ctx->data.cFileName)
				*out_attrib = ctx->data.dwFileAttributes and not(&hFFFFFF00)
			end if

			if ( _name ) then
				ctx->in_use = TRUE
			end if
		end if
	else
		/' findnext '/
		if ( ctx->in_use ) then
			_name = find_next( out_attrib, ctx )
		end if
	end if

	/' store filename if found '/
	if ( _name ) then
		_len = strlen( _name )
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			fb_hStrCopy( dst.data, _name, _len )
		end if
	else
		*out_attrib = 0
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern