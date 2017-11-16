#if defined(HOST_WIN32)
	#include "windows.bi"
	type W32_SERIAL_INFO
		as HANDLE hDevice
		as long iPort
		as FB_SERIAL_OPTIONS ptr pOptions
	end type
#elseif defined(HOST_LINUX)
	/' Uncomment HAS_LOCKDEV to active lock file funcionality, not forget
	 * compile whith -llockdev
	 '/
	/' #define HAS_LOCKDEV 1 '/
	type LINUX_SERIAL_INFO
		as long sfd
		as termios oldtty, newtty
		#ifdef HAS_LOCKDEV
		as pid_t pplckid
		#endif
		as long iPort
		as FB_SERIAL_OPTIONS ptr pOptions
	end type
#elseif defined(HOST_DOS)
	type DOS_SERIAL_INFO
		as long com_num
		as FB_SERIAL_OPTIONS ptr pOptions
	end type
#endif
