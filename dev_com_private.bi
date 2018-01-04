type DEV_COM_INFO
	as any ptr hSerial
	as ubyte ptr pszDevice
	as long iPort
	as FB_SERIAL_OPTIONS Options
end type
