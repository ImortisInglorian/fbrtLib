#pragma once

extern "c"


#ifdef __FB_UNIX__
declare function strcasecmp (byval as const zstring ptr, byval as const zstring ptr) as long
declare function strncasecmp (byval as const zstring ptr, byval as const zstring ptr, byval n as size_t) as long
declare function strdup (byval as const zstring ptr) as zstring ptr
declare function strndup (byval as const zstring ptr, byval n as size_t) as zstring ptr
#endif

#ifdef __FB_WIN32__
' Microsoft renamed all POSIX but non-standard C functions to have a leading underscore
' However, many of this functions don't exist in POSIX, or have a different name.
' Those that exist in POSIX are aliased to their POSIX names here, for code portability.
'strerror isn't _strerror
#define memccpy _memccpy
'#define memicmp _memicmp
#define strdup _strdup
'#define strcmpi _strcmpi
'#define stricmp _stricmp
#define strcasecmp _stricmp
'#define stricoll _stricoll
'#define strlwr _strlwr
'#define strnicmp _strnicmp
#define strncasecmp _strnicmp
'#define strnset _strnset
'#define strrev _strrev
'#define strset _strset
'#define strupr _strupr
#define swab _swab
'#define strncoll _strncoll
'#define strnicoll _strnicoll
#define wcsdup _wcsdup
'#define wcsicmp _wcsicmp
#define wcscasecmp _wcsicmp
'#define wcsicoll _wcsicoll
'#define wcslwr _wcslwr
'#define wcsnicmp _wcsnicmp
#define wcsncasecmp _wcsnicmp
'#define wcsnset _wcsnset
'#define wcsrev _wcsrev
'#define wcsset _wcsset
'#define wcsupr _wcsupr
#define wcsncoll _wcsncoll
#define wcsnicoll _wcsnicoll
#endif

end extern
