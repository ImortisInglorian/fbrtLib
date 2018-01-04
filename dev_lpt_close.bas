/' LPTx device '/

#include "fb.bi"

extern "C"
function fb_DevLptClose( handle as FB_FILE ptr ) as long
    dim as long res
    dim as DEV_LPT_INFO ptr devInfo

    FB_LOCK()

    devInfo = cast(DEV_LPT_INFO ptr, handle->opaque)
    if ( devInfo->uiRefCount = 1 ) then
		res = fb_PrinterClose( devInfo )

		if ( res = FB_RTERROR_OK ) then
			free(devInfo->pszDevice)
			free(devInfo)
		else
			devInfo->uiRefCount -= 1
			res = fb_ErrorSetNum( FB_RTERROR_OK )
		end if
	end if
    FB_UNLOCK()

	return res
end function
end extern