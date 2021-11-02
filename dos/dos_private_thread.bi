#ifdef ENABLE_MT
	#include "crt/pthread.bi"

	type _FBMUTEX
		as pthread_mutex_t id
	end type

	Type _FBCOND
		as pthread_cond_t id
	End Type
#endif
