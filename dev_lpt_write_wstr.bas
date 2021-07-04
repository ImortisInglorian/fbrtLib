/' LPTx device '/

#include "fb.bi"

extern "C"
function fb_DevLptWriteWstr( handle as FB_FILE ptr, value as const FB_WCHAR ptr, valuelen as size_t ) as long
    dim as long res

    FB_LOCK()

    res = fb_PrinterWriteWstr(cast(DEV_LPT_INFO ptr, handle->opaque), value, valuelen )

    FB_UNLOCK()

	return res
end function
end extern