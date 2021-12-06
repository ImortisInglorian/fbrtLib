/' serial port access for Linux '/

#include "../fb.bi"
#include "../io_serial_private.bi"

#include "sys/ioctl.bi"
#include "sys/select.bi"
#include "../crt_extra/signal.bi"
#include "fcntl.bi"

#ifdef HAS_LOCKDEV
#include "lockdev.bi"
#endif

#define BUFFERSIZE	BUFSIZ*16
#define ENDSPD		111111
#define BADSPEED	999999
#define SERIAL_TIMEOUT	3	/' seconds  for write on open'/
#define SREAD_TIMEOUT	70	/' if not receive any character in less 50 millisecs finish read process '/

Private Sub alrm()
	/' signal callback, do nothing '/
End Sub

Private Function get_speed( speed as long ) as speed_t

	static sp(0 to 28, 0 to 1) as ulong = { _
    		{0,     B0}, _
        	{50,    B50}, _
	        {150,   B150}, _
        	{300,   B300}, _
	        {600,   B600}, _
        	{1200,  B1200}, _
	        {1800,  B1800}, _
        	{2400,  B2400}, _
	        {4800,  B4800}, _
        	{9600,  B9600}, _
	        {19200, B19200}, _
        	{38400, B38400}, _
#ifdef B57600
	        {57600, B57600 }, _
#endif
#ifdef B115200
		{115200, B115200 }, _
#endif
#ifdef B230400
		{230400, B230400 }, _
#endif
#ifdef B460800
		{460800, B460800 }, _
#endif
#ifdef B500000
		{500000, B500000 }, _
#endif
#ifdef  B576000
		{576000, B576000 }, _
#endif
#ifdef  B921600
		{921600, B921600 }, _
#endif
#ifdef  B1000000
		{1000000, B1000000 }, _
#endif
#ifdef  B1152000
		{1152000, B1152000 }, _
#endif
#ifdef  B1500000
		{1500000, B1500000 }, _
#endif
#ifdef  B2000000
		{2000000, B2000000 }, _
#endif
#ifdef  B2500000
		{2500000, B2500000 }, _
#endif
#ifdef  B3000000
		{3000000, B3000000 }, _
#endif
#ifdef  B3500000
		{3500000, B3500000 }, _
#endif
#ifdef  B4000000
		{4000000, B4000000 }, _
#endif

		{ENDSPD, 0}, _
		{0, 0} _
	}

	dim n as long = -1
	dim curspeed as ulong

	do
		n += 1
		curspeed = sp(n)(0)
		
	loop while curspeed <> speed

	Return Iif(curspeed = ENDSPD, BADSPEED, sp(n)(1))
End function

Extern "c"
Function fb_SerialOpen
	(
		FB_FILE *handle,
		int iPort,
		FB_SERIAL_OPTIONS *options,
		const char *pszDevice,
		void **ppvHandle
	) as long

	dim res as long = FB_RTERROR_OK
	dim DesiredAccess as long = O_RDWR Or O_NOCTTY Or O_NONBLOCK
	dim SerialFD as long = (-1)
	dim DeviceName(0 to 511) as ubyte
	dim DeviceNamePtr as ubyte ptr = @DeviceName(0)
	dim as termios oldserp, nwserp
	dim TermSpeed as speed_t
#ifdef HAS_LOCKDEV
	dim plckid as pid_t
#endif

	/' The IRQ stuff is not supported on Linux ... '/
	if( options->IRQNumber <> 0 ) then
	
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	res = fb_ErrorSetNum( FB_RTERROR_OK )

	select case handle->access
		case FB_FILE_ACCESS_READ DesiredAccess Or= O_RDONLY
		case FB_FILE_ACCESS_WRITE DesiredAccess Or= O_WRONLY
		case FB_FILE_ACCESS_READWRITE, FB_FILE_ACCESS_ANY
        		DesiredAccess Or= O_RDWR
	end select

	DeviceNamePtr[0] = 0

	if( iPort = 0 ) then
	
		if( strcasecmp(pszDevice, "COM") = 0 ) then
			strcpy( DeviceNamePtr, "/dev/modem" )		
		else		
			strcpy( DeviceNamePtr, pszDevice )
		end if	
	else	
		sprintf(DeviceNamePtr, "/dev/ttyS%d", (iPort-1))
	end if

	/' Setting speed baud line '/
	TermSpeed = get_speed(options->uiSpeed)
	if( TermSpeed = BADSPEED ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

#ifdef HAS_LOCKDEV
	if( dev_testlock(DeviceNamePtr) ) then
		return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
	end if

	plckid = dev_lock(DeviceNamePtr)
	if( plckid < 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
	end if
#endif

	alarm(SERIAL_TIMEOUT)
	SerialFD =  open( DeviceNamePtr, DesiredAccess )
	alarm(0)
	if( SerialFD < 0) then
#ifdef HAS_LOCKDEV
		dev_unlock(DeviceName, plckid)
#endif
		return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
	end if

	/' !!!FIXME!!! Lock file handle (handle->lock) pending, you can use fcnctl or flock functions '/

	/' Make the file descriptor asynchronous '/
	/' fcntl(SerialFD, F_SETFL, FASYNC) '/

	/' Save old status of serial port discipline '/
	if( tcgetattr ( SerialFD, @oldserp ) ) then
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' Discard data write/read in serial port not transmitted '/
	if( tcflush( SerialFD, TCIOFLUSH)  ) then
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    /' Initialize new struct termios with old values '/
	if( tcgetattr ( SerialFD, @nwserp ) ) then
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' Set timeouts
	 * Timeout not are defined in UNIX termio/s
	 * set CTS > 0 enable CTSRTS flow control,
	 * other are ignored are setting for default in open function
	 * !!!FIXME!!! ???
	 '/

	/' setup generic serial port configuration '/
	if( res = FB_RTERROR_OK ) then
		/' Initialize '/
		nwserp.c_cflag Or= CREAD /' Enable receiver '/
		nwserp.c_iflag And= ~(IXON Or IXOFF Or IXANY) /' Disable Software Flow Control '/
		nwserp.c_cflag Or= CREAD /' Enable receiver '/

		if( options->AddLF ) then
			/' With AddFl Set, Process Canonical output/input '/
			nwserp.c_lflag Or= (ICANON Or OPOST Or ONLCR) /' Postprocess output and map newline at nl/cr '/
		
		else
			/' Set raw tty settings '/
			cfmakeraw(@nwserp)
			nwserp.c_cc(VMIN) = 1  /' Wait min for 1 char '/
			nwserp.c_cc(VTIME) = 0  /' Not use timeout '/
		end if

		if( options->KeepDTREnabled ) then
			nwserp.c_cflag And= Not HUPCL /' Not Hangup (set DTR) on last close '/
		else
			nwserp.c_cflag Or= (HUPCL) /' Hangup (drop DTR) on last close '/
		end if

		/' CD (Carrier Detect) and DS (Data Set Ready) are modem signal
		 * in UNIXes the flag CLOCAL attend the modem signals. Quickly, if your conection is
		 * a modem telephony device active CD[0-n] and DS[0-n]
		 * else for local conections set CD0 or DS0
		 '/
		/' DS and CD are ignored '/
		if( options->DurationDSR OrElse options->DurationCD ) then
			nwserp.c_cflag And= Not CLOCAL
		else
			nwserp.c_cflag Or= CLOCAL /' Ignore modem control Lines '/
		end if

		/' Termios not manage timeout for CTS, but understand RTSCTS flow control
		 * if DurationCTS is greater zero CTSRTS flow will be activate
		 '/
		if( options->DurationCTS <> 0 AndAlso (options->SuppressRTS = 0)) then
			nwserp.c_cflag Or= CRTSCTS
		else
			nwserp.c_cflag And= Not CRTSCTS
		end if

		/' Setting speed baud and other serial parameters '/
		nwserp.c_cflag Or= TermSpeed 
		/' Set size word 5,6,7,8 sonly support '/
		nwserp.c_cflag And= Not CSIZE

		select case options->uiDataBits
			case 5 nwserp.c_cflag Or= CS5
			case 6 nwserp.c_cflag Or= CS6
			case 7 nwserp.c_cflag Or= CS7
			case else nwserp.c_cflag Or= CS8
		end select

		On options->Parity + 1 Goto NoParity, EvenParity, OddParity, SpaceParity, MarkParity
		/' Setting parity, 1.5 StopBit not supported '/
		NoParity:
			nwserp.c_cflag And= Not PARENB
			Goto EndParity
		/' 7bits and Space parity is the same (7S1) that (8N1) 8 bits without parity '/
		SpaceParity:
			nwserp.c_cflag And= Not PARENB
			nwserp.c_cflag Or= CS8
			Goto EndParity

		/' !!!FIXME!!! I'm not sure for mark parity, set the input line. Fix me! for output '/
		MarkParity:
			nwserp.c_iflag Or= PARMRK
			/' fall through '/

		EvenParity:
			nwserp.c_iflag Or= (INPCK Or ISTRIP)
			nwserp.c_cflag Or= PARENB
			Goto EndParity

		OddParity:
			nwserp.c_iflag Or= (INPCK Or ISTRIP)
			nwserp.c_cflag Or= (PARENB Or PARODD)
			Goto EndParity

		EndParity:

		/' Ignore all parity errors, can be dangerous '/
		if ( options->IgnoreAllErrors ) then
			nwserp.c_iflag Or= (IGNPAR)
		else
			nwserp.c_iflag And= Not IGNPAR
		end if

		select case options->StopBits
			case FB_SERIAL_STOP_BITS_1 nwserp.c_cflag And= Not(CSTOPB)

			/' 1.5 Stop not support 2 Stop bits assumed '/
			case FB_SERIAL_STOP_BITS_1_5, FB_SERIAL_STOP_BITS_2
				nwserp.c_cflag Or= CSTOPB
		end select

		/' If not RTS hardware flow, sotfware IXANY softflow assumed '/
		if( options->SuppressRTS ) then
			nwserp.c_iflag And= Not(IXON Or IXOFF Or IXANY)
			nwserp.c_iflag Or= (IXON Or IXANY)
		end if

		if( res = FB_RTERROR_OK ) then
			/' Active set serial parameters '/
			if( tcsetattr( SerialFD, TCSAFLUSH, @nwserp ) ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if
		end if
	end if

	/' error? '/
	if( res <> FB_RTERROR_OK ) then

#ifdef HAS_LOCKDEV
		dev_unlock(DeviceNamePtr, plckid)
#endif
		tcsetattr( SerialFD, TCSAFLUSH, @oldserp) /' Restore old parameter of serial line '/
		close(SerialFD)
	else
		dim pInfo LINUX_SERIAL_INFO ptr = New LINUX_SERIAL_INFO
		DBG_ASSERT( ppvHandle!=NULL )
		*ppvHandle = pInfo
		pInfo->sfd = SerialFD	
		pInfo->oldtty = oldserp
		pInfo->newtty = nwserp
#ifdef HAS_LOCKDEV
		pInfo->pplckid = plckid
#endif
		pInfo->iPort = iPort
		pInfo->pOptions = options
	end if

	return res
End Function

Function fb_SerialGetRemaining( handle as FB_FILE ptr, pvHandle as any ptr, pLength as fb_off_t ptr ) as long

	dim rBytes as long
	dim SerialFD as long
	dim pInfo as LINUX_SERIAL_INFO ptr = pvHandle

	SerialFD = pInfo->sfd
	if( ioctl(SerialFD, FIONREAD, @rBytes) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if( pLength ) then *pLength = rBytes

	return fb_ErrorSetNum( FB_RTERROR_OK )
End Function

Function fb_SerialWrite ( handle as FB_FILE ptr, pvHandle as any ptr, data as const any ptr, length as size_t ) as long 

	dim rlng as ssize_t = 0
	dim pInfo as LINUX_SERIAL_INFO ptr = pvHandle
	dim SerialFD as long = pInfo->sfd
	dim err as long

	signal(SIGALRM,  alrm)
	alarm( SERIAL_TIMEOUT )
	rlng=write(SerialFD, data, length)
	alarm(0)

	err = Iif(rlng = length, FB_RTERROR_OK, FB_RTERROR_FILEIO)

	return fb_ErrorSetNum( err )
End Function

Function fb_SerialRead( handle as FB_FILE ptr, pvHandle as any ptr, data as any ptr, length as size_t ) as long

	dim pInfo as LINUX_SERIAL_INFO ptr = pvHandle
	dim SerialFD as long = pInfo->sfd
	dim count as ssize_t = 0
	dim rdfs as fd_set
	dim tnmout as timeval

	FD_ZERO( @rfds )
	FD_SET( SerialFD, @rfds )

	tmout.tv_sec = 0
	tmout.tv_usec = (SREAD_TIMEOUT*1000L) /' convert to microsecs '/

	select( SerialFD+1, @rfds, NULL, NULL, @tmout )
	if ( FD_ISSET(SerialFD, @rfds) ) then
		count = read(SerialFD, data, *pLength)
    		if ( count < 0 ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
	end if

	*pLength = count

	return fb_ErrorSetNum( FB_RTERROR_OK )
End Function

Function fb_SerialClose( handle as FB_FILE ptr, pvHandle as any ptr) as long

	dim pInfo as LINUX_SERIAL_INFO ptr = pvHandle
	dim SerialFD as long = pInfo->sfd
	dim oserp as termios = pInfo->oldtty
#ifdef HAS_LOCKDEV
	dim plckid as pid_t = pInfo->pplckid
	/' !!!FIXME!!! Translated directly from the C version, this can't possibly compile
	 we don't have the DeviceName here '/
	dev_unlock(DeviceName, plckid)
#endif

	/' Restore old parameter of serial line '/
	tcsetattr( SerialFD, TCSAFLUSH, @oserp)

	close(SerialFD)
	Delete pInfo

	return fb_ErrorSetNum( FB_RTERROR_OK )
End Function
