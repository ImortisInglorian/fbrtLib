#include "windows.bi"

extern "C"
declare function fb_hGetLocaleInfo 			   ( Locale as LCID, _LCType as LCTYPE, pszBuffer as ubyte ptr, uiSize as size_t ) as ubyte ptr
declare function fb_hIntlConvertString 		   ( source as FBSTRING ptr, source_cp as long, dest_cp as long ) as FBSTRING ptr
end extern