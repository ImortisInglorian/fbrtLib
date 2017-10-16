#include "windows.h"
#include "winspool.h"

Type _W32_PRINTER_INFO as W32_PRINTER_INFO

type FnEmuPrint as Sub ( pInfo as _W32_PRINTER_INFO ptr, pText as any const ptr, uiLength as size_t, isunicode as long)

/' Win32-specific printer information '/
type W32_PRINTER_INFO
    as HANDLE          hPrinter
    as DWORD           dwJob
    as HDC             hDc
    type Emu
        as DWORD       dwFullSizeX
        as DWORD       dwFullSizeY
        as DWORD       dwSizeX
        as DWORD       dwSizeY
        as DWORD       dwOffsetX
        as DWORD       dwOffsetY
        as DWORD       dwDPI_X
        as DWORD       dwDPI_Y

        as DWORD       dwCurrentX
        as DWORD       dwCurrentY
        as HFONT       hFont
        as COLORREF    clFore, clBack
        as DWORD       dwFontSizeX
        as DWORD       dwFontSizeY
        as long        iPageStarted

        as FnEmuPrint  pfnPrint
    end Type
end type
