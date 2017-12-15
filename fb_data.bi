#ifdef fb_DataRestore
	#undef fb_DataRestore
	#undef fb_DataReadStr
	#undef fb_DataReadWstr
	#undef fb_DataReadBool
	#undef fb_DataReadByte
	#undef fb_DataReadUByte
	#undef fb_DataReadShort
	#undef fb_DataReadUShort
	#undef fb_DataReadInt
	#undef fb_DataReadUInt
	#undef fb_DataReadLongint
	#undef fb_DataReadULongint
	#undef fb_DataReadSingle
	#undef fb_DataReadDouble
#endif

type _FB_DATADESC
	as short 					len
	union
		as ubyte ptr 		zstr
		as FB_WCHAR ptr		wstr
		as any ptr   		ofs
		as _FB_DATADESC ptr next
	end union
end type

type FB_DATADESC as _FB_DATADESC

extern as FB_DATADESC ptr __fb_data_ptr

#define FB_DATATYPE_LINK -1
#define FB_DATATYPE_OFS  -2
#define FB_DATATYPE_WSTR &h8000

extern "C"
declare sub 	 fb_DataRestore      FBCALL ( labeladdr as FB_DATADESC ptr)
declare sub 	 fb_DataNext                ( )
declare sub 	 fb_DataReadStr      FBCALL ( dst as any ptr, dst_size as ssize_t, fillrem as long )
declare sub 	 fb_DataReadWstr     FBCALL ( dst as FB_WCHAR ptr, dst_size as ssize_t )
declare sub 	 fb_DataReadBool     FBCALL ( dst as boolean ptr )
declare sub 	 fb_DataReadByte     FBCALL ( dst as byte ptr )
declare sub 	 fb_DataReadUByte    FBCALL ( dst as ubyte ptr )
declare sub 	 fb_DataReadShort    FBCALL ( dst as short ptr )
declare sub 	 fb_DataReadUShort   FBCALL ( dst as ushort ptr )
declare sub 	 fb_DataReadInt      FBCALL ( dst as long ptr)
declare sub 	 fb_DataReadUInt     FBCALL ( dst as ulong ptr )
declare sub 	 fb_DataReadLongint  FBCALL ( dst as longint ptr )
declare sub 	 fb_DataReadULongint FBCALL ( dst as ulongint ptr )
declare sub 	 fb_DataReadSingle   FBCALL ( dst as single ptr )
declare sub 	 fb_DataReadDouble   FBCALL ( dst as double ptr )
end extern