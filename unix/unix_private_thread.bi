#include "crt/pthread.bi"

type _FBMUTEX
    as pthread_mutex_t id
end type

type _FBCOND
    as pthread_cond_t id
end type
