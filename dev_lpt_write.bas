/' LPTx device '/

#include "fb.bi"

extern "C"
function fb_DevLptWrite( handle as FB_FILE ptr, value as const any ptr, valuelen as size_t ) as long
    dim as long res

    FB_LOCK()

    res = fb_PrinterWrite(cast(DEV_LPT_INFO ptr, handle->opaque), value, valuelen )

    FB_UNLOCK()

	return res
end function
end extern