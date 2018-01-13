/' print raw data - no interpretation is done '/

#include "fb.bi"


#define FB_CONPRINTRAW_ fb_ConPrintRawWstr
#define FB_TCHAR FB_WCHAR
#define FB_CON_HOOK_TWRITE Write
#define FB_TCHAR_ADVANCE( iter, count ) iter += count

#include "con_print_raw_uni.bi"
