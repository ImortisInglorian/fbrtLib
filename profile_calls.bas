''
'' profile.c -- profiling functions
''
'' chng: apr/2005 written [lillo]
''       may/2005 rewritten to properly support recursive calls [lillo]
''       apr/2024 use thread local storage (wip) [jeffm]
''       apr/2024 add call counting [jeffm]
''       apr/2024 dynamic string table [jeffm]
''       apr/2024 remove NUL character padding requirement [jeffm]
''       apr/2024 add API to set output file name and report options [jeffm]
''       apr/2024 add profiler lock (replacing fb lock) [jeffm]
''       apr/2024 add calltree report and API to ignore procedures [jeffm]
''       may/2024 instance profiler on each thread [jeffm]
''

'' TODO: disambiguate private procedures by module name
'' TODO: function pointer testing and reporting
'' TODO: test the start-up and exit code more
'' TODO: demangle procedure names
'' TODO: split calls profiler to separate module
'' TODO: allow cycles profiler to use global settings

#include "fb.bi"
#include "fb_profile.bi"

#include "crt/time.bi"
#include "fb_private_thread.bi"

/' choose a suitable 64-bit decimal printf specifier '/
#if not defined(fmtlld)
	#if defined(PRId64)
		#define fmtlld PRId64
	#elif defined(FB_LL_FMTMOD) 
		#define fmtlld ("%12" + FB_LL_FMTMOD + "d")
	#else
		#define fmtlld "%12lld"
	#endif
#endif

extern "C"

'' procs

'' extra information about procinfo entry
enum PROCINFO_FLAGS
	PROCINFO_FLAGS_NONE     = 0
	PROCINFO_FLAGS_MAIN     = 1
	PROCINFO_FLAGS_THREAD   = 2
	PROCINFO_FLAGS_CALLPTR  = 4
	PROCINFO_FLAGS_FOREIGN  = 8
end enum

'' procedure call information, and hash table for child procedures
type FB_PROCINFO
	as const zstring ptr name
	as FB_PROCINFO ptr parent
	as double start_time
	as double local_time
	as longint local_count
	as ulong hashkey
	as long proc_id
	as FB_PROCINFO ptr child(0 to PROC_MAX_CHILDREN-1)
	as FB_PROCINFO ptr next
	as long flags
end type

'' block of memory to store procedure call information records
type FB_PROCINFO_TB
	as FB_PROCINFO procinfo(0 to PROC_INFO_TB_SIZE-1)
	as FB_PROCINFO_TB ptr next
	as long next_free
	as long procinfo_tb_id
end type

'' hash table block for procedures
type PROC_HASH_TB
	as FB_PROCINFO ptr proc(0 to PROC_HASH_TB_SIZE-1)
	as PROC_HASH_TB ptr next
end type

'' array of procinfo entries and associated hash tables
type FB_PROCARRAY
	as FB_PROCINFO ptr ptr array
	as STRING_HASH hash
	as STRING_HASH_TABLE ptr ignores
	as long length
	as long size
end type

'' profiler

'' context for thread local storage

type FB_PROFILER_THREAD
	as FB_PROCINFO ptr thread_entry
	as FB_PROCINFO ptr thread_proc
	as STRING_TABLE strings
	as STRING_HASH_TABLE strings_hash
	as FB_PROCINFO_TB ptr proc_tb
	as FB_PROFILER_THREAD ptr next
	as long last_proc_id
end type

type FB_PROFILECTX
	as FB_PROFILER_THREAD ptr ctx
end type

'' calls profiler global context
'' use FB_PROFILE_LOCK()/FB_PROFILE_UNLOCK when accessing
type FB_PROFILER_CALLS
	as FB_PROFILER_GLOBAL ptr global
	as FB_PROFILER_THREAD ptr main_thread
	as FB_PROFILER_THREAD ptr threads
	as FBSTRING calltree_leader
end type

end extern

declare sub PROFILECTX_Destructor ( byval ctx as any ptr )
declare function fb_get_thread_profilectx ( ) as FB_PROFILECTX ptr

extern "C"

'' ************************************
'' Globals
''

dim shared as FB_PROFILER_CALLS ptr fb_profiler = NULL

'' ************************************
'' strings
''

private function PROFILER_THREAD_add_string( byval ctx as FB_PROFILER_THREAD ptr, byval src as const zstring ptr, byval hashkey as ulong ) as zstring ptr
	dim as STRING_INFO ptr info = STRING_HASH_TABLE_add( @ctx->strings_hash, src, hashkey )
	return cast(zstring ptr,info+1)
end function

'' ************************************
'' procs
''

private sub FB_PROCINFO_TB_destructor( byval tb as FB_PROCINFO_TB ptr )
	while ( tb )
		dim as FB_PROCINFO_TB ptr nxt = tb->next
		PROFILER_free( tb )
		tb = nxt
	wend
end sub

private function FB_PROCINFO_TB_alloc_proc( byval proc_tb as FB_PROCINFO_TB ptr ptr ) as FB_PROCINFO ptr
	dim as FB_PROCINFO_TB ptr tb = any
	dim as FB_PROCINFO ptr proc = any

	if( ( (*proc_tb) = NULL ) orelse ( (*proc_tb)->next_free >= PROC_INFO_TB_SIZE ) ) then
		tb = cast(FB_PROCINFO_TB ptr, PROFILER_calloc( 1, sizeof(FB_PROCINFO_TB) ))
		tb->next = (*proc_tb)
		tb->procinfo_tb_id = iif((*proc_tb), (*proc_tb)->procinfo_tb_id, 0) + 1
		(*proc_tb) = tb
	end if

	proc = @(*proc_tb)->procinfo((*proc_tb)->next_free)
	(*proc_tb)->next_free += 1

	return proc
end function

private function FB_PROFILER_THREAD_alloc_proc( byval ctx as FB_PROFILER_THREAD ptr ) as FB_PROCINFO ptr
	return FB_PROCINFO_TB_alloc_proc( @ctx->proc_tb )
end function

'' ************************************
'' Proc Arrays
''

private sub PROCARRAY_constructor( byval list as FB_PROCARRAY ptr, byval strings_hash as STRING_HASH_TABLE ptr, byval ignores as STRING_HASH_TABLE ptr )
	list->array = NULL
	list->size = 0
	list->length = 0
	STRING_HASH_constructor( @list->hash, strings_hash )
	list->ignores = ignores
end sub

private sub PROCARRAY_destructor( byval list as FB_PROCARRAY ptr )
	STRING_HASH_destructor( @list->hash )
	PROFILER_free( list->array )
	list->array = NULL
	list->size = 0
	list->length = 0
	list->ignores = NULL
end sub

private function PROCARRAY_name_sorter( byval e1 as const any ptr, byval e2 as const any ptr ) as long
	dim as FB_PROCINFO ptr p1 = *cast(FB_PROCINFO ptr ptr, e1)
	dim as FB_PROCINFO ptr p2 = *cast(FB_PROCINFO ptr ptr, e2)

	if( (p1->parent <> NULL) andalso (p2->parent <> NULL ) ) then
		return strcmp( p1->name, p2->name )
	elseif( (p1->parent = NULL) andalso (p2->parent <> NULL ) ) then
		return -1
	elseif( (p1->parent <> NULL) andalso (p2->parent = NULL) ) then
		return 1
	else
		return 0
	end if
end function

private sub PROCARRAY_sort_by_name( byval list as FB_PROCARRAY ptr )
	qsort( list->array, list->length, sizeof(FB_PROCINFO ptr), procptr(PROCARRAY_name_sorter) )
end sub

private function PROCARRAY_time_sorter( byval e1 as const any ptr, byval e2 as const any ptr ) as long
	dim as FB_PROCINFO ptr p1 = *cast(FB_PROCINFO ptr ptr, e1)
	dim as FB_PROCINFO ptr p2 = *cast(FB_PROCINFO ptr ptr, e2)

	if( p1->local_time > p2->local_time ) then
		return -1
	elseif( p1->local_time < p2->local_time ) then
		return 1
	else
		return 0
	end if
end function

private sub PROCARRAY_sort_by_time( byval list as FB_PROCARRAY ptr )
	qsort( list->array, list->length, sizeof(FB_PROCINFO ptr), procptr(PROCARRAY_time_sorter) )
end sub

private sub PROCARRAY_add( byval list as FB_PROCARRAY ptr, byval proc as FB_PROCINFO ptr )
	dim as FB_PROCINFO ptr ptr new_array = NULL
	dim as long s = list->size

	if( s = 0 ) then
		s = 16
		new_array = cast( FB_PROCINFO ptr ptr, PROFILER_malloc( s * sizeof(FB_PROCINFO ptr) ) )
	elseif( list->length = s ) then
		s *= 2
		new_array = cast( FB_PROCINFO ptr ptr, PROFILER_realloc( list->array, s * sizeof(FB_PROCINFO ptr) ) )
	else
		new_array = list->array
	end if

	if( new_array ) then
		new_array[list->length] = proc
		list->array = new_array
		list->size = s
		list->length += 1
		STRING_HASH_add( @list->hash, proc->name, proc->hashkey )
	end if
end sub

private sub PROCARRAY_find_all_procs( byval list as FB_PROCARRAY ptr, byval proc_tb as FB_PROCINFO_TB ptr )
	dim as FB_PROCINFO_TB ptr tb = proc_tb
	dim as FB_PROCINFO ptr proc = any
	dim as long i = any

	while( tb )
		for i = 0 to tb->next_free - 1
			proc = @tb->procinfo(i)
			if( STRING_HASH_TABLE_find( list->ignores, proc->name, proc->hashkey ) = NULL) then
				PROCARRAY_add( list, proc )
			end if
		next
		tb = tb->next
	wend
end sub

private sub PROCARRAY_find_unique_procs( byval list as FB_PROCARRAY ptr, byval proc_tb as FB_PROCINFO_TB ptr )
	dim as FB_PROCINFO_TB ptr tb = proc_tb
	dim as FB_PROCINFO ptr proc = any
	dim as long i = any

	while( tb )
		for i = 0 to tb->next_free - 1
			proc = @tb->procinfo(i)
			if( STRING_HASH_TABLE_find( list->ignores, proc->name, proc->hashkey ) = NULL) then
				if( STRING_HASH_find( @list->hash, proc->name, proc->hashkey ) = NULL ) then
					PROCARRAY_add( list, proc )
				end if
			end if
		next
		tb = tb->next
	wend
end sub

'' ************************************
'' Profile Thread Context
''

end extern

private sub PROFILER_THREAD_constructor( byval ctx as FB_PROFILER_THREAD ptr )
	if( ctx ) then
		ctx->thread_entry = NULL
		ctx->thread_proc = NULL
		STRING_TABLE_constructor( @ctx->strings )
		STRING_HASH_TABLE_constructor( @ctx->strings_hash, @ctx->strings )
		ctx->proc_tb = NULL
		ctx->next = NULL
		ctx->last_proc_id = 0
	end if
end sub

private sub FB_PROFILECTX_constructor( byval tls as FB_PROFILECTX ptr )
	if( tls->ctx = NULL ) then
		tls->ctx = cast(FB_PROFILER_THREAD ptr, PROFILER_calloc(1, sizeof(FB_PROFILER_THREAD)))
		PROFILER_THREAD_constructor( tls->ctx )
	end if
end sub

private sub PROFILECTX_Destructor ( byval data_ as any ptr )
	dim as FB_PROFILECTX ptr tls = cast(FB_PROFILECTX ptr, data_ )
	if( tls ) then
		dim as FB_PROFILER_THREAD ptr ctx = tls->ctx
		if( ctx ) then
			dim as FB_PROCINFO ptr lastproc = any

			'' walk the call stack and update times
			'' calculate time even if the thread ends from a called procedure
			lastproc = ctx->thread_proc
			while( lastproc )
				lastproc->local_time = fb_Timer() - lastproc->start_time
				lastproc =  lastproc->parent
			wend

			'' don't actually delete the data, just
			'' add it to the main profiler state
			if( fb_profiler ) then
				FB_PROFILE_LOCK()
				ctx->next = fb_profiler->threads
				fb_profiler->threads = ctx
				FB_PROFILE_UNLOCK()
			end if
		end if
	end if
end sub

function fb_get_thread_profilectx ( ) as FB_PROFILECTX ptr
	dim thread As FBThread ptr = fb_GetCurrentThread( )
	dim ctx As FB_PROFILECTX ptr = cast( FB_PROFILECTX ptr, thread->GetData( FB_TLSKEY_PROFILE) )
		if( ctx = NULL ) then
		ctx = New FB_PROFILECTX
		thread->SetData( FB_TLSKEY_PROFILE, ctx, procptr( PROFILECTX_destructor ) )
		end if
	return ctx

end function

extern "C"

'' ************************************
'' Profiler Metrics (internal stats)
''

private sub  fb_hPROFILER_METRICS_Procs( byval metrics as FB_PROFILER_METRICS ptr, byval proc_tb as FB_PROCINFO_TB ptr )
	dim as FB_PROCINFO_TB ptr tb = any
	if( (metrics <> NULL) andalso (proc_tb <> NULL) ) then
		tb = proc_tb
		while( tb )
			metrics->procs_bytes_allocated += sizeof( FB_PROCINFO_TB )
			metrics->procs_count_blocks += 1

			for i as integer = 0 to PROC_INFO_TB_SIZE-1
				if( tb->procinfo(i).name ) then
					metrics->procs_count_items += 1
				end if
				metrics->procs_count_slots += 1

			next
			tb = tb->next
		wend
	end if
end sub

private sub fb_hPROFILER_METRICS_Threads( byval metrics as FB_PROFILER_METRICS ptr, byval ctx as FB_PROFILER_THREAD ptr )
	if( (metrics <> NULL) andalso (ctx <> NULL) ) then
		metrics->count_threads += 1
		fb_hPROFILER_METRICS_Strings( metrics, @ctx->strings )
		fb_hPROFILER_METRICS_HashTable( metrics, @ctx->strings_hash )
		fb_hPROFILER_METRICS_Procs( metrics, ctx->proc_tb )
	end if
end sub

private sub fb_hPROFILER_METRICS_CallsProfiler( byval metrics as FB_PROFILER_METRICS ptr, byval prof as FB_PROFILER_CALLS ptr )
	dim as FB_PROFILER_THREAD ptr ctx = any

	if( (prof = NULL) orelse (metrics = NULL) ) then
		return
	end if

	fb_hPROFILER_METRICS_Clear( metrics )
	fb_hPROFILER_METRICS_Global( metrics, prof->global )
	fb_hPROFILER_METRICS_Threads( metrics, prof->main_thread )

	ctx = prof->threads
	while( ctx )
		fb_hPROFILER_METRICS_Threads( metrics, ctx )
		ctx = ctx->next
	wend
end sub

'' ************************************
'' Profiling
''

public function PROFILER_CALLS_create( ) as FB_PROFILER_CALLS ptr
	if( fb_profiler = NULL ) then
		dim as FB_PROFILER_CALLS ptr prof = any
		prof = PROFILER_calloc( 1, sizeof( FB_PROFILER_CALLS ) )
		if( prof ) then
			prof->global = PROFILER_GLOBAL_create( )
			if( prof->global ) then
				prof->global->profiler_ctx = cast(any ptr, prof)
				prof->calltree_leader.data = NULL
				prof->calltree_leader.size = 0
				prof->calltree_leader.len = 0
				fb_profiler = prof
			else
				PROFILER_free( prof )
			end if
		end if
	end if
	return fb_profiler
end function

public sub PROFILER_CALLS_destroy(  )

	if( fb_profiler ) then
		PROFILER_free( fb_profiler->calltree_leader.data )

		while( fb_profiler->threads )
			dim as FB_PROFILER_THREAD ptr nxt_ctx = any

			FB_PROCINFO_TB_destructor( fb_profiler->threads->proc_tb )
			STRING_HASH_TABLE_destructor( @fb_profiler->threads->strings_hash )
			STRING_TABLE_destructor( @fb_profiler->threads->strings )

			nxt_ctx = fb_profiler->threads->next
			PROFILER_free( fb_profiler->threads )
			fb_profiler->threads = nxt_ctx
		wend

		PROFILER_GLOBAL_destroy( )

		PROFILER_free( fb_profiler )
		fb_profiler = NULL
	end if
end sub

private function PROFILER_new_proc_id( byval ctx as FB_PROFILER_THREAD ptr ) as long
	ctx->last_proc_id += 1
	return ctx->last_proc_id
end function

'' ************************************
'' REPORT GENERATION
''

private sub pad_spaces( byval f as FILE ptr, byval len_ as long )
	while( len_ > 0 )
		fprintf( f, !" " )
		len_ -= 1
	wend
end sub

private sub pad_section( byval f as FILE ptr )
	static as boolean started = false
	if( started ) then
		fprintf( f, !"\n\n" )
	else
		started = true
	end if
end sub

'' PROFILE_OPTION_REPORT_CALLS
private sub hProfilerReportCallsProc _
	( _
		byval prof as FB_PROFILER_CALLS ptr, byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr, _
		byval parent_proc as FB_PROCINFO ptr, byval col as long _
	)
	dim as FB_PROCINFO ptr proc = any
	dim as FB_PROCARRAY proc_list = any
	dim as long j = any, len_ = any

	PROCARRAY_constructor( @proc_list, @prof->global->strings_hash, @prof->global->ignores_hash )

	proc = parent_proc
	while( proc )
		for j = 0 to PROC_MAX_CHILDREN - 1
			if( proc->child(j) ) then
				if( STRING_HASH_TABLE_find( proc_list.ignores, proc->child(j)->name, proc->child(j)->hashkey ) = 0 ) then
					PROCARRAY_add( @proc_list, proc->child(j) )
				end if
			end if
		next
		proc = proc->next
	wend

	if( proc_list.length > 0 ) then

		if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
			if( (parent_proc->flags and PROCINFO_FLAGS_THREAD) <> 0 ) then
				fprintf( f, !"(thread)\n" )
			end if
		end if

		len_ = col - (fprintf( f, !"%s", parent_proc->name ) )
		pad_spaces( f, len_ )

		if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
			len_ = 14 - fprintf( f, fmtlld, parent_proc->local_count )
			pad_spaces( f, len_ )
		end if

		if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
			len_ = 14 - fprintf( f, !"%10.5f", parent_proc->local_time )
			pad_spaces( f, len_ )

			fprintf( f, !"%6.2f%%", (parent_proc->local_time * 100.0) / ctx->thread_entry->local_time )
		end if

		fprintf( f, !"\n\n" )

		PROCARRAY_sort_by_time( @proc_list )

		for j = 0 to proc_list.length - 1
			proc = proc_list.array[j]

			len_ = col - fprintf( f, !"        %s", proc->name )
			pad_spaces( f, len_ )

			if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
				len_ = 14 - fprintf( f, fmtlld, proc->local_count )
				pad_spaces( f, len_ )
			end if

			if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
				len_ = 14 - fprintf( f, !"%10.5f", proc->local_time )
				pad_spaces( f, len_ )

				len_ = 10 - fprintf( f, !"%6.2f%%", ( proc->local_time * 100.0 ) / ctx->thread_entry->local_time )
				pad_spaces( f, len_ )

				fprintf( f, !"%6.2f%%", iif( parent_proc->local_time > 0.0, _
					( proc->local_time * 100.0 ) /parent_proc->local_time, 0.0 ) )
			end if

			fprintf( f, !"\n" )
		next

		fprintf( f, !"\n" )
	end if

	PROCARRAY_destructor( @proc_list )
end sub

private function hProcIsRecursive( byval proc as FB_PROCINFO ptr ) as long
	dim as FB_PROCINFO ptr p = proc
	if( p ) then
		p = p->parent
		while( p )
			if( (p->hashkey = proc->hashkey) andalso (strcmp( p->name, proc->name ) = 0) ) then
				return TRUE
			end if
			p = p->parent
		wend
	end if
	return FALSE
end function

private sub hProfilerReportCallsFunctions _
	( _
		byval prof as FB_PROFILER_CALLS ptr, byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as FB_PROCARRAY list = any
	dim as long i = any, len_ = any
	dim as long max_len = STRING_TABLE_max_len( @ctx->strings )
	dim as long col = iif(max_len + 8 + 1 >= 20, max_len + 8 + 1, 20)

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"Per function results:\n\n" )
		len_ = col - fprintf( f, !"        Function:" )
		pad_spaces( f, len_ )

		if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
			fprintf( f, !"      Count:  " )
		end if

		if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
			fprintf( f, !"     Time:    " )
			fprintf( f, !"Total%%:    " )
			fprintf( f, !"Proc%%:" )
		end if

		fprintf( f, !"\n\n" )
	end if

	PROCARRAY_constructor( @list, @prof->global->strings_hash, @prof->global->ignores_hash )

	PROCARRAY_find_unique_procs( @list, ctx->proc_tb )
	PROCARRAY_sort_by_name( @list )
	for i = 0 to list.length - 1
		hProfilerReportCallsProc( prof, ctx, f, list.array[i], col )
	next

	PROCARRAY_destructor( @list )
end sub

private sub hProfilerReportCallsGlobals _
	( _
		byval prof as FB_PROFILER_CALLS ptr, byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as FB_PROCINFO_TB ptr tb = any
	dim as FB_PROCARRAY list_all = any, list = any
	dim as FB_PROCINFO ptr last_p = any
	dim as long i = any, len_ = any
	dim as long max_len = STRING_TABLE_max_len( @ctx->strings )
	dim as long col = iif(max_len + 8 + 1 >= 20, max_len + 8 + 1, 20)

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"Global results:\n\n" )
	end if

	PROCARRAY_constructor( @list, @prof->global->strings_hash, @prof->global->ignores_hash )

	PROCARRAY_constructor( @list_all, @prof->global->strings_hash, @prof->global->ignores_hash )
	PROCARRAY_find_all_procs( @list_all, ctx->proc_tb )
	PROCARRAY_sort_by_name( @list_all )

	tb = NULL
	last_p = NULL
	for i = 0 to list_all.length - 1
		dim as FB_PROCINFO ptr p = any, q = any
		q = list_all.array[i]

		if( (last_p = 0 ) orelse (last_p->hashkey <> q->hashkey) orelse (strcmp(last_p->name, q->name) <> 0) ) then
			p = FB_PROCINFO_TB_alloc_proc( @tb )
			if( p ) then
				p->name = q->name
				p->hashkey = q->hashkey
				if( hProcIsRecursive( q ) = 0 ) then
					p->local_time = q->local_time
				else
					p->local_time = 0
				end if
				p->local_count = q->local_count
				PROCARRAY_add( @list, p )
			end if
			last_p = p
		else
			if( hProcIsRecursive( q ) = FALSE ) then
				last_p->local_time += q->local_time
			end if
			last_p->local_count += q->local_count
		end if
	next

	for i = 0 to list.length - 1
		dim as FB_PROCINFO ptr proc = list.array[i]
		len_ = col - fprintf( f, !"%s", proc->name )
		pad_spaces( f, len_ )

		if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
			len_ = 14 - fprintf( f, fmtlld, proc->local_count )
			pad_spaces( f, len_ )
		end if

		if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
			len_ = 14 - fprintf( f, !"%10.5f", proc->local_time )
			pad_spaces( f, len_ )

			len_ = 10 - fprintf( f, !"%6.2f%%", ( proc->local_time * 100.0 ) / ctx->thread_entry->local_time )
		end if

		fprintf( f, !"\n" )
	next

	FB_PROCINFO_TB_destructor( tb )
	PROCARRAY_destructor( @list )
	PROCARRAY_destructor( @list_all )
end sub

'' PROFILE_OPTION_REPORT_CALLTREE
private sub hPushLeader( byval prof as FB_PROFILER_CALLS ptr, byval ch as long )
	if( (prof->calltree_leader.data = NULL) orelse _
	    (prof->calltree_leader.len + 4 > prof->calltree_leader.size) ) then

		dim as ssize_t newsize = iif( prof->calltree_leader.size, prof->calltree_leader.size * 2, 64 )
		dim as zstring ptr newbuffer = cast(zstring ptr, realloc( prof->calltree_leader.data, newsize ))
		if( newbuffer = NULL ) then
			return
		end if
		prof->calltree_leader.data = newbuffer
		prof->calltree_leader.size = newsize
	end if

	if( prof->calltree_leader.len + 4 > prof->calltree_leader.size ) then
		return
	end if

	if( ch ) then
		prof->calltree_leader.data[prof->calltree_leader.len] = ch
		prof->calltree_leader.len += 1
	end if
	prof->calltree_leader.data[prof->calltree_leader.len] = 0
end sub

private sub hPopLeader( byval prof as FB_PROFILER_CALLS ptr )
	if( prof->calltree_leader.data ) then
		if( prof->calltree_leader.len >= 3 ) then
			prof->calltree_leader.len -= 3
		end if
		prof->calltree_leader.data[prof->calltree_leader.len] = 0
	else
		prof->calltree_leader.len = 0
	end if
end sub

private sub hProfilerReportCallTreeProc _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr, _
		byval proc as FB_PROCINFO ptr, byval isfirst as long, byval islast as long _
	)

	static as ubyte asc_chars(0 to 3) = { asc(!"|"), asc(!"-"), asc(!"|"), asc(!"\\") }
	static as ubyte gfx_chars(0 to 3) = { 179, 196, 195, 192  }
	dim as ubyte ptr ch = @asc_chars(0)

	dim as FB_PROCINFO ptr p = any
	dim as long i = any, j = any, children = any
	dim as FB_PROCARRAY lst = any

	if( (prof->global->options and PROFILE_OPTION_GRAPHICS_CHARS) <> 0 ) then
		ch = @gfx_chars(0)
	end if

	hPushLeader( prof, 0 )

	if( islast ) then
		fprintf( f, !"%s%c%c %s\n", prof->calltree_leader.data, ch[3], ch[1], proc->name )
	else
		fprintf( f, !"%s%c%c %s\n", prof->calltree_leader.data, ch[2], ch[1], proc->name )
	end if

	children = 0
	p = proc
	while( p )
		for j = 0 to PROC_MAX_CHILDREN-1
			if ( p->child(j) ) then
				children += 1
			end if
		next
		p = p->next
	wend

	if( children > 0 ) then
		if( islast ) then
			hPushLeader( prof, asc(!" ") )
		else
			hPushLeader( prof, ch[0] )
		end if
		hPushLeader( prof, asc(!" ") )
		hPushLeader( prof, asc(!" ") )
	end if

	PROCARRAY_constructor( @lst, @prof->global->strings_hash, @prof->global->ignores_hash )

	p = proc
	while( p )
		for j = 0 to PROC_MAX_CHILDREN - 1
			if( proc->child(j) ) then
				if( STRING_HASH_TB_find( lst.ignores->tb, p->child(j)->name, p->child(j)->hashkey ) = 0 ) then
					PROCARRAY_add( @lst, proc->child(j) )
				end if
			end if
		next
		p = p->next
	wend

	PROCARRAY_sort_by_name( @lst )

	for i = 0 to lst.length-1
		hProfilerReportCallTreeProc( prof, ctx, f, lst.array[i], (i = 0), (i = lst.length - 1) )
	next

	PROCARRAY_destructor( @lst )

	if( children > 0 ) then
		hPopLeader( prof )
	end if
end sub

private sub hProfilerReportCallTree _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)
	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"Call Tree:\n\n" )
	end if

	hProfilerReportCallTreeProc( prof, ctx, f, ctx->thread_entry, TRUE, TRUE )

end sub

'' PROFILE_OPTION_REPORT_RAWLIST
private sub hProfilerReportRawList _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as long len_ = any, col = any, i = any, max_len = any
	dim as FB_PROCINFO_TB ptr tb = any
	dim as FB_PROCINFO ptr proc = any

	max_len = STRING_TABLE_max_len( @ctx->strings )

	col = iif(max_len >= 20, max_len, 20)

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"List of call data captured:\n\n" )

		fprintf( f, !"    id  " )
		len_ = col - fprintf( f, !"caller (parent)" )
		pad_spaces( f, len_ )

		fprintf( f, !"    id  " )
		len_ = col - fprintf( f, !"callee" )
		pad_spaces( f, len_ )

		if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
			fprintf( f, !"      count:  " )
		end if
		if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
			fprintf( f, !"     time:  " )
		end if
		fprintf( f, !"\n\n" )
	end if

	tb = ctx->proc_tb
	while( tb )
		for i = 0 to tb->next_free - 1
			proc = @tb->procinfo(i)

			if( proc->parent = NULL ) then
				fprintf( f, !"%6d  ", 0 )
				len_ = col - fprintf( f, !"(root)" )
			else
				fprintf( f, !"%6d  ", proc->parent->proc_id )
				len_ = col - fprintf( f, !"%s", proc->parent->name )
			end if
			pad_spaces( f, len_ )

			fprintf( f, !"%6d  ", proc->proc_id )
			len_ = col - fprintf( f, !"%s", proc->name )
			pad_spaces( f, len_ )

			if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
				len_ = 14 - fprintf( f, fmtlld, proc->local_count )
				pad_spaces( f, len_ )
			end if

			if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
				len_ = 12 - fprintf( f, !"%10.5f", proc->local_time )
				pad_spaces( f, len_ )
			end if

			fprintf( f, !"\n" )
		next
		tb = tb->next
	wend
end sub

'' PROFILE_OPTION_REPORT_RAWDATA
private sub hProfilerReportRawDataProc _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr, _
		byval proc as FB_PROCINFO ptr , _
		byval level as long, byval max_len as long, byval recursion as long _
	)

	dim as long len_ = any, col = any, j = any

	col = iif(max_len >= 20, max_len, 20)

	if( recursion > 0 ) then
		fprintf( f, !"%5d   ", level )
	else
		fprintf( f, !"%5d * ", level )
	end if

	if( proc->parent = NULL ) then
		fprintf( f, !"%6d  ", 0 )
		len_ = col - fprintf( f, !"(root)" )
	else
		fprintf( f, !"%6d  ", proc->parent->proc_id )
		len_ = col - fprintf( f, !"%s", proc->parent->name )
	end if
	pad_spaces( f, len_ )

	fprintf( f, !"%6d  ", proc->proc_id )
	len_ = col - fprintf( f, !"%s", proc->name )
	pad_spaces( f, len_ )

	if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
		len_ = 14 - fprintf( f, fmtlld, proc->local_count )
		pad_spaces( f, len_ )
	end if

	if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
		len_ = 14 - fprintf( f, !"%10.5f", proc->local_time )
		pad_spaces( f, len_ )
	end if

	fprintf( f, !"\n" )

	if( recursion > 0 ) then
		for j = 0 to PROC_MAX_CHILDREN - 1
			if( proc->child(j) ) then
				hProfilerReportRawDataProc( prof, ctx, f, proc->child(j), level + 1, max_len, recursion - 1 )
			end if
		next
	end if
end sub

private sub hProfilerReportRawData _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as long i = any, max_len = any, len_ = any, col = any
	dim as FB_PROCINFO_TB ptr tb = any
	dim as FB_PROCINFO ptr proc = any

	max_len = STRING_TABLE_max_len( @ctx->strings )

	col = iif(max_len >= 20, max_len, 20)

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"List of call data captured (recursive):\n\n" )

		fprintf( f, !" depth: " )
		fprintf( f, !"    id  " )
		len_ = col - fprintf( f, !"caller (parent)" )
		pad_spaces( f, len_ )

		fprintf( f, !"    id  " )
		len_ = col - fprintf( f, !"callee" )
		pad_spaces( f, len_ )

		if( (prof->global->options and PROFILE_OPTION_HIDE_COUNTS) = 0 ) then
			fprintf( f, !"      count:  " )
		end if
		if( (prof->global->options and PROFILE_OPTION_HIDE_TIMES) = 0 ) then
			fprintf( f, !"     time:  " )
		end if
		fprintf( f, !"\n\n" )
	end if

	tb = ctx->proc_tb
	while( tb )
		for i = 0 to tb->next_free - 1
			proc = @tb->procinfo(i)
			hProfilerReportRawDataProc( prof, ctx, f, proc, 1, max_len, 1 )
		next
		tb = tb->next
	wend
end sub

'' PROFILE_OPTION_REPORT_RAWSTRINGS
private sub hProfilerReportRawStrings _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as STRING_INFO_TB ptr tb = ctx->strings.tb

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		pad_section( f )
		fprintf( f, !"Profiler string table (procedure names):\n\n" )
		fprintf( f, !" size length  hash      string\n\n" )
	end if

	while( tb )
		dim as long index = 0
		while( index < tb->bytes_used )
			dim as STRING_INFO ptr info = cast(STRING_INFO ptr, @tb->data(index))
			fprintf( f, !"%5d", info->size )
			fprintf( f, !"  %5d", info->length )
			fprintf( f, !"  %8x", info->hashkey )
			fprintf( f, !"  %s\n", cast(zstring ptr, info + 1) )
			index += info->size
		wend
		tb = tb->next
	wend

	if( (prof->global->options and PROFILE_OPTION_HIDE_TITLES) = 0 ) then
		fprintf( f, !"\n\n" )
	end if
end sub

'' PROFILE_OPTION_SHOW_DEBUGGING
private sub hProfilerReportDebug _
	( _
		byval prof as FB_PROFILER_CALLS ptr, _
		byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr _
	)

	dim as FB_PROFILER_METRICS metrics_data
	dim as FB_PROFILER_METRICS ptr metrics = @metrics_data
	fb_hPROFILER_METRICS_Clear( metrics )
	fb_hPROFILER_METRICS_CallsProfiler( metrics, prof )

	fprintf( f, !"Profiler Debugging Information:\n" )

	fprintf( f, !"    Call Tree:\n" )
	fprintf( f, !"        number of threads  : %d\n", metrics->count_threads )
	fprintf( f, !"        bytes allocated    : %d\n", metrics->procs_bytes_allocated )
	fprintf( f, !"        number of blocks   : %d\n", metrics->procs_count_blocks )
	fprintf( f, !"        number of items    : %d\n", metrics->procs_count_items )
	fprintf( f, !"        number of slots    : %d\n", metrics->procs_count_slots )
	fprintf( f, !"    String Block:\n" )
	fprintf( f, !"        bytes allocated    : %d\n", metrics->string_bytes_allocated )
	fprintf( f, !"        bytes used         : %d\n", metrics->string_bytes_used )
	fprintf( f, !"        bytes free         : %d\n", metrics->string_bytes_free )
	fprintf( f, !"        number of blocks   : %d\n", metrics->string_count_blocks )
	fprintf( f, !"        number of strings  : %d\n", metrics->string_count_strings )
	fprintf( f, !"        max string length  : %d\n", metrics->string_max_len )
	fprintf( f, !"    Hash String Table:\n" )
	fprintf( f, !"        bytes allocated    : %d\n", metrics->hash_bytes_allocated )
	fprintf( f, !"        number of blocks   : %d\n", metrics->hash_count_blocks )
	fprintf( f, !"        number of items    : %d\n", metrics->hash_count_items )
	fprintf( f, !"        number of slots    : %d\n", metrics->hash_count_slots )
	fprintf( f, !"        density            : %-4.2f%%\n", csng(metrics->hash_count_items * 100) / csng(metrics->hash_count_slots ))
	fprintf( f, !"\n" )
end sub

private sub hProfilerReportThread ( _
	byval prof as FB_PROFILER_CALLS ptr, byval ctx as FB_PROFILER_THREAD ptr, byval f as FILE ptr )

	'' default report?
	if( (prof->global->options and PROFILE_OPTION_REPORT_MASK) = 0 ) then
		prof->global->options or= PROFILE_OPTION_REPORT_CALLS
	end if

	if( (prof->global->options and PROFILE_OPTION_REPORT_CALLS) <> 0 ) then
		if( (prof->global->options and PROFILE_OPTION_HIDE_FUNCTIONS) = 0 ) then
			hProfilerReportCallsFunctions( prof, ctx, f )
		end if
		if( (prof->global->options and PROFILE_OPTION_HIDE_GLOBALS) = 0 ) then
			hProfilerReportCallsGlobals( prof, ctx, f )
		end if
	end if

	if( (prof->global->options and PROFILE_OPTION_REPORT_CALLTREE) <> 0 ) then
		hProfilerReportCallTree( prof, ctx, f )
	end if

	if( (prof->global->options and PROFILE_OPTION_REPORT_RAWLIST) <> 0 ) then
		hProfilerReportRawList( prof, ctx, f )
	end if

	if( (prof->global->options and PROFILE_OPTION_REPORT_RAWDATA) <> 0 ) then
		hProfilerReportRawData( prof, ctx, f )
	end if

	if( (prof->global->options and PROFILE_OPTION_REPORT_RAWSTRINGS) <> 0 ) then
		hProfilerReportRawStrings( prof, ctx, f )
	end if

	if( (prof->global->options and PROFILE_OPTION_SHOW_DEBUGGING) <> 0 ) then
		hProfilerReportDebug( prof, ctx, f )
	end if
end sub

private sub hProfilerWriteReport( byval prof as FB_PROFILER_CALLS ptr )
	dim as zstring * PROFILER_MAX_PATH filename_buffer = any
	dim as zstring ptr filename = @filename_buffer
	dim as FB_PROFILER_THREAD ptr thread = any
	dim as FILE ptr f = any

	if( prof = NULL ) then
		return
	end if

	fb_ProfileGetFileName( filename, PROFILER_MAX_PATH )

	f = fopen( filename, "w" )

	if( (prof->global->options and PROFILE_OPTION_HIDE_HEADER) = 0 ) then
		pad_section( f )
		fprintf( f, !"Profiling results:\n" )
		fprintf( f, !"------------------\n\n" )

		fb_hGetExeName( filename, PROFILER_MAX_PATH-1 )
		fprintf( f, !"Executable name: %s\n", filename )
		fprintf( f, !"Launched on: %s\n", prof->global->launch_time )
		fprintf( f, !"Total program execution time: %5.4g seconds\n", prof->main_thread->thread_entry->local_time )
	end if

	hProfilerReportThread( prof, prof->main_thread, f )

	thread = prof->threads
	while( thread )
		hProfilerReportThread( prof, thread, f )
		thread = thread->next
	wend

	fclose( f )
end sub

'' ************************************
'' Call Stack
''

private sub hInitCall( byval ctx as FB_PROFILER_THREAD ptr, byval proc as FB_PROCINFO ptr, byval procname as const zstring ptr )
	dim as ulong hashkey = fb_ProfileHashName( procname )

	proc->name = PROFILER_THREAD_add_string( ctx, procname, hashkey )
	proc->hashkey = hashkey
	proc->proc_id = PROFILER_new_proc_id( ctx )
	proc->start_time = fb_Timer()
	proc->local_time = 0.0
	proc->local_count = 0
	proc->parent = NULL
	if( strncmp( proc->name, @"{fbfp}", 6 ) = 0 ) then
		proc->flags = PROCINFO_FLAGS_CALLPTR
	else
		proc->flags = PROCINFO_FLAGS_NONE
	end if
end sub

private function hPushCall( byval ctx as FB_PROFILER_THREAD ptr, byval parent_proc as FB_PROCINFO ptr, byval procname as const zstring ptr ) as FB_PROCINFO ptr
	dim as FB_PROCINFO ptr orig_parent_proc = any, proc = any
	dim as long j = any, hash_index = any, offset = any
	dim as ulong hashkey = any

	hashkey = fb_ProfileHashName( procname )

	orig_parent_proc = parent_proc

	hash_index = hashkey mod PROC_MAX_CHILDREN
	offset = iif( hash_index, (PROC_MAX_CHILDREN - hash_index), 1 )

	do
		for j = 0 to PROC_MAX_CHILDREN-1
			proc = parent_proc->child(hash_index)
			if ( proc ) then
				if( (proc->hashkey = hashkey) andalso (strcmp( proc->name, procname ) = 0) ) then
					goto update_proc
				end if
				hash_index = ( hash_index + offset ) mod PROC_MAX_CHILDREN
			else
				proc = FB_PROFILER_THREAD_alloc_proc( ctx )
				goto fill_proc
			end if
		next

		if ( parent_proc->next = NULL ) then
			parent_proc->next = FB_PROFILER_THREAD_alloc_proc( ctx )
			proc = parent_proc->next
			goto fill_proc
		end if

		parent_proc = parent_proc->next
	loop

fill_proc:
	hInitCall( ctx, proc, procname )
	proc->parent = orig_parent_proc
	parent_proc->child(hash_index) = proc

update_proc:
	proc->local_count += 1
	proc->start_time = fb_Timer()

	'' set the current procedure pointer to the procedure about to be called
	ctx->thread_proc = proc

	return proc
end function

private sub hPopCall( byval ctx as FB_PROFILER_THREAD ptr, byval proc as FB_PROCINFO ptr )
	dim as double end_time = any

	end_time = fb_Timer()

	'' accumulated time and call count is for all calls
	'' with the current parent
	proc->local_time += ( end_time - proc->start_time )

	'' return to the callee's parent
	ctx->thread_proc = proc->parent
end sub

'' ************************************
'' Public API
''

'':::::
public function fb_ProfileBeginProc FBCALL (  byval procname as const zstring ptr ) as any ptr
	dim thread As FBThread ptr = fb_GetCurrentThread( )
	dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
	dim as FB_PROFILER_THREAD ptr ctx = any
	dim as FB_PROCINFO ptr proc = any

	if( tls->ctx = NULL ) then
		fb_PROFILECTX_Constructor( tls )
	end if

	ctx = tls->ctx
	proc = ctx->thread_proc

	'' First function call of a newly spawned thread has no proc set
	if( proc = NULL ) then
		if( (procname = NULL) orelse (*procname = 0) ) then
			procname = @THREAD_PROC_NAME
		end if
		proc = FB_PROFILER_THREAD_alloc_proc( ctx )
		hInitCall( ctx, proc,  procname )
		proc->flags or= PROCINFO_FLAGS_THREAD
		ctx->thread_entry = proc
		proc->local_count += 1
	end if

	if( (procname = NULL) orelse (*procname = 0) ) then
		procname = @UNNAMED_PROC_NAME
	end if

	'' set the current proc pointer to current procedure called
	ctx->thread_proc = proc

	if( (proc->flags and PROCINFO_FLAGS_CALLPTR) <> 0 ) then
		proc = hPushCall( ctx, proc, procname )
		ctx->thread_proc = proc
	end if


	return cast(FB_PROCINFO ptr, proc)
end function

public sub fb_ProfileEndProc FBCALL ( byval callid as any ptr )
	if( callid ) then
		dim thread As FBThread ptr = fb_GetCurrentThread( )
		dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
		dim as FB_PROFILER_THREAD ptr ctx = tls->ctx
		dim as FB_PROCINFO ptr proc = ctx->thread_proc

		'' TODO: check proc == callid
		if( proc->parent ) then
			if( (proc->parent->flags and PROCINFO_FLAGS_CALLPTR) <> 0 ) then
				hPopCall( ctx, proc )
			end if
		end if
	end if
end sub

'':::::
public function fb_ProfileBeginCall FBCALL ( byval procname as const zstring ptr ) as any ptr
	dim thread As FBThread ptr = fb_GetCurrentThread( )
	dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
	dim as FB_PROFILER_THREAD ptr ctx = any
	dim as FB_PROCINFO ptr parent_proc = any

	if( tls->ctx = NULL ) then
		return NULL
	end if

	ctx = tls->ctx
	parent_proc = ctx->thread_proc

	'' First function call of a newly spawned thread has no parent proc set
	if( parent_proc = NULL ) then
		if( (procname = NULL) orelse ((*procname) = 0) ) then
			procname = @THREAD_PROC_NAME
		end if
		parent_proc = FB_PROFILER_THREAD_alloc_proc( ctx )
		hInitCall( ctx, parent_proc, THREAD_PROC_NAME )
		parent_proc->flags or= PROCINFO_FLAGS_THREAD
	end if

	if( (procname = NULL) orelse ((*procname) = 0) ) then
		procname = @UNNAMED_PROC_NAME
	end if

	return cast( any ptr, hPushCall( ctx, parent_proc, procname ) )
end function

'':::::
public sub fb_ProfileEndCall FBCALL ( byval callid as any ptr )
	if( callid ) then
		dim thread As FBThread ptr = fb_GetCurrentThread( )
		dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
		hPopCall( tls->ctx, cast(FB_PROCINFO ptr, callid) )
	end if
end sub

'':::::
public sub fb_InitProfile FBCALL ( )
	dim thread As FBThread Ptr = fb_GetCurrentThread( )
	dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
	dim as FB_PROFILER_THREAD ptr ctx = any

	if( fb_profiler ) then
		return
	end if
	fb_profiler = PROFILER_CALLS_create( )
	fb_PROFILECTX_Constructor( tls )
	ctx = tls->ctx

	'' assume we are starting from MAIN procedure
	ctx->thread_entry = FB_PROFILER_THREAD_alloc_proc( ctx )
	hInitCall( ctx, ctx->thread_entry, MAIN_PROC_NAME )
	ctx->thread_proc = ctx->thread_entry
	ctx->thread_proc->flags or= PROCINFO_FLAGS_MAIN
	ctx->thread_proc->local_count = 1

	'' assume that this must have been called from the main thread
	fb_profiler->main_thread = ctx
end sub

'':::::
public function fb_EndProfile FBCALL ( byval errorlevel as long ) as long
	dim thread As FBThread Ptr = fb_GetCurrentThread( )
	dim as FB_PROFILECTX ptr tls = fb_get_thread_profilectx( )
	dim as FB_PROFILER_THREAD ptr ctx = tls->ctx
	dim as FB_PROFILER_CALLS ptr prof = fb_profiler
	dim as FB_PROCINFO ptr lastproc = any

	if( ctx <> prof->main_thread ) then
		'' TODO: Ending profiling from some other thread?
	end if

	'' walk up the call stack and update times
	lastproc = ctx->thread_proc
	while( lastproc )
		lastproc->local_time = fb_timer() - lastproc->start_time
		lastproc = lastproc->parent
	wend

	hProfilerWriteReport( prof )

	PROFILER_CALLS_destroy( )

	return errorlevel
end function

'':::::
public function fb_ProfileGetProfiler FBCALL () as FB_PROFILER_CALLS ptr
	return fb_profiler
end function

'':::::
public sub fb_ProfileGetCallsMetrics FBCALL ( byval metrics as FB_PROFILER_METRICS ptr )

	FB_PROFILE_LOCK()

	if( (fb_profiler <> NULL) andalso (metrics <> NULL) ) then
		fb_hPROFILER_METRICS_CallsProfiler( metrics, fb_profiler )
	end if

	FB_PROFILE_UNLOCK()
end sub

end extern
