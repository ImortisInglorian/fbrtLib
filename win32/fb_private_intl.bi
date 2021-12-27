#include "windows.bi"

extern "C"
declare function fb_hGetLocaleInfo 			   ( Locale as LCID, _LCType as LCTYPE, pszBuffer as ubyte ptr, uiSize as size_t ) as ubyte ptr
declare function fb_hIntlConvertString 		   ( source as FBSTRING ptr, source_cp as long, dest_cp as long, result as FBSTRING ptr ) as FBSTRING ptr
end extern

declare function _GetLocaleString			( info as LCTYPE, result as FBSTRING ptr ) as FBSTRING ptr