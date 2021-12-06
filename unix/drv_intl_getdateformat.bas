/' get localized short DATE format '/

#include "../fb.bi"
#include "langinfo.bi"

Function fb_DrvIntlGetDateFormat( char *buffer, size_t len ) as long

    dim do_esc as Boolean = FALSE
    dim do_fmt as Boolean = FALSE
    dim pszOutput as ubyte ptr = buffer
    dim achAddBuffer(0 to 1) as ubyte
    dim pszAdd as const ubyte ptr = NULL
    dim remaining as size_t= len - 1
    dim add_len as size_t = 0
    dim pszCurrent as const ubyte ptr = nl_langinfo( D_FMT )

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

            case asc("a")
                pszAdd = sadd("ddd")
                add_len = 3
            case asc("A")
                pszAdd = sadd("dddd")
                add_len = 4
            case asc("h"), asc("b")
                pszAdd = sadd("mmm")
                add_len = 3
            case asc("B")
                pszAdd = sadd("mmmm")
                add_len = 4
            case asc("d"), asc("e")
                pszAdd = sadd("dd")
                add_len = 2
            case asc("F")
                pszAdd = sadd("yyyy-MM-dd")
                add_len = 10
            case asc("m")
                pszAdd = sadd("MM")
                add_len = 2
            case asc("D"), asc("x")
                pszAdd = sadd("MM/dd/yyyy")
                add_len = 10
            case asc("y")
                pszAdd = sadd("yy")
                add_len = 2
            case asc("Y")
                pszAdd = sadd("yyyy")
                add_len = 4
            case else:
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
