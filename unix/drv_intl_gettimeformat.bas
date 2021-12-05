/' get localized short TIME format '/

#include "../fb.bi"
#include "langinfo.bi"

Function fb_DrvIntlGetTimeFormat( buffer as ubyte ptr, len as size_t ) as long

    dim do_esc as Boolean = FALSE
    dim do_fmt as Boolean = FALSE
    dim pszOutput as ubyte ptr = buffer
    dim achAddBuffer(0 to 1) as ubyte = { 0, 0 }
    dim pszAdd as const ubyte ptr
    dim remaining as size_t = len - 1
    dim add_len as size_t = 0
    dim pszCurrent as const ubyte ptr = nl_langinfo( T_FMT )

    DBG_ASSERT(buffer <> NULL)

    while ( *pszCurrent <> 0 ) 
        dim ch as ubyte = *pszCurrent
        if( do_esc ) then
            do_esc = FALSE
            achAddBuffer(0) = ch
            pszAdd = @achAddBuffer(0)
            add_len = 1
        elseif ( do_fmt ) then
            dim succeeded as Boolean = TRUE
            do_fmt = FALSE
            select case ch
            case asc("n")
                pszAdd = sadd(!"\n")
                add_len = 1
            case asc("t")
                pszAdd = sadd(!"\t")
                add_len = 1
            case asc("%")
                pszAdd = sadd("%")
                add_len = 1
            case asc("H")
                pszAdd = sadd("HH")
                add_len = 2
            case asc("I")
                pszAdd = sadd("hh")
                add_len = 2
            case asc("M")
                pszAdd = sadd("mm")
                add_len = 2
            case asc("p")
                pszAdd = sadd("tt")
                add_len = 2
            case asc("r")
                pszAdd = sadd("hh:mm:ss tt")
                add_len = 11
            case asc("R")
                pszAdd = sadd("HH:mm")
                add_len = 5
            case asc("S")
                pszAdd = sadd("ss")
                add_len = 2
            case asc("T"), asc("X")
                pszAdd = sadd("HH:mm:ss")
                add_len = 8
            case else
                /' Unsupported format '/
                succeeded = FALSE
            end select
            if( succeeded = False) then
                exit while
            end if
        else
            select case ch
            case asc("%")
                do_fmt = TRUE
            case asc(!"\\")
                do_esc = TRUE
            case else
                achAddBuffer(0) = ch
                pszAdd = @achAddBuffer(0)
                add_len = 1
            end select
        end if
        if( add_len <> 0 ) then
            if( remaining < add_len ) then
                return FALSE
            end if
            strcpy( pszOutput, pszAdd )
            pszOutput += add_len
            remaining -= add_len
            add_len = 0
        end if
        pszCurrent += 1
    Wend

    return TRUE
End Function
