
extern "C"
/' CONS '/
declare function fb_DevConsOpen          ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long

/' ERR '/
declare function fb_DevErrOpen           ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long

/' FILE '/
declare sub 	 fb_hSetFileBufSize      ( fp as FILE ptr )
declare function fb_DevFileOpen          ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevFileClose         ( handle as FB_FILE ptr ) as long
declare function fb_DevFileEof           ( handle as FB_FILE ptr ) as long

declare function fb_DevFileLock          ( handle as FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
declare function fb_DevFileRead          ( handle as FB_FILE ptr, value as any ptr, pLength as size_t ptr ) as long
declare function fb_DevFileReadWstr      ( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
declare function fb_DevFileReadLine      ( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
declare function fb_DevFileReadLineWstr  ( handle as FB_FILE ptr, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
declare function fb_DevFileSeek          ( handle as FB_FILE ptr, offset as fb_off_t, whence as long ) as long
declare function fb_hDevFileSeekStart    ( fp as FILE ptr, mode as long, encod as FB_FILE_ENCOD, seek_zero as long ) as long
declare function fb_DevFileGetSize       ( fp as FILE ptr, mode as long, encod as FB_FILE_ENCOD, seek_back as long ) as fb_off_t
declare function fb_DevFileTell          ( handle as FB_FILE ptr, pOffset as fb_off_t ptr ) as long
declare function fb_DevFileUnlock        ( handle as FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
declare function fb_DevFileWrite         ( handle as FB_FILE ptr, value as any const ptr, valuelen as size_t ) as long
declare function fb_DevFileWriteWstr     ( handle as FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
declare function fb_DevFileFlush         ( handle as FB_FILE ptr ) as long

type fb_FnDevReadString as function ( buffer as ubyte ptr, count as size_t, fp as FILE ptr ) as ubyte ptr
declare function fb_DevFileReadLineDumb  ( fp as FILE ptr, dst as FBSTRING ptr, pfnReadString as fb_FnDevReadString ) as long

/' ENCOD '/
declare function fb_DevFileOpenEncod     ( handle as FB_FILE ptr, filename as ubyte ptr, fname_len as size_t ) as long
declare function fb_DevFileOpenUTF       ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevFileReadEncod     ( handle as FB_FILE ptr, dst as any ptr, max_chars as size_t ptr) as long
declare function fb_DevFileReadEncodWstr ( handle as FB_FILE ptr, dst as FB_WCHAR ptr, max_chars as size_t ptr ) as long
declare function fb_DevFileReadLineEncod ( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
declare function fb_DevFileReadLineEncodWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as long
declare function fb_DevFileWriteEncod    ( handle as FB_FILE ptr, buffer as any const ptr, chars as size_t ) as long
declare function fb_DevFileWriteEncodWstr( handle as FB_FILE ptr, buffer as FB_WCHAR const ptr, _len as size_t ) as long

/' PIPE '/
declare function fb_DevPipeOpen          ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevPipeClose         ( handle as FB_FILE ptr ) as long

/' SCRN '/
type DEV_SCRN_INFO
	as ubyte          buffer(0 to 15)
	as ulong          length
end type

declare sub 	 fb_DevScrnInit              ( )
declare sub 	 fb_DevScrnInit_Screen       ( )
declare sub 	 fb_DevScrnUpdateWidth       ( )
declare sub 	 fb_DevScrnMaybeUpdateWidth  ( )
declare sub 	 fb_DevScrnEnd               ( handle as FB_FILE ptr )
declare sub 	 fb_DevScrnInit_NoOpen       ( )
declare sub 	 fb_DevScrnInit_Write        ( )
declare sub 	 fb_DevScrnInit_WriteWstr    ( )
declare sub 	 fb_DevScrnInit_Read         ( )
declare sub 	 fb_DevScrnInit_ReadWstr     ( )
declare sub 	 fb_DevScrnInit_ReadLine     ( )
declare sub 	 fb_DevScrnInit_ReadLineWstr ( )

declare function fb_DevScrnOpen          ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevScrnClose         ( handle as FB_FILE ptr ) as long
declare function fb_DevScrnEof           ( handle as FB_FILE ptr ) as long
declare function fb_DevScrnRead          ( handle as FB_FILE ptr, value as any ptr, pLength as size_t ptr ) as long
declare function fb_DevScrnReadWstr      ( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
declare function fb_DevScrnWrite         ( handle as FB_FILE ptr, value as any const ptr, valuelen as size_t ) as long
declare function fb_DevScrnWriteWstr     ( handle as FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
declare function fb_DevScrnReadLine      ( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
declare function fb_DevScrnReadLineWstr  ( handle as FB_FILE ptr, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
declare sub 	 fb_DevScrnFillInput     ( info as DEV_SCRN_INFO ptr )

/' STDIO '/
declare function fb_DevStdIoClose        ( handle as FB_FILE ptr ) as long

/' LPT '/
#ifndef fb_DevLptOpen
declare function fb_DevLptOpen           ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
#endif

/' COM '/
declare function fb_DevComOpen           ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevComTestProtocol   ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
declare function fb_DevComTestProtocolEx ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t, pPort as size_t ptr ) as long
end extern