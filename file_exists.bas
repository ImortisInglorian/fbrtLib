/' file existence testing '/

#include "fb.bi"

extern "C"
function fb_FileExists FBCALL ( filename as const ubyte ptr ) as long
	dim as FILE ptr fp
	
	fp = fopen(cast(ubyte ptr, filename), "r")
	if (fp <> 0) then
		fclose(fp)
		return FB_TRUE
	else
		return FB_FALSE
	end if
end function
end extern
