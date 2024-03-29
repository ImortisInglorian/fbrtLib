/' enhanced ltrimw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrLTrimEx FBCALL ( src as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
    dim as FB_WCHAR ptr dst
    dim as ssize_t _len
    dim as const FB_WCHAR ptr p = src

    if ( src = NULL ) then
        return NULL
    end if

    scope
        dim as ssize_t len_pattern = fb_wstr_Len( pattern )
        _len = fb_wstr_Len( src )
        if ( _len >= len_pattern ) then
            if ( len_pattern = 1 ) then
                p = fb_wstr_SkipChar( src, _len, *pattern )
                _len -= fb_wstr_CalcDiff( src, p )
            elseif ( len_pattern <> 0 ) then
                p = src
                while (_len >= len_pattern )
                    if ( fb_wstr_Compare( p, pattern, len_pattern ) <> 0 ) then
                        exit while
                    end if
                    p += len_pattern
                    _len -= len_pattern
                wend
            end if
        end if
    end scope

    if ( _len > 0 ) then
        /' alloc temp string '/
        dst = fb_wstr_AllocTemp( _len )
        if ( dst <> NULL ) then
            /' simple copy '/
            fb_wstr_Copy( dst, p, _len )
        else
            dst = NULL
        end if
    else
        dst = NULL
    end if

    return dst
end function
end extern