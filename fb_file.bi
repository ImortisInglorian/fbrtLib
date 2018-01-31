#ifdef fb_FileOpenCons
	#undef fb_FileOpenCons
	#undef fb_FileOpenErr
	#undef fb_FileOpenPipe
	#undef fb_FileOpenScrn
	#undef fb_FileOpenLpt
	#undef fb_FileOpenCom
	#undef fb_FileOpenQB
	#undef fb_FileOpen
	#undef fb_FileOpenEncod
	#undef fb_FileOpenShort
	#undef fb_FileClose
	#undef fb_FileCloseAll
	#undef fb_FilePut
	#undef fb_FilePutLarge
	#undef fb_FilePutStr
	#undef fb_FilePutStrLarge
	#undef fb_FilePutStrEx
	#undef fb_FileGet
	#undef fb_FileGetLarge
	#undef fb_FileGetIOB
	#undef fb_FileGetLargeIOB
	#undef fb_FileGetStr
	#undef fb_FileGetStrLarge
	#undef fb_FileGetStrIOB
	#undef fb_FileGetStrLargeIOB
	#undef fb_FilePutArray
	#undef fb_FilePutArrayLarge
	#undef fb_FileGetArray
	#undef fb_FileGetArrayLarge
	#undef fb_FileGetArrayIOB
	#undef fb_FileGetArrayLargeIOB
	#undef fb_FileEof
	#undef fb_FileEofEx
	#undef fb_FileTell
	#undef fb_FileSeek
	#undef fb_FileSeekLarge
	#undef fb_FileInput
	#undef fb_FileStrInput
	#undef fb_FileWstrInput
	#undef fb_FileLineInput
	#undef fb_FileLineInputWstr
	#undef fb_InputBool
	#undef fb_InputByte
	#undef fb_InputUbyte
	#undef fb_InputShort
	#undef fb_InputUshort
	#undef fb_InputInt
	#undef fb_InputUint
	#undef fb_InputLongint
	#undef fb_InputUlongint
	#undef fb_InputSingle
	#undef fb_InputDouble
	#undef fb_InputString
	#undef fb_InputWstr
	#undef fb_FileLock
	#undef fb_FileLockLarge
	#undef fb_FileUnlock
	#undef fb_FileUnlockLarge
#endif

#define FB_FILE_MODE_BINARY             0
#define FB_FILE_MODE_RANDOM             1
#define FB_FILE_MODE_INPUT              2
#define FB_FILE_MODE_OUTPUT             3
#define FB_FILE_MODE_APPEND             4

#define FB_FILE_ACCESS_ANY              0
#define FB_FILE_ACCESS_READ             1
#define FB_FILE_ACCESS_WRITE            2
#define FB_FILE_ACCESS_READWRITE        3

#define FB_FILE_LOCK_SHARED             0
#define FB_FILE_LOCK_READ               1
#define FB_FILE_LOCK_WRITE              2
#define FB_FILE_LOCK_READWRITE          3

#define FB_FILE_TYPE_NORMAL             0
#define FB_FILE_TYPE_CONSOLE            1
#define FB_FILE_TYPE_ERR                2
#define FB_FILE_TYPE_PIPE               3
#define FB_FILE_TYPE_VFS                4
#define FB_FILE_TYPE_PRINTER            5
#define FB_FILE_TYPE_SERIAL             6

enum FB_FILE_ENCOD
	FB_FILE_ENCOD_ASCII
	FB_FILE_ENCOD_UTF8
	FB_FILE_ENCOD_UTF16
	FB_FILE_ENCOD_UTF32
end enum

#define FB_FILE_ENCOD_DEFAULT FB_FILE_ENCOD_ASCII


#define FB_FILE_FROM_HANDLE(handle) ((handle) - @__fb_ctx.fileTB(0)) + 1 - FB_RESERVED_FILES)
#define FB_FILE_INDEX_VALID(index) ((index)>=1 and ((index)<=(FB_MAX_FILES-FB_RESERVED_FILES)))

#define FB_INDEX_IS_SPECIAL(index) (((index) < 1) and (((index) > (-FB_RESERVED_FILES))

#define FB_HANDLE_IS_SCREEN(handle) ((handle)<> NULL and FB_HANDLE_DEREF(handle) = @FB_HANDLE_SCREEN)

#define FB_HANDLE_USED(handle) ((handle) <> NULL and ((handle)->hooks <> NULL))

#define FB_HANDLE_SCREEN    __fb_ctx.fileTB(0)
#define FB_HANDLE_PRINTER   (__fb_ctx.fileTB(1))

type _FB_FILE as FB_FILE

type FnFileSetWidth as function ( handle as _FB_FILE ptr, new_width as long ) as long
type FnFileTest as function ( handle as _FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
type FnFileOpen as function ( handle as _FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
type FnFileEof as function ( handle as _FB_FILE ptr ) as long
type FnFileClose as function ( handle as _FB_FILE ptr ) as long
type FnFileSeek as function ( handle as _FB_FILE ptr, offset as fb_off_t, whence as long ) as long
type FnFileTell as function ( handle as _FB_FILE ptr, pOffset as fb_off_t ptr ) as long
type FnFileRead as function ( handle as _FB_FILE ptr, value as any ptr, pValuelen as size_t ptr ) as long
type FnFileReadWstr as function ( handle as _FB_FILE ptr, value as FB_WCHAR ptr, pValuelen as size_t ptr ) as long
type FnFileWrite as function ( handle as _FB_FILE ptr, value as any const ptr, valuelen as size_t ) as long
type FnFileWriteWstr as function ( handle as _FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
type FnFileLock as function ( handle as _FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
type FnFileUnlock as function ( handle as _FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
type FnFileReadLine as function ( handle as _FB_FILE ptr, dst as FBSTRING ptr ) as long
type FnFileReadLineWstr as function ( handle as _FB_FILE ptr, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
type FnFileFlush as function ( handle as _FB_FILE ptr ) as long

type FB_FILE_HOOKS
	as FnFileEof           pfnEof
	as FnFileClose         pfnClose
	as FnFileSeek          pfnSeek
	as FnFileTell          pfnTell
	as FnFileRead          pfnRead
	as FnFileReadWstr      pfnReadWstr
	as FnFileWrite         pfnWrite
	as FnFileWriteWstr     pfnWriteWstr
	as FnFileLock          pfnLock
	as FnFileUnlock        pfnUnlock
	as FnFileReadLine      pfnReadLine
	as FnFileReadLineWstr  pfnReadLineWstr
	as FnFileSetWidth      pfnSetWidth
	as FnFileFlush         pfnFlush
end type

type FB_FILE
	as long 				mode
	as long 				len
	as FB_FILE_ENCOD 		encod
	as fb_off_t 			size
	as long 				type
	as long 				access
	as long 				lock
	as ulong 				line_length
	as ulong 				width

	/' for a device-independent put back feature '/
	as ubyte 				putback_buffer(0 to 3)
	as size_t 				putback_size

	as FB_FILE_HOOKS ptr 	hooks
	/' an i/o handler might store additional (handler specific) data here '/
	as any ptr 				opaque
	/' used when opening SCRN: to create an redirection handle '/
	as _FB_FILE ptr 		redirection_to
end type

type FB_INPUTCTX
	as FB_FILE ptr 			handle
	as long 				status
	as FBSTRING ptr 		str
	as long 				index
end type


#define FB_FILE_TO_HANDLE_VALID( index ) (cast(FB_FILE ptr, (@__fb_ctx.fileTB(0) + (index) - 1 + FB_RESERVED_FILES)))

#define FB_FILE_TO_HANDLE( index ) _
	(iif(index = 0,_
		(cast(FB_FILE ptr, @FB_HANDLE_SCREEN)),_
		iif( (index) = -1,_
			cast(FB_FILE ptr, @FB_HANDLE_PRINTER),_
			iif( FB_FILE_INDEX_VALID( (index) ),_ 
				FB_FILE_TO_HANDLE_VALID( (index) ),_
				(cast(FB_FILE ptr,(NULL)))_
				)_
			)_
		)_
	)

extern "C"
private function FB_HANDLE_DEREF( handle as FB_FILE ptr ) as FB_FILE ptr
	if ( handle <> NULL ) then
		FB_LOCK()
		while ( handle->redirection_to <> NULL )
			handle = handle->redirection_to
		wend
		FB_UNLOCK()
	end if
	return handle
end function

declare function fb_FilePutData 				   ( fnum as long, pos as fb_off_t, data as any const ptr, length as size_t, adjust_rec_pos as long, checknewline as long ) as long
declare function fb_FilePutDataEx 				   ( handle as FB_FILE ptr, pos as fb_off_t, data as any const ptr, length as size_t, adjust_rec_pos as long, checknewline as long, isunicode as long ) as long
declare function fb_FileGetData 				   ( fnum as long, pos as fb_off_t, data as any ptr, length as size_t, adjust_rec_pos as long ) as long
declare function fb_FileGetDataEx 				   ( handle as FB_FILE ptr, pos as fb_off_t, data as any ptr, length as size_t, bytesread as size_t ptr, adjust_rec_pos as long, isunicode as long ) as long

declare function fb_FileOpenVfsRawEx 			   ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_length as size_t, mode as ulong, access as ulong, lock as ulong, _len as long, encoding as FB_FILE_ENCOD, pfnOpen as FnFileOpen ) as long
declare function fb_FileOpenVfsEx 				   ( handle as FB_FILE ptr, str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, len as long, encoding as FB_FILE_ENCOD, pfnOpen as FnFileOpen ) as long
declare function fb_FileOpenCons 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long
declare function fb_FileOpenErr 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long
declare function fb_FileOpenPipe 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long
declare function fb_FileOpenScrn 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long

declare function fb_FileOpenLpt 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long

declare function fb_FileOpenCom 			FBCALL ( str_filename as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long

declare function fb_FileOpenQB 				FBCALL ( str as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long ) as long

declare function fb_FileFree 				FBCALL ( ) as long
declare function fb_FileOpen 				FBCALL ( str as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long ) as long
declare function fb_FileOpenEncod 			FBCALL ( str as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, fnum as long, len as long, encoding as ubyte const ptr ) as long
declare function fb_FileOpenEx 					   ( handle as FB_FILE ptr, _str as FBSTRING ptr, mode as ulong, access as ulong, lock as ulong, len as long ) as long
declare function fb_FileOpenShort 			FBCALL ( str_file_mode as FBSTRING ptr, fnum as long, filename as FBSTRING ptr, len as long, str_access_mode as FBSTRING ptr, str_lock_mode as FBSTRING ptr ) as long
declare function fb_FileCloseEx 				   ( handle as FB_FILE ptr ) as long
declare function fb_FileClose 				FBCALL ( fnum as long ) as long
declare function fb_FileCloseAll 			FBCALL ( ) as long

declare function fb_FilePut 				FBCALL ( fnum as long, pos as long, value as any ptr, valuelen as size_t ) as long
declare function fb_FilePutLarge 			FBCALL ( fnum as long, pos as longint, value as any ptr, valuelen as size_t ) as long
declare function fb_FilePutEx 					   ( handle as FB_FILE ptr, pos as fb_off_t, value as any ptr, valuelen as size_t ) as long
declare function fb_FilePutStr 				FBCALL ( fnum as long, pos as long, str as any ptr, str_len as ssize_t ) as long
declare function fb_FilePutStrLarge 		FBCALL ( fnum as long, pos as longint, str as any ptr, str_len as ssize_t ) as long
declare function fb_FilePutStrEx 				   ( handle as FB_FILE ptr, pos as fb_off_t, str as any ptr, str_len as ssize_t ) as long
declare function fb_FilePutArray 			FBCALL ( fnum as long, pos as long, src as FBARRAY ptr ) as long
declare function fb_FilePutArrayLarge 		FBCALL ( fnum as long, pos as longint, src as FBARRAY ptr ) as long

declare function fb_FileGet 				FBCALL ( fnum as long, pos as long, value as any ptr, valuelen as size_t ) as long
declare function fb_FileGetLarge 			FBCALL ( fnum as long, pos as longint, dst as any ptr, chars as size_t ) as long
declare function fb_FileGetIOB 				FBCALL ( fnum as long, pos as long, dst as any ptr, chars as size_t, bytesread as size_t ptr ) as long
declare function fb_FileGetLargeIOB 		FBCALL ( fnum as long, pos as longint, dst as any ptr, chars as size_t, bytesread as size_t ptr ) as long
declare function fb_FileGetEx 					   ( handle as FB_FILE ptr, pos as fb_off_t, value as any ptr, valuelen as size_t ) as long
declare function fb_FileGetStr 				FBCALL ( fnum as long, pos as long, str as any ptr, str_len as ssize_t ) as long
declare function fb_FileGetStrLarge 		FBCALL ( fnum as long, pos as longint, str as any ptr, str_len as ssize_t ) as long
declare function fb_FileGetStrIOB 			FBCALL ( fnum as long, pos as long, str as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
declare function fb_FileGetStrLargeIOB 		FBCALL ( fnum as long, pos as longint, _tr as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
declare function fb_FileGetStrEx 				   ( handle as FB_FILE ptr, pos as fb_off_t, str as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
declare function fb_FileGetArray 			FBCALL ( fnum as long, pos as long, dst as FBARRAY ptr ) as long
declare function fb_FileGetArrayLarge 		FBCALL ( fnum as long, pos as longint, dst as FBARRAY ptr ) as long
declare function fb_FileGetArrayIOB 		FBCALL ( fnum as long, pos as long, dst as FBARRAY ptr, bytesread as size_t ptr ) as long
declare function fb_FileGetArrayLargeIOB 	FBCALL ( fnum as long, pos as longint, dst as FBARRAY ptr, bytesread as size_t ptr ) as long

declare function fb_FileEof 				FBCALL ( fnum as long ) as long
declare function fb_FileEofEx 					   ( handle as FB_FILE ptr ) as long
declare function fb_FileTell 				FBCALL ( fnum as long ) as longint
declare function fb_FileTellEx 				       ( handle as FB_FILE ptr ) as fb_off_t
declare function fb_FileSeek 				FBCALL ( fnum as long, newpos as long )  as long
declare function fb_FileSeekLarge 			FBCALL ( fnum as long, newpos as longint ) as long
declare function fb_FileSeekEx 					   ( handle as FB_FILE ptr, newpos as fb_off_t ) as long
declare function fb_FileLocation 			FBCALL ( fnum as long ) as longint
declare function fb_FileLocationEx 				   ( handle as FB_FILE ptr ) as fb_off_t
declare function fb_FileKill 				FBCALL ( str as FBSTRING ptr ) as long
declare sub 	 fb_FileReset 				FBCALL ( )
declare sub 	 fb_FileResetEx 			FBCALL ( streamno as long )
declare function fb_hFileResetEx 				   ( streamno as long ) as long
declare function fb_FileSize 				FBCALL ( fnum as long ) as longint
declare function fb_FileSizeEx 					   ( handle as FB_FILE ptr ) as fb_off_t
declare function fb_FilePutBack 			FBCALL ( fnum as long, _data as any const ptr, length as size_t ) as long
declare function fb_FilePutBackWstr 		FBCALL ( fnum as long, src as FB_WCHAR const ptr, chars as size_t ) as long
declare function fb_FilePutBackEx 				   ( handle as FB_FILE ptr, _data as any const ptr, length as size_t ) as long
declare function fb_FilePutBackWstrEx 			   ( handle as FB_FILE ptr, src as FB_WCHAR ptr, chars as size_t ) as long

declare function fb_FileInput 				FBCALL ( fnum as long ) as long
declare function fb_FileStrInput 			FBCALL ( bytes as ssize_t, fnum as long ) as FBSTRING ptr
declare function fb_FileWstrInput 			FBCALL ( chars as ssize_t, fnum as long ) as FB_WCHAR ptr
declare function fb_FileLineInput 			FBCALL ( fnum as long, dst as any ptr, dst_len as ssize_t, fillrem as long ) as long
declare function fb_FileLineInputWstr 		FBCALL ( fnum as long, dst as FB_WCHAR ptr, max_chars as ssize_t ) as long

declare function fb_InputBool 				FBCALL ( dst as ubyte ptr ) as long
declare function fb_InputByte 				FBCALL ( dst as ubyte ptr ) as long
declare function fb_InputUbyte 				FBCALL ( dst as ubyte ptr ) as long
declare function fb_InputShort 				FBCALL ( dst as short ptr ) as long
declare function fb_InputUshort 			FBCALL ( dst as ushort ptr ) as long
declare function fb_InputInt 				FBCALL ( dst as long ptr ) as long
declare function fb_InputUint 				FBCALL ( dst as ulong ptr ) as long
declare function fb_InputLongint 			FBCALL ( dst as longint ptr ) as long
declare function fb_InputUlongint 			FBCALL ( dst as ulongint ptr) as long
declare function fb_InputSingle 			FBCALL ( dst as single ptr ) as long
declare function fb_InputDouble 			FBCALL ( dst as double ptr ) as long
declare function fb_InputString 			FBCALL ( dst as any ptr, strlen as ssize_t, fillrem as long ) as long
declare function fb_InputWstr 				FBCALL ( str as FB_WCHAR ptr, length as ssize_t ) as long

declare function fb_FileLock 				FBCALL ( fnum as long, inipos as ulong, endpos as ulong ) as long
declare function fb_FileLockLarge 			FBCALL ( fnum as long, inipos as longint, endpos as longint ) as long
declare function fb_FileUnlock 				FBCALL ( fnum as long, inipos as ulong, endpos as ulong ) as long
declare function fb_FileUnlockLarge 		FBCALL ( fnum as long, inipos as longint, endpos as longint ) as long

declare function fb_hFilePrintBuffer 			   ( fnum as long, buffer as ubyte const ptr ) as long
declare function fb_hFilePrintBufferWstr 		   ( fnum as long, buffer as FB_WCHAR const ptr ) as long
declare function fb_hFilePrintBufferEx 			   ( handle as FB_FILE ptr, buffer as any const ptr, len as size_t ) as long
declare function fb_hFilePrintBufferWstrEx 		   ( handle as FB_FILE ptr, buffer as FB_WCHAR const ptr, len as size_t ) as long

declare function fb_hFileLock 					   ( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) as long
declare function fb_hFileUnlock 				   ( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) as long
declare sub 	 fb_hConvertPath 				   ( path as ubyte ptr )

declare function fb_hFileStrToEncoding 			   ( encoding as ubyte ptr ) as FB_FILE_ENCOD

declare function fb_SetPos 					FBCALL ( handle as FB_FILE ptr, line_length as long ) as long

declare function fb_FileInputNextToken 			   ( buffer as ubyte ptr, maxlen as ssize_t, isstring as long, isfp as long ptr ) as long
declare sub 	 fb_FileInputNextTokenWstr 		   ( buffer as FB_WCHAR ptr, max_chars as ssize_t, is_string as long )

declare function fb_Dir 					FBCALL ( filespec as FBSTRING ptr, attrib as long, out_attrib as long ptr ) as FBSTRING ptr
declare function fb_Dir64 					FBCALL ( filespec as FBSTRING ptr, attrib as long, outattrib as longint ptr ) as FBSTRING ptr
declare function fb_DirNext 				FBCALL ( outattrib as long ptr ) as FBSTRING ptr
declare function fb_DirNext64 				FBCALL ( outattrib as longint ptr ) as FBSTRING ptr

 /' Maximum length that can safely be parsed as INTEGER '/
#define FB_INPUT_MAXINTLEN 9

 /' Maximum length that can safely be parsed as LONGINT '/
#define FB_INPUT_MAXLONGLEN 18

 /' Maximum length of a DOUBLE printed in FB ("-1.345678901234567e+100") '/
#define FB_INPUT_MAXDBLLEN (1 + 17 + 1 + 1 + 3)

 /' Maximum length that can represent a LONGINT ("&B" + 64 digits) '/
#define FB_INPUT_MAXLONGBINLEN (2 + 64)

 /' Numeric input max buffer length (max numeric length + delimiter) '/
#define FB_INPUT_MAXNUMERICLEN (FB_INPUT_MAXLONGBINLEN+1)

 /' String input max buffer length '/
#define FB_INPUT_MAXSTRINGLEN 4096


/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * UTF Encoding
 *************************************************************************************************'/

dim shared as UTF_8 __fb_utf8_bmarkTb(0 to 6)

declare sub 	 fb_hCharToUTF8 				   ( src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr )
declare function fb_CharToUTF 					   ( encod as FB_FILE_ENCOD, src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
declare function fb_WCharToUTF 					   ( encod as FB_FILE_ENCOD, src as FB_WCHAR const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
declare function fb_hFileRead_UTFToChar 		   ( fp as FILE ptr, encod as FB_FILE_ENCOD, dst as ubyte ptr, max_chars as ssize_t ) as ssize_t
declare function fb_hFileRead_UTFToWchar 		   ( fp as FILE ptr, encod as FB_FILE_ENCOD, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * VB-compatible functions
 *************************************************************************************************'/

#define FB_FILE_ATTR_MODE_INPUT         1
#define FB_FILE_ATTR_MODE_OUTPUT        2
#define FB_FILE_ATTR_MODE_RANDOM        4
#define FB_FILE_ATTR_MODE_APPEND        8
#define FB_FILE_ATTR_MODE_BINARY        32

#define FB_FILE_ATTR_MODE     1
#define FB_FILE_ATTR_HANDLE   2
#define FB_FILE_ATTR_ENCODING 3

declare function fb_FileCopy 				FBCALL ( source as ubyte const ptr, destination as ubyte const ptr ) as long
declare function fb_CrtFileCopy 			FBCALL ( source as ubyte const ptr, destination as ubyte const ptr ) as long
end extern
