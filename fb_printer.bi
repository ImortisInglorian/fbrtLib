type DEV_LPT_PROTOCOL
	as ubyte ptr proto
	as long iPort
	as ubyte ptr name
	as ubyte ptr title
	as ubyte ptr emu
	as ubyte ptr raw
end type

type DEV_LPT_INFO
    as any ptr driver_opaque /' this member must be first '/
    as ubyte ptr pszDevice
    as long iPort
    as size_t uiRefCount
end type

extern "C"
declare function fb_DevLptParseProtocol	( lpt_proto_out as DEV_LPT_PROTOCOL ptr ptr, proto_raw as ubyte const ptr, proto_raw_len as size_t, substprn as long ) as long
declare function fb_DevLptTestProtocol 	( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long

#ifndef fb_DevLptOpen
declare function fb_DevLptOpen       		( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
#endif
declare function fb_DevLptWrite      		( handle as FB_FILE ptr, value as any const ptr, valuelen as size_t ) as long
declare function fb_DevLptWriteWstr  		( handle as FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
declare function fb_DevLptClose      		( handle as FB_FILE ptr ) as long

declare function fb_DevPrinterSetWidth 	( pszDevice as ubyte const ptr, _width as long, default_width as long ) as long
declare function fb_DevPrinterGetOffset 	( pszDevice as ubyte const ptr ) as long

declare function fb_PrinterOpen      		( devInfo as DEV_LPT_INFO ptr, iPort as long, pszDevice as ubyte const ptr ) as long
declare function fb_PrinterWrite     		( devInfo as DEV_LPT_INFO ptr, _data as any const ptr, length as size_t ) as long
declare function fb_PrinterWriteWstr 		( devInfo as DEV_LPT_INFO ptr, _data as FB_WCHAR const ptr, length as size_t ) as long
declare function fb_PrinterClose     		( devInfo as DEV_LPT_INFO ptr ) as long
end extern