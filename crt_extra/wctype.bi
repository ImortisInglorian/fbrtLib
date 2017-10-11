#ifndef __crt_wctype_bi__
#define __crt_wctype_bi__

#include "crt/stddef.bi"  'For wint_t

extern "C"

'TODO: should be defined in wchar.h/wchar.bi. This is platform-specific (correct for linux)
type wctype_t as unsigned long

declare function iswalnum (byval as wint_t) as long
declare function iswalpha (byval as wint_t) as long
declare function iswcntrl (byval as wint_t) as long
declare function iswdigit (byval as wint_t) as long
declare function iswgraph (byval as wint_t) as long
declare function iswlower (byval as wint_t) as long
declare function iswprint (byval as wint_t) as long
declare function iswpunct (byval as wint_t) as long
declare function iswspace (byval as wint_t) as long
declare function iswupper (byval as wint_t) as long
declare function iswxdigit (byval as wint_t) as long
declare function iswblank (byval as wint_t) as long
declare function wctype (byval as zstring ptr) as wctype_t
declare function iswctype (byval as wint_t, byval as wctype_t) as long
declare function towlower (byval as wint_t) as wint_t
declare function towupper (byval as wint_t) as wint_t

end extern

#endif
