#include "windows.bi"
type _FBMUTEX
    as HANDLE id
end type

type w9x_t
	as HANDLE event(0 to 1)
end type

type nt_t
	as HANDLE sema /' semaphore for waiters '/
	as HANDLE waiters_done /' event '/
	as Boolean was_broadcast
end type

Type _FBCOND
	/' data common to both implementations '/
	as long waiters_count
	as CRITICAL_SECTION waiters_count_lock
	union
		as w9x_t w9x
		as nt_t nt
	end union
end type