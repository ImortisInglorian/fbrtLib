enum FB_SERIAL_PARITY
	FB_SERIAL_PARITY_NONE
	FB_SERIAL_PARITY_EVEN
	FB_SERIAL_PARITY_ODD
	FB_SERIAL_PARITY_SPACE
	FB_SERIAL_PARITY_MARK
end enum

enum FB_SERIAL_STOP_BITS
	FB_SERIAL_STOP_BITS_1
	FB_SERIAL_STOP_BITS_1_5
	FB_SERIAL_STOP_BITS_2
end enum

type FB_SERIAL_OPTIONS
	as ulong 				uiSpeed
	as ulong 				uiDataBits
	as FB_SERIAL_PARITY 	Parity
	as FB_SERIAL_STOP_BITS 	StopBits
	as ulong 				DurationCTS        /' CS[msec] '/
	as ulong 				DurationDSR        /' DS[msec] '/
	as ulong 				DurationCD         /' CD[msec] '/
	as ulong 				OpenTimeout        /' OP[msec] '/
	as long 				SuppressRTS        /' RS '/
	as long 				AddLF              /' LF, or ASC, or BIN '/
	as long 				CheckParity        /' PE '/
	as long 				KeepDTREnabled     /' DT '/
	as long 				DiscardOnError     /' FE '/
	as long 				IgnoreAllErrors    /' ME '/
	as ulong 				IRQNumber          /' IR2..IR15 '/
	as ulong 				TransmitBuffer     /' TBn - a value 0 means: default value '/
	as ulong 				ReceiveBuffer      /' RBn - a value 0 means: default value '/
end type

extern "C"
declare function fb_DevSerialSetWidth	( pszDevice as ubyte const ptr, _width as long, default_width as long ) as long
declare function fb_SerialOpen       	( handle as FB_FILE ptr, iPort as long, options as FB_SERIAL_OPTIONS ptr, pszDevice as ubyte ptr, ppvHandle as any ptr ptr ) as long
declare function fb_SerialGetRemaining	( handle as FB_FILE ptr, pvHandle as any ptr, pLength as fb_off_t ptr ) as long
declare function fb_SerialWrite      	( handle as FB_FILE ptr, pvHandle as any ptr, _data as any const ptr, length as size_t ) as long
declare function fb_SerialWriteWstr  	( handle as FB_FILE ptr, pvHandle as any ptr, _data as FB_WCHAR const ptr, length as size_t ) as long
declare function fb_SerialRead       	( handle as FB_FILE ptr, pvHandle as any ptr, _data as any ptr, pLength as size_t ptr ) as long
declare function fb_SerialReadWstr   	( handle as FB_FILE ptr, pvHandle as any ptr, _data as FB_WCHAR ptr, pLength as size_t ptr ) as long
declare function fb_SerialClose      	( handle as FB_FILE ptr, pvHandle as any ptr ) as long
end extern