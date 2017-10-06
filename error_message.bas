/' error message buffer shared by fb_Die() and fb_Assert() functions '/

#include "fb.bi"

dim as ubyte __fb_errmsg(0 to FB_ERRMSG_SIZE - 1)
