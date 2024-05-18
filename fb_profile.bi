'' reporting options

#ifdef fb_InitProfile
	#undef fb_InitProfile
	#undef fb_EndProfile

	#undef fb_ProfileBeginProc
	#undef fb_ProfileEndProc
	#undef fb_ProfileBeginCall
	#undef fb_ProfileEndCall

	#undef fb_InitProfileCycles
	#undef fb_EndProfileCycles
#endif

extern "C"

enum PROFILE_OPTIONS
	PROFILE_OPTION_REPORT_DEFAULT    = &h00000000
	PROFILE_OPTION_REPORT_CALLS      = &h00000001
	PROFILE_OPTION_REPORT_CALLTREE   = &h00000002
	PROFILE_OPTION_REPORT_RAWLIST    = &h00000004
	PROFILE_OPTION_REPORT_RAWDATA    = &h00000008
	PROFILE_OPTION_REPORT_RAWSTRINGS = &h00000010

	PROFILE_OPTION_REPORT_MASK       = &h000000FF

	PROFILE_OPTION_HIDE_HEADER       = &h00000100
	PROFILE_OPTION_HIDE_TITLES       = &h00000200
	PROFILE_OPTION_HIDE_COUNTS       = &h00000400
	PROFILE_OPTION_HIDE_TIMES        = &h00000800
	PROFILE_OPTION_HIDE_FUNCTIONS    = &h00001000
	PROFILE_OPTION_HIDE_GLOBALS      = &h00002000

	PROFILE_OPTION_SHOW_DEBUGGING    = &h01000000
	PROFILE_OPTION_GRAPHICS_CHARS    = &h02000000
end enum

'' ************************************
'' Memory Allocation
''

#define PROFILER_malloc( size )       allocate( size )
#define PROFILER_calloc( n, size )    callocate( n, size )
#define PROFILER_realloc( ptr, size ) reallocate( ptr, size )
#define PROFILER_free( ptr )          deallocate( ptr )

'' ************************************
'' CONFIG
''

#define PROFILER_MAX_PATH      1024
#define MAIN_PROC_NAME         !"(main)"
#define THREAD_PROC_NAME       !"(thread)"
#define UNNAMED_PROC_NAME      !"(unnamed)"
#define DEFAULT_PROFILE_FILE   !"profile.txt"
#define DEFAULT_PROFILE_EXT    !".prf"
#define STRING_INFO_TB_SIZE    10240
#define STRING_HASH_TB_SIZE    997
#define PROC_MAX_CHILDREN      257
#define PROC_INFO_TB_SIZE      1024
#define PROC_HASH_TB_SIZE      257

#if defined( __FB_UNIX__ )
#define PROFILER_PATH_SEP      !"/"
#else
#define PROFILER_PATH_SEP      !"\\"
#endif

'' String Storage

'' information about a single string
type STRING_INFO
	as long  size
	as long  length
	as ulong hashkey
end type

'' block of memory to store strings
type STRING_INFO_TB
	as ubyte data(0 to STRING_INFO_TB_SIZE-1)
	as STRING_INFO_TB ptr next
	as long bytes_used
	as long string_tb_id
end type

'' first block in a list of string storage blocks
type STRING_TABLE
	as STRING_INFO_TB ptr tb
end type

'' block of memory for hashes
type STRING_HASH_TB
	as STRING_INFO ptr items(0 to STRING_HASH_TB_SIZE-1)
	as STRING_HASH_TB ptr next
end type

'' first block of memory for hashes and associated string table
type STRING_HASH_TABLE
	as STRING_TABLE ptr strings
	as STRING_HASH_TB ptr tb
end type

'' hash table for strings
type STRING_HASH
	as STRING_HASH_TABLE ptr strings_hash
	as STRING_HASH_TABLE hash
end type

declare function fb_ProfileHashName( byval p as const zstring ptr ) as ulong

declare function STRING_TABLE_alloc( byval strings as STRING_TABLE ptr, byval length as long ) as STRING_INFO ptr
declare sub          STRING_TABLE_constructor( byval strings as STRING_TABLE ptr )
declare sub          STRING_TABLE_destructor( byval strings as STRING_TABLE ptr )
declare function     STRING_TABLE_add( byval strings as STRING_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
declare function     STRING_TABLE_max_len( byval strings as STRING_TABLE ptr ) as long
declare function     STRING_HASH_TB_find( byval tb as STRING_HASH_TB ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
declare function     STRING_HASH_TABLE_find( byval hash as STRING_HASH_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
declare sub          STRING_HASH_TABLE_constructor( byval hash as STRING_HASH_TABLE ptr, byval strings as STRING_TABLE ptr )
declare sub          STRING_HASH_TABLE_destructor( byval hash as STRING_HASH_TABLE ptr )
declare function     STRING_HASH_TABLE_add( byval hash as STRING_HASH_TABLE ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr
declare function     STRING_HASH_TABLE_add_info( byval hash as STRING_HASH_TABLE ptr, byval new_indo as STRING_INFO ptr ) as STRING_INFO ptr
declare sub          STRING_HASH_constructor( byval hash as STRING_HASH ptr, byval strings_hash as STRING_HASH_TABLE ptr )
declare sub          STRING_HASH_destructor( byval hash as STRING_HASH ptr )
declare sub          STRING_HASH_add( byval hash as STRING_HASH ptr, byval src as const zstring ptr, byval hashkey as ulong )
declare function STRING_HASH_find( byval hash as STRING_HASH ptr, byval src as const zstring ptr, byval hashkey as ulong ) as STRING_INFO ptr

'' ************************************
'' Public API
''

'' global profiler state
'' use FB_PROFILE_LOCK()/FB_PROFILE_UNLOCK when accessing
type FB_PROFILER_GLOBAL
	as any ptr profiler_ctx
	as STRING_TABLE strings
	as STRING_HASH_TABLE strings_hash
	as STRING_HASH_TABLE ignores_hash
	as zstring * PROFILER_MAX_PATH filename
	as zstring * 32 launch_time
	as long options '' PROFILE_OPTIONS
end type

'' information about the profiler internals
type FB_PROFILER_METRICS
	as long count_threads

	as long string_bytes_allocated
	as long string_bytes_used
	as long string_bytes_free
	as long string_count_blocks
	as long string_count_strings
	as long string_max_len

	as long hash_bytes_allocated
	as long hash_count_blocks
	as long hash_count_items
	as long hash_count_slots

	as long procs_bytes_allocated
	as long procs_count_blocks
	as long procs_count_items
	as long procs_count_slots
end type

'' calls profiler

declare sub      fb_InitProfile FBCALL ( )
declare function fb_EndProfile FBCALL ( byval errorlevel as long ) as long

declare function fb_ProfileBeginProc FBCALL ( byval procname as const zstring ptr ) as any ptr
declare sub      fb_ProfileEndProc   FBCALL ( byval callid as any ptr )
declare function fb_ProfileBeginCall FBCALL ( byval procname as const zstring ptr ) as any ptr
declare sub      fb_ProfileEndCall   FBCALL ( byval callid as any ptr )

'' cycles profiles

declare sub      fb_InitProfileCycles FBCALL ( )
declare function fb_EndProfileCycles FBCALL ( byval errorlevel as long ) as long

'' global profiler

declare function fb_ProfileGetGlobalProfiler FBCALL () as FB_PROFILER_GLOBAL ptr

declare function fb_ProfileSetFileName FBCALL ( byval filename as const zstring ptr ) as long
declare function fb_ProfileGetFileName FBCALL ( byval filename as zstring ptr, byval length as long ) as long
declare function fb_ProfileGetOptions FBCALL () as long
declare function fb_ProfileSetOptions FBCALL ( byval options as long ) as long
declare sub      fb_ProfileIgnore FBCALL ( byval procname as const zstring ptr )
declare sub      fb_ProfileGetMetrics FBCALL ( byval metrics as FB_PROFILER_METRICS ptr )

'' ************************************
'' Internals
''

declare function PROFILER_GLOBAL_create( ) as FB_PROFILER_GLOBAL ptr
declare sub PROFILER_GLOBAL_destroy( )

declare function PROFILER_add_ignore( byval prof as FB_PROFILER_GLOBAL ptr, byval src as const zstring ptr, byval hashkey as ulong ) as zstring ptr
declare sub fb_hPROFILER_METRICS_Clear( byval metrics as FB_PROFILER_METRICS ptr )
declare sub fb_hPROFILER_METRICS_Strings( byval metrics as FB_PROFILER_METRICS ptr, byval strings as STRING_TABLE ptr )
declare sub fb_hPROFILER_METRICS_HashTable( byval metrics as FB_PROFILER_METRICS ptr, byval hash as STRING_HASH_TABLE ptr )
declare sub fb_hPROFILER_METRICS_Global( byval metrics as FB_PROFILER_METRICS ptr, byval global as FB_PROFILER_GLOBAL ptr )

end extern
