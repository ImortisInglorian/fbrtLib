''
'' profile.c -- profiling core functions
''
'' chng: apr/2024 add API to set output file name and report options [jeffm]
''       apr/2024 dynamic string table [jeffm]
''       apr/2024 add profiler lock (replacing fb lock) [jeffm]
''

'' TODO: test the start-up and exit code more

#include "fb.bi"
#include "fb_profile.bi"

#include "crt/time.bi"
#include "fb_private_thread.bi"

extern "C"

'' ************************************
'' Globals - common to all profilers
''

dim shared as FB_PROFILER_GLOBAL ptr fb_profiler = NULL

'' ************************************
'' Helpers
''

public function fb_ProfileHashName( byval p as const zstring ptr ) as ulong
	dim as ulong hash = 0
	while( *p )
		hash += *cast(ubyte ptr, p)
		hash += hash shl 10
		hash ^= hash shr 6
		p += 1
	wend
	hash += hash shl 3
	hash ^= hash shr 11
	hash += hash shl 15
	return hash
end function

'' ************************************
'' String Storage
''

public function STRING_TABLE_alloc( byval strings as STRING_TABLE ptr, byval length as long ) as STRING_INFO ptr
	dim as STRING_INFO ptr info = any
	dim as long size = any

	'' minumum size per string (assuming 4 bytes per int)
	'' - space for STRING_INFO
	'' - pad with additional NUL bytes to make size a multiple of 4
	''

	size = sizeof(STRING_INFO) + ((length + (sizeof(long)-1)) _
	       and not (sizeof(long)-1))

	if( size > STRING_INFO_TB_SIZE ) then
		return NULL
	end if

	if( size > (STRING_INFO_TB_SIZE - strings->tb->bytes_used) ) then
		dim as STRING_INFO_TB ptr tb = cast(STRING_INFO_TB ptr, PROFILER_calloc( 1, sizeof(STRING_INFO_TB) ))
		if( tb = NULL ) then
			return NULL
		end if

		tb->bytes_used = 0
		tb->string_tb_id = strings->tb->string_tb_id + 1
		tb->next = strings->tb
		strings->tb = tb
	end if

	info = cast(STRING_INFO ptr, @strings->tb->data(strings->tb->bytes_used))
	info->size = size
	strings->tb->bytes_used += size

	return info
end function

public sub STRING_TABLE_constructor( byval strings as STRING_TABLE ptr )
	if( strings ) then
		dim as STRING_INFO_TB ptr tb = cast(STRING_INFO_TB ptr, PROFILER_calloc( 1, sizeof(STRING_INFO_TB) ))
		if( tb ) then
			tb->bytes_used = 0
			tb->string_tb_id = 1
			tb->next = NULL
		end if
		strings->tb = tb
	end if
end sub

public sub STRING_TABLE_destructor( byval strings as STRING_TABLE ptr )
	if( strings ) then
		dim as STRING_INFO_TB ptr tb = strings->tb
		while( tb )
			dim as STRING_INFO_TB ptr tb_next = tb->next
			PROFILER_free( tb )
			tb = tb_next
		wend
		PROFILER_free( strings )
	end if
end sub

public function STRING_TABLE_add( byval strings as STRING_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
	dim as STRING_INFO ptr info = any
	dim as long length = any

	length = strlen( src ) + 1

	info = STRING_TABLE_alloc( strings, length )

	if( info ) then
		info->length = length
		info->hashkey = hashkey

		'' copy the string
		strncpy( cast(zstring ptr, (info+1)), src, length )
	end if
	return info
end function

public function STRING_TABLE_max_len( byval strings as STRING_TABLE ptr ) as long
	dim as STRING_INFO_TB ptr tb = any
	dim as STRING_INFO ptr info = any
	dim as long max_len = 0, index = any
	if( strings ) then
		tb = strings->tb
		while ( tb )
			index = 0
			while( index < tb->bytes_used )
				info = cast(STRING_INFO ptr, @tb->data(index))
				if( info->length > max_len ) then
					max_len = info->length
				end if
				index += info->size
			wend
			tb = tb->next
		wend
	end if
	return max_len
end function

public function STRING_HASH_TB_find( byval tb as STRING_HASH_TB ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr

	dim as STRING_INFO ptr info = any
	dim as long hash_index = hashkey mod STRING_HASH_TB_SIZE

	while( tb )
		info = tb->items(hash_index)
		if( info ) then
			if( (info->hashkey = hashkey) andalso (strcmp( cast(zstring ptr, (info + 1)), src ) = 0) ) then
				return info
			end if
		else
			exit while
		end if
		tb = tb->next
	wend
	return NULL
end function

public function STRING_HASH_TABLE_find( byval hash as STRING_HASH_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
	return STRING_HASH_TB_find( hash->tb, src, hashkey )
end function

public sub STRING_HASH_TABLE_constructor( byval hash as STRING_HASH_TABLE ptr, byval strings as STRING_TABLE ptr )
	if( hash ) then
		hash->tb = NULL
		hash->strings = strings
	end if
end sub

public sub STRING_HASH_TABLE_destructor( byval hash as STRING_HASH_TABLE ptr )
	if( hash ) then
		dim as STRING_HASH_TB ptr tb = hash->tb
		while ( tb )
			dim as STRING_HASH_TB ptr tb_next = tb->next
			PROFILER_free( tb )
			tb = tb_next
		wend
		hash->tb = NULL
	end if
end sub

public function STRING_HASH_TABLE_add( byval hash as STRING_HASH_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
	dim as STRING_HASH_TB ptr tb = hash->tb
	dim as STRING_INFO ptr info = any
	dim as long hash_index = hashkey mod STRING_HASH_TB_SIZE

	if( tb = NULL ) then
		tb = cast(STRING_HASH_TB ptr, PROFILER_calloc( 1, sizeof( STRING_HASH_TB ) ) )
		hash->tb = tb
	end if

	while( tb )
		info = tb->items(hash_index)
		if( info ) then
			if( (info->hashkey = hashkey) andalso (strcmp( cast(zstring ptr, info + 1), src ) = 0) ) then
				return info
			end if
		else
			info = STRING_TABLE_add( hash->strings, src, hashkey )
			tb->items(hash_index) = info
			return info
		end if
		if( tb->next = NULL ) then
			tb->next = cast(STRING_HASH_TB ptr, PROFILER_calloc( 1, sizeof( STRING_HASH_TB ) ))
		end if
		tb = tb->next
	wend
	return NULL
end function

public function STRING_HASH_TABLE_add_info( byval hash as STRING_HASH_TABLE ptr, byval new_info as STRING_INFO ptr ) as STRING_INFO ptr
	dim as STRING_HASH_TB ptr tb = hash->tb
	dim as STRING_INFO ptr info = any
	dim as long hash_index = new_info->hashkey mod STRING_HASH_TB_SIZE

	if( tb = NULL ) then
		tb = cast(STRING_HASH_TB ptr, PROFILER_calloc( 1, sizeof( STRING_HASH_TB ) ) )
		hash->tb = tb
	end if

	while( tb )
		info = tb->items(hash_index)
		if( info ) then
			if( info = new_info ) then
				return info
			end if
		else
			tb->items(hash_index) = info
			return info
		end if
		if( tb->next = NULL ) then
			tb->next = cast(STRING_HASH_TB ptr, PROFILER_calloc( 1, sizeof( STRING_HASH_TB ) ))
		end if
		tb = tb->next
	wend
	return NULL
end function

public sub STRING_HASH_constructor( byval hash as STRING_HASH ptr, byval strings_hash as STRING_HASH_TABLE ptr )
	if( hash ) then
		STRING_HASH_TABLE_constructor( @hash->hash, strings_hash->strings )
		hash->strings_hash = strings_hash
	end if
end sub

public sub STRING_HASH_destructor( byval hash as STRING_HASH ptr )
	if( hash ) then
		STRING_HASH_TABLE_destructor( @hash->hash )
		hash->strings_hash = NULL
	end if
end sub

public sub STRING_HASH_add( byval hash as STRING_HASH ptr, byval src as const zstring ptr, byval hashkey as ulong )
	dim as STRING_INFO ptr info = STRING_HASH_TABLE_add( hash->strings_hash, src, hashkey )
	if( info ) then
		STRING_HASH_TABLE_add_info( @hash->hash, info )
	end if
end sub

public function STRING_HASH_find( byval hash as STRING_HASH ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
	return STRING_HASH_TB_find( hash->hash.tb, src, hashkey )
end function

public function PROFILER_add_ignore( byval prof as FB_PROFILER_GLOBAL ptr, byval src as const zstring ptr, byval hashkey as ulong ) as zstring ptr
	dim as STRING_INFO ptr info = STRING_HASH_TABLE_add( @prof->ignores_hash, src, hashkey )
	return cast(zstring ptr,info+1)
end function

'' ************************************
'' Profiler Metrics (internal stats)
''

public sub fb_hPROFILER_METRICS_Clear( byval metrics as FB_PROFILER_METRICS ptr )
	if( metrics ) then
		metrics->count_threads = 0

		metrics->string_bytes_allocated = 0
		metrics->string_bytes_used = 0
		metrics->string_bytes_free = 0
		metrics->string_count_blocks = 0
		metrics->string_count_strings = 0

		metrics->hash_bytes_allocated = 0
		metrics->hash_count_blocks = 0
		metrics->hash_count_items = 0
		metrics->hash_count_slots = 0

		metrics->procs_bytes_allocated = 0
		metrics->procs_count_blocks = 0
		metrics->procs_count_items = 0
		metrics->procs_count_slots = 0
	end if
end sub

public sub fb_hPROFILER_METRICS_Strings( byval metrics as FB_PROFILER_METRICS ptr, byval strings as STRING_TABLE ptr )
	dim as STRING_INFO_TB ptr tb = any
	dim as STRING_INFO ptr info = any
	dim as long index = any

	if( (metrics <> NULL) andalso (strings <> NULL) ) then
		tb = strings->tb
		while ( tb )
			metrics->string_bytes_allocated += sizeof( STRING_INFO_TB )
			metrics->string_bytes_used += tb->bytes_used
			metrics->string_bytes_free += sizeof( STRING_INFO_TB ) - tb->bytes_used
			metrics->string_count_blocks += 1

			index = 0
			while( index < tb->bytes_used )
				info = cast(STRING_INFO ptr, @tb->data(index) )
				if( info->length > metrics->string_max_len ) then
					metrics->string_max_len = info->length
				end if
				metrics->string_count_strings += 1
				index += info->size
			wend
			tb = tb->next
		wend
	end if
end sub

public sub  fb_hPROFILER_METRICS_HashTable( byval metrics as FB_PROFILER_METRICS ptr, byval hash as STRING_HASH_TABLE ptr )
	dim as STRING_HASH_TB ptr tb = any
	if( (metrics <> NULL) andalso (hash <> NULL) ) then
		tb = hash->tb
		while( tb )
			metrics->hash_bytes_allocated += sizeof( STRING_HASH_TB )
			metrics->hash_count_blocks += 1

			for i as integer = 0 to STRING_HASH_TB_SIZE-1
				if( tb->items(i) ) then
					metrics->hash_count_items += 1
				end if
				metrics->hash_count_slots += 1

			next
			tb = tb->next
		wend
	end if
end sub

public sub fb_hPROFILER_METRICS_Global( byval metrics as FB_PROFILER_METRICS ptr, byval global as FB_PROFILER_GLOBAL ptr )
	fb_hPROFILER_METRICS_Strings( metrics, @global->strings )
	fb_hPROFILER_METRICS_HashTable( metrics, @global->strings_hash )
	fb_hPROFILER_METRICS_HashTable( metrics, @global->ignores_hash )
end sub

'' ************************************
'' Profiling
''

public function PROFILER_GLOBAL_create( ) as FB_PROFILER_GLOBAL ptr
	if( fb_profiler ) then
		return fb_profiler
	end if

	fb_profiler = PROFILER_calloc( 1, sizeof( FB_PROFILER_GLOBAL ) )
	if( fb_profiler ) then
		dim as time_t rawtime
		dim as tm ptr ptm

		STRING_TABLE_constructor( @fb_profiler->strings )
		STRING_HASH_TABLE_constructor( @fb_profiler->strings_hash, @fb_profiler->strings )
		STRING_HASH_TABLE_constructor( @fb_profiler->ignores_hash, @fb_profiler->strings )
		fb_profiler->filename[0] = 0
		fb_profiler->launch_time[0] = 0

		time_( @rawtime )
		ptm = localtime( @rawtime )
		snprintf( fb_profiler->launch_time, sizeof(fb_profiler->launch_time), _
			!"%02d-%02d-%04d, %02d:%02d:%02d", _
			clng((1+ptm->tm_mon)) mod 100u, clng(ptm->tm_mday) mod 100u, clng(1900+ptm->tm_year) mod 100u, _
			clng(ptm->tm_hour) mod 100u, clng(ptm->tm_min) mod 100u, clng(ptm->tm_sec) mod 100u )
		fb_profiler->launch_time[sizeof(fb_profiler->launch_time)-1] = 0
	end if
	return fb_profiler
end function

public sub PROFILER_GLOBAL_destroy( )
	if( fb_profiler ) then
		STRING_HASH_TABLE_destructor( @fb_profiler->strings_hash )
		STRING_HASH_TABLE_destructor( @fb_profiler->ignores_hash )
		STRING_TABLE_destructor( @fb_profiler->strings )
		PROFILER_free( fb_profiler )
		fb_profiler = NULL
	end if
end sub

'' ************************************
'' Profiling Options
''

private function hProfileCopyFilename( byval dst as zstring ptr, byval src as const zstring ptr, byval length as long ) as long
	dim as long len_ = any

	if( (fb_profiler = NULL) orelse (dst = NULL) orelse (src = NULL) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	len_ = strlen(src)

	if( (len_ < 1) orelse (len_ >= PROFILER_MAX_PATH-1) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	strncpy( dst, src, length )
	dst[length-1] = asc(!"\0")

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

'':::::
public function fb_ProfileSetFileName FBCALL ( byval filename as const zstring ptr ) as long
	dim as long ret = any

	FB_PROFILE_LOCK()

	if( (fb_profiler <> NULL) andalso (filename <> NULL) ) then
		ret = hProfileCopyFilename( fb_profiler->filename, filename, PROFILER_MAX_PATH )
	else
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_PROFILE_UNLOCK()

	return ret
end function

'':::::
public function fb_ProfileGetFileName FBCALL ( byval filename as zstring ptr, byval length as long ) as long
	dim as long ret = any

	FB_PROFILE_LOCK()

	if( (fb_profiler <> NULL) andalso (filename <> NULL) andalso (length > 0) ) then
		dim as zstring * PROFILER_MAX_PATH buffer_data = any
		dim as zstring ptr buffer = @buffer_data, fname = any
		if( fb_profiler->filename[0] ) then
			fname = @fb_profiler->filename
		else
			fname = fb_hGetExeName( buffer, PROFILER_MAX_PATH-1 )
			if( fname ) then
				strcat( buffer, DEFAULT_PROFILE_EXT )
				fname = buffer
			else
				fname = @DEFAULT_PROFILE_FILE
			end if
		end if
		ret = hProfileCopyFilename( filename, fname, length )
	else
		ret = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_PROFILE_UNLOCK()

	return ret
end function

'':::::
public function fb_ProfileGetOptions FBCALL () as long
	dim as long options = 0

	FB_PROFILE_LOCK()

	if( fb_profiler ) then
		options = fb_profiler->options
	end if

	FB_PROFILE_UNLOCK()

	return options
end function

'':::::
public function fb_ProfileSetOptions FBCALL ( byval options as long ) as long
	dim as long previous_options = 0

	FB_PROFILE_LOCK()

	if( fb_profiler ) then
		previous_options = fb_profiler->options
		fb_profiler->options = options
	end if

	FB_PROFILE_UNLOCK()

	return previous_options
end function

'':::::
public sub fb_ProfileIgnore FBCALL ( byval procname as const zstring ptr  )
	FB_PROFILE_LOCK()

	if( (fb_profiler <> NULL) andalso (procname <> NULL) ) then
		dim as ulong hashkey = any
		hashkey = fb_ProfileHashName( procname )
		PROFILER_add_ignore( fb_profiler, procname, hashkey )
	end if

	FB_PROFILE_UNLOCK()
end sub

'':::::
public function fb_ProfileGetGlobalProfiler FBCALL () as FB_PROFILER_GLOBAL ptr
	return fb_profiler
end function

end extern
