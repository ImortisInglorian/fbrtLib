/'*
 * ThreadCall: Launches any procedure as new thread, based on libffi.
 *
 * For example:
 *
 * FB code:
 *    declare sub MySub(x as integer, y as integer)
 *    thread = threadcall MySub(2, 3)
 *    threadwait thread
 *
 * Turned into this by fbc:
 *    a = 2
 *    b = 3
 *    thread = fb_ThreadCall(@MySub, STDCALL, 2, INT, @a, INT, @b)
 *    fb_ThreadWait(thread)
 *
 * fb_ThreadCall() packs the call and parameter data it's given into an array
 * of pointers and then launches a thread. The new thread reconstructs the call
 * using LibFFI and then calls the user's procedure.
 '/

#include "fb.bi"

#if defined(DISABLE_FFI) or defined(HOST_DOS) or (defined(HOST_X86) = 0 and defined(HOST_X86_64) = 0)
extern "C"
function fb_ThreadCall( proc as any ptr, abi as long, stack_size as ssize_t, num_args as long, ... ) as FBTHREAD ptr
	return NULL
end function
end extern
#else

#include "ffi.bi"

#define FB_THREADCALL_MAX_ELEMS 1024

type FBTHREADCALL
	as any ptr 			proc
	as long 			abi
	as long 			num_args
	as ffi_type ptr ptr ffi_arg_types
	as any ptr ptr 		values
end type

/' mirrored in compiler/rtl.bi '/
enum 
	FB_THREADCALL_STDCALL
	FB_THREADCALL_CDECL
	FB_THREADCALL_INT8
	FB_THREADCALL_UINT8
	FB_THREADCALL_INT16
	FB_THREADCALL_UINT16
	FB_THREADCALL_INT32
	FB_THREADCALL_UINT32
	FB_THREADCALL_INT64
	FB_THREADCALL_UINT64
	FB_THREADCALL_FLOAT32
	FB_THREADCALL_FLOAT64
	FB_THREADCALL_STRUCT
	FB_THREADCALL_PTR
end enum

private sub freeStruct( arg as ffi_type ptr )
    dim as long i = 0
    dim as ffi_type ptr ptr elem = arg->elements
    
    while( *elem <> NULL )
        /' cap element count to limit buffer overrun '/
        if ( i >= FB_THREADCALL_MAX_ELEMS ) then
            exit while
		end if
        
        /' free embedded types '/
        if ( (*elem)->type = FFI_TYPE_STRUCT ) then
            freeStruct( *elem )
		end if
            
        elem += 1
        i += 1
    wend
    
    free( arg->elements )
    free( arg )
end sub

declare function getArgument( args_list as va_list ptr ) as ffi_type ptr

private function getStruct( args_list as cva_list ptr ) as ffi_type ptr
    dim as long num_elems = cva_arg( *args_list, long )
    dim as long i, j

    /' prepare type '/
    dim as ffi_type ptr ffi_arg = cast(ffi_type ptr, malloc( sizeof( ffi_type ) ))
    ffi_arg->size = 0
    ffi_arg->alignment = 0
    ffi_arg->type = FFI_TYPE_STRUCT
    ffi_arg->elements = cast(ffi_type ptr ptr, malloc( sizeof( ffi_type ptr ) * ( num_elems + 1 ) ))
    ffi_arg->elements[num_elems] = NULL
    
    /' scan elements '/
    for i=0 to num_elems - 1
        ffi_arg->elements[i] = getArgument( args_list )
        if ( ffi_arg->elements[i] = NULL ) then
            /' error, free memory and return NULL '/
            for j=0 to i - 1
                if( ffi_arg->elements[j]->type = FFI_TYPE_STRUCT ) then
                    freeStruct( ffi_arg )
				end if
            next
            free( ffi_arg->elements )
            free( ffi_arg )
            return NULL
        end if
    next
    
    return ffi_arg
end function

private function getArgument( args_list as cva_list ptr ) as ffi_type ptr
    dim as long arg_type = cva_arg( (*args_list), long )
    select case( arg_type )
        case FB_THREADCALL_INT8:
			return @ffi_type_sint8
        case FB_THREADCALL_UINT8:
			return @ffi_type_uint8
        case FB_THREADCALL_INT16:
			return @ffi_type_sint16
        case FB_THREADCALL_UINT16:
			return @ffi_type_uint16
        case FB_THREADCALL_INT32:
			return @ffi_type_sint32
        case FB_THREADCALL_UINT32:
			return @ffi_type_uint32
        case FB_THREADCALL_INT64:
			return @ffi_type_sint64
        case FB_THREADCALL_UINT64:
			return @ffi_type_uint64
        case FB_THREADCALL_FLOAT32:
			return @ffi_type_float
        case FB_THREADCALL_FLOAT64:
			return @ffi_type_double
        case FB_THREADCALL_STRUCT:
			return getStruct( args_list )
        case FB_THREADCALL_PTR:
			return @ffi_type_pointer
        case else:
            return NULL
    end select
end function

declare sub threadproc FBCALL ( param as any ptr )

extern "c"
function fb_ThreadCall( proc as any ptr, abi as long, stack_size as ssize_t, num_args as long, ... ) as FBTHREAD ptr
    dim as ffi_type ptr ptr ffi_args
    dim as any ptr ptr values
    dim as FBTHREADCALL ptr param
    dim as long i, j
    
    /' initialize lists and arrays '/
    ffi_args = cast(ffi_type ptr ptr, malloc( sizeof( ffi_type ptr ) * num_args ))
    values = cast(any ptr ptr, malloc( sizeof( any ptr ) * num_args ))
    dim as cva_list args_list
    
	cva_start(args_list, num_args)
	
    /' scan arguments and values from var_args '/
    for i=0 to num_args - 1
        ffi_args[i] = getArgument( @args_list )
        if( ffi_args[i] = NULL ) then
            /' error, free all memory allocated up to this point '/
            for j=0 to i - 1
                if ( ffi_args[j]->type = FFI_TYPE_STRUCT ) then
                    freeStruct( ffi_args[j] )
				end if
            next
            free(values)
            free(ffi_args)
            return NULL
        end if
        values[i] = cva_arg( args_list, any ptr )
    next
	cva_end( args_list )
    
    /' pack into thread parameter '/
    param = malloc( sizeof( FBTHREADCALL ) )
    param->proc = proc
    param->abi = abi
    param->num_args = num_args
    param->ffi_arg_types = ffi_args
    param->values = values
    
    /' actually start thread '/
    return fb_ThreadCreate( @threadproc, cast(any ptr,param), stack_size )
end function
end extern

private sub threadproc FBCALL ( param as any ptr )
    dim as FBTHREADCALL ptr info = cast(FBTHREADCALL ptr, param)
    dim as ffi_status status = FFI_OK
    dim as ffi_abi abi = -1
    dim as ffi_cif cif
    dim as long i

#ifdef HOST_X86_64
    abi = FFI_DEFAULT_ABI
#else
    /' check calling convention '/
    if( info->abi = FB_THREADCALL_CDECL ) then
        abi = FFI_SYSV
	#ifdef HOST_WIN32
    elseif ( info->abi = FB_THREADCALL_STDCALL ) then
        abi = FFI_STDCALL
	#endif
    else
        status = not(FFI_OK)
	end if

#endif

    /' prep FFI call interface '/
    if ( status = FFI_OK ) then
        status = ffi_prep_cif( _
            @cif, _              '' handle
            abi, _               '' ABI (CDECL or STDCALL on x86, host default on x86_64)
            info->num_args, _    '' number of arguments
            @ffi_type_void, _    '' return type
            info->ffi_arg_types _'' argument types
        )
    end if
	
    /' execute '/
    if ( status = FFI_OK ) then
        ffi_call( @cif, FFI_FN( info->proc ), NULL, info->values )
	end if

    /' free memory and exit '/
    for i=0 to info->num_args - 1
        if ( info->ffi_arg_types[i]->type = FFI_TYPE_STRUCT ) then
            freeStruct( info->ffi_arg_types[i] )
		end if
    next
    free( info->values )
    free( info->ffi_arg_types )
    free( info )
end sub

#endif