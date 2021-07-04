/' dir() '/

#include "../fb.bi"
'' #ifndef HOST_CYGWIN
'' 	#include "direct.bi"
'' #endif
#include "windows.bi"

type FB_DIRCTX
	as long in_use
	as long attrib
#ifdef HOST_CYGWIN
	as WIN32_FIND_DATA data
	as HANDLE handle
#else
	as _finddata_t data
	as long handle
#endif
end type

extern "C"
private sub close_dir_internal( byval ctx as FB_DIRCTX ptr )
#ifdef HOST_MINGW
	_findclose( ctx->handle )
#else
	FindClose( ctx->handle )
#endif
	ctx->in_use = FALSE
end sub

sub fb_DIRCTX_Destructor ( byval _data as any ptr )
	dim as FB_DIRCTX ptr ctx = cast( FB_DIRCTX ptr, _data )
	if( ctx->in_use ) then
		close_dir_internal( ctx )
	end if
end sub

private sub close_dir cdecl ( )
	dim as FB_DIRCTX ptr ctx = _FB_TLSGETCTX( DIR )
	close_dir_internal( ctx )
end sub

private function find_next cdecl ( attrib as long ptr ) as ubyte ptr
	dim as ubyte ptr _name = NULL
	dim as FB_DIRCTX ptr ctx = _FB_TLSGETCTX( DIR )

#ifdef HOST_MINGW
    do
		if( _findnext( ctx->handle, @ctx->data ) ) then
			close_dir( )
			_name = NULL
			exit do
		end if
        _name = sadd(ctx->data.name)
	loop while( ctx->data.attrib and not ctx->attrib )

	*attrib = ctx->data.attrib and not(&hFFFFFF00)
#else
	do
		if ( not(FindNextFile( ctx->handle, @ctx->data )) ) then
			close_dir()
			_name = NULL
			exit do
		end if
		_name = sadd(ctx->data.cFileName)
	loop while ( ctx->data.dwFileAttributes and not(ctx->attrib) )

	*attrib = ctx->data.dwFileAttributes and not(&hFFFFFF00)
#endif

	return _name
end function

function fb_Dir FBCALL ( filespec as FBSTRING ptr, attrib as long, out_attrib as long ptr ) as FBSTRING ptr
	dim as FB_DIRCTX ptr ctx
	dim as FBSTRING ptr res
	dim as ssize_t _len
	dim as long tmp_attrib
	dim as ubyte ptr _name
	dim as long handle_ok

	if ( out_attrib = NULL ) then
		out_attrib = @tmp_attrib
	end if

	_len = FB_STRSIZE( filespec )
	_name = NULL

	ctx = _FB_TLSGETCTX( DIR )

	if ( _len > 0 ) then
		/' findfirst '/
		if ( ctx->in_use ) then
			close_dir( )
		end if

#ifdef HOST_MINGW
		ctx->handle = _findfirst( filespec->data, @ctx->data )
		handle_ok = ctx->handle <> -1
#else
		ctx->handle = FindFirstFile( filespec->data, @ctx->data )
		handle_ok = ctx->handle <> INVALID_HANDLE_VALUE
#endif
		
		if ( handle_ok ) then
			/' Handle any other possible bits different Windows versions could return '/
			ctx->attrib = attrib or &hFFFFFF00

			/' archive bit not set? set the dir bit at least.. '/
			if ( (attrib and &h10) = 0 ) then
				ctx->attrib or= &h20
			end if

#ifdef HOST_MINGW
			if( ctx->data.attrib and not ctx->attrib ) then
				_name = find_next( out_attrib )
			else
                _name = sadd(ctx->data.name)
				*out_attrib = ctx->data.attrib and not &hFFFFFF00
            end if
#else
			if ( ctx->data.dwFileAttributes and not(ctx->attrib) ) then
				_name = find_next( out_attrib )
			else
				_name = sadd(ctx->data.cFileName)
				*out_attrib = ctx->data.dwFileAttributes and not(&hFFFFFF00)
			end if
#endif			
			if ( _name ) then
				ctx->in_use = TRUE
			end if
		end if
	else
		/' findnext '/
		if ( ctx->in_use ) then
			_name = find_next( out_attrib )
		end if
	end if

	FB_STRLOCK()

	/' store filename if found '/
	if ( _name ) then
		_len = strlen( _name )
		res = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( res ) then
			fb_hStrCopy( res->data, _name, _len )
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
end function
end extern