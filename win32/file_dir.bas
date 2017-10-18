/' dir() '/

#include "../fb.bi"
/'#include <direct.h>'/
#include "windows.bi"

type FB_DIRCTX
	as long in_use
	as long attrib
	as WIN32_FIND_DATA data
	as HANDLE handle
end type

extern "C"
private sub close_dir cdecl ( )
	dim as FB_DIRCTX ptr ctx = _FB_TLSGETCTX( DIR )
    FindClose( ctx->handle )
	ctx->in_use = FALSE
end sub

private function find_next cdecl ( attrib as long ptr ) as ubyte ptr
	dim as ubyte ptr _name = NULL
	dim as FB_DIRCTX ptr ctx = _FB_TLSGETCTX( DIR )
    do
        if ( not(FindNextFile( ctx->handle, @ctx->data )) ) then
            close_dir()
            _name = NULL
            exit do
        end if
        _name = sadd(ctx->data.cFileName)
    loop while ( ctx->data.dwFileAttributes and not(ctx->attrib) )

    *attrib = ctx->data.dwFileAttributes and not(&hFFFFFF00)
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
				_name = find_next( out_attrib )
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