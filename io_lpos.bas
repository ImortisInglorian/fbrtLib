/' Returns the printers X position '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_LPos FBCALL ( printer_index as long ) as long
    dim as long cur
    dim as ubyte buffer(0 to 31)
	
    FB_LOCK()

    sprintf(@buffer(0), "LPT%d:", (printer_index+1))
    cur = fb_DevPrinterGetOffset( @buffer(0) )

	FB_UNLOCK()
	
    return cur
end function
end extern