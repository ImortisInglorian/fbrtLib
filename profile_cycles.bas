'' profile_cycles.c -- cycle counting profiler

'' WIP
'' TODO: update src/compiler/rtl-system.bas:rtlInitProfile
'' TODO: test exit code, profiler clean-up should still run
''       even when compiled exe does not encounter fb_End()
'' TODO: organize this code by only having start-up code here
''       and the test in src/rtlib/profile-cycles.c
'' TODO: share reporting code with src/rtlib/profile.c
'' TODO: add a report option for binary output

#include "fb.bi"
#include "fb_profile.bi"

extern "C"

/' choose a suitable size_t printf specifier '/
#if not defined(fmtsizet)
	#if defined(HOST_CYGWIN)
		#define fmtsizet "%18Iu"
	#elif defined(HOST_WIN32)
		#define fmtsizet "%18Iu"
	#else
		#define fmtsizet "%18zu"
	#endif
#endif

'' profile section data
extern as ubyte __start_fb_profilecycledata alias "__start_fb_profilecycledata"
extern as ubyte __stop_fb_profilecycledata alias "__stop_fb_profilecycledata"

'' profiler record ids - these indicate what the record is
enum FB_PROFILE_REDORD_ID
	FB_PROFILE_RECORD_VERSION_ID = 1
	FB_PROFILE_RECORD_DATA_ID    = 2
end enum

'' the current profiler version number
#define FB_PROFILE_VERSION 100

type FB_PROFILE_RECORD_HEADER
	dim as ssize_t size
	dim as ssize_t id
end type

type FB_PROFILE_RECORD_VERSION
	dim as ssize_t size
	dim as ssize_t id
	dim as ssize_t version
	dim as any ptr reserved1
end type

type FB_PROFILE_RECORD_DATA
	dim as ssize_t size
	dim as ssize_t id
	dim as zstring ptr module_name
	dim as zstring ptr proc_name
	dim as ssize_t init0
	dim as ssize_t grand_total
	dim as ssize_t reinit
	dim as ssize_t internal_total
	dim as ssize_t call_count
	dim as ssize_t reserved
end type

type FB_PROFILE_FILE_DATA
	dim as ssize_t init0
	dim as ssize_t grand_total
	dim as ssize_t reinit
	dim as ssize_t internal_total
	dim as ssize_t call_count
end type

'' cycles profiler global context
'' use FB_PROFILE_LOCK()/FB_PROFILE_UNLOCK when accessing
type FB_PROFILER_CYCLES
	dim as FB_PROFILER_GLOBAL ptr global
	dim as double start_time
end type

'' ************************************
'' Globals
''

#if 0

/' FIXME: creating a library with other sections causes dxe3gen to fail
''        when building the DXE dynamic link library support for DOS
'/
#if !defined(HOST_DOS) 

'' make sure there is at least one record in the profile data section
static FB_PROFILE_RECORD_VERSION
__attribute__ ((aligned (16))) prof_data_version
__attribute__((section("fb_profilecycledata"), used)) =
	{
		sizeof( FB_PROFILE_RECORD_VERSION ),
		FB_PROFILE_RECORD_VERSION_ID,
		FB_PROFILE_VERSION, 0
	};

#endif

#endif

dim shared as FB_PROFILER_CYCLES ptr fb_profiler = NULL

'' ************************************
'' Profiling
''

private function PROFILER_CYCLES_create( ) as FB_PROFILER_CYCLES ptr
	if( fb_profiler = NULL ) then
		dim as FB_PROFILER_CYCLES ptr prof = any
		prof = PROFILER_calloc( 1, sizeof( FB_PROFILER_CYCLES ) )
		if( prof ) then
			prof->global = PROFILER_GLOBAL_create( )
			if( prof->global ) then
				prof->global->profiler_ctx = cast(any ptr, prof)
				fb_profiler = prof
			else
				PROFILER_free( prof )
			end if
		end if
	end if
	return fb_profiler
end function

private sub PROFILER_CYCLES_destroy(  )
	if( fb_profiler ) then
		PROFILER_GLOBAL_destroy( )
		PROFILER_free( fb_profiler )
		fb_profiler = NULL
	end if
end sub

'' ************************************
'' Report Generation
''

#if 0
static hProfilerReportBinary( )
{
	f1 = fopen( "profilename.prf", "w" );
	f2 = fopen( "profilecycles.prf", "w" );

	while( index < length )
	{
		FB_PROFILE_RECORD_HEADER *rec = (FB_PROFILE_RECORD_HEADER *)&data[index];
		switch ( rec->id )
		{
			case FB_PROFILE_RECORD_VERSION_ID:
			{
				// FB_PROFILE_RECORD_VERSION *ver = (FB_PROFILE_RECORD_VERSION *)rec;
				break;
			}
			case FB_PROFILE_RECORD_DATA_ID:
			{
				FB_PROFILE_RECORD_DATA *dat = (FB_PROFILE_RECORD_DATA *)rec;
				FB_PROFILE_FILE_DATA fil;

				fil.init0          = dat->init0;
				fil.grand_total    = dat->grand_total;
				fil.reinit         = dat->reinit;
				fil.internal_total = dat->internal_total;
				fil.call_count     = dat->call_count;

				fprintf( f1, "%s\n", dat->proc_name );
				fprintf( f1, "%s\n", dat->module_name );
				fwrite( &fil, sizeof(FB_PROFILE_FILE_DATA), 1, f2 );
				break;
			}
			default:
				break;
		}
		index += rec->size;
	}

	fclose( f2 );
	fclose( f1 );
}
#endif

private function hProfilerCountProcs( byval data_ as ubyte ptr, byval length as ssize_t ) as ssize_t
	dim as ssize_t index = 0, count = 0
	while( index < length )
		dim as FB_PROFILE_RECORD_HEADER ptr rec = cast(FB_PROFILE_RECORD_HEADER ptr, @data_[index])
		if( rec->id = FB_PROFILE_RECORD_DATA_ID ) then
			count += 1
		end if
		index += rec->size
	wend
	return count
end function

private function name_sorter( byval e1 as const any ptr, byval e2 as const any ptr ) as long
	dim as FB_PROFILE_RECORD_DATA ptr p1 = *cast(FB_PROFILE_RECORD_DATA ptr ptr, e1)
	dim as FB_PROFILE_RECORD_DATA ptr p2 = *cast(FB_PROFILE_RECORD_DATA ptr ptr, e2)
	dim as long ret = any

	ret = strcmp( p1->module_name, p2->module_name )
	if( ret ) then
		return ret
	end if
	return strcmp( p1->proc_name, p2->proc_name )
end function

private sub hProfilerSortArray( byval array as FB_PROFILE_RECORD_DATA ptr ptr, byval count as ssize_t )
	qsort( array, count, sizeof(FB_PROFILE_RECORD_DATA ptr), procptr(name_sorter) )
end sub

private sub hProfilerBuildArray _
	( _
		byval array as FB_PROFILE_RECORD_DATA ptr ptr, _
		byval count as ssize_t, _
		byval data_ as ubyte ptr, _
		byval length as ssize_t _
	)
	dim as ssize_t index = 0
	dim as long i = 0

	if( array = NULL ) then
		return
	end if

	while( (index < length) andalso (i < count) )
		dim as FB_PROFILE_RECORD_HEADER ptr rec = cast(FB_PROFILE_RECORD_HEADER ptr, @data_[index])
		if( rec->id = FB_PROFILE_RECORD_DATA_ID ) then
			array[i] = cast(FB_PROFILE_RECORD_DATA ptr, rec)
			i += 1
		end if
		index += rec->size
	wend
end sub

private sub hProfilerReport _
	( _
		byval prof as FB_PROFILER_CYCLES ptr, _
		byval f as FILE ptr, _
		byval array as FB_PROFILE_RECORD_DATA ptr ptr, _
		byval count as ssize_t _
	)

	dim as FB_PROFILE_RECORD_DATA ptr rec = any
	dim as zstring ptr last_module = NULL
	dim as ssize_t index

	if( (prof->global->options and PROFILE_OPTION_HIDE_HEADER) = 0 ) then
		fprintf( f, !"module  function             total             inside         call count\n\n" )
	end if

	for index = 0 to count - 1
		rec = array[index]
		if( last_module <> rec->module_name ) then
			if( last_module <> NULL ) then
				fprintf( f, !"\n" )
			end if
			last_module = rec->module_name
			fprintf( f, !"%s\n\n", rec->module_name )
		end if

		fprintf( f, !"        %s\n", rec->proc_name )
		fprintf( f, !"                " + fmtsizet + " " + fmtsizet + " " + fmtsizet + "\n", _
			rec->grand_total, _
			rec->internal_total, _
			rec->call_count _
		)
	next
end sub

private sub hProfilerWriteReport( byval prof as FB_PROFILER_CYCLES ptr )
	dim as zstring * PROFILER_MAX_PATH filename_buffer = any
	dim as zstring ptr filename = @filename_buffer
	dim as FILE ptr f = any
	dim as ubyte ptr data_ = any
	dim as ssize_t length = any, count = any
	dim as FB_PROFILE_RECORD_DATA ptr ptr array = any

	fb_ProfileGetFileName( filename, PROFILER_MAX_PATH )

	f = fopen( filename, "w" )

	if( (prof->global->options and PROFILE_OPTION_HIDE_HEADER) = 0 ) then
		fprintf( f, !"Cycle Count Profiling results:\n" )
		fprintf( f, !"------------------------------\n\n" )

		fb_hGetExeName( filename, PROFILER_MAX_PATH-1 )
		fprintf( f, !"Executable name: %s\n", filename )
		fprintf( f, !"Launched on: %s\n", prof->global->launch_time )
		fprintf( f, !"Total program execution time: %5.4g seconds\n", fb_Timer() - prof->start_time )
	end if

	data_ = cast(ubyte ptr, @__start_fb_profilecycledata)
	length = cast(ssize_t, @__stop_fb_profilecycledata) - cast(ssize_t, @__start_fb_profilecycledata)

	count = hProfilerCountProcs( data_, length )
	if( count ) then
		array = PROFILER_malloc( sizeof(FB_PROFILE_RECORD_DATA ptr) * count )
		if( array ) then
			hProfilerBuildArray( array, count, data_, length )
			hProfilerSortArray( array, count )
			hProfilerReport( prof, f, array, count )
			PROFILER_free( array )
		end if
	end if

	fclose( f )
end sub

'' ************************************
'' Cylcles Profing Public API
''

'':::::
public sub fb_InitProfileCycles FBCALL ( )
	if( fb_profiler ) then
		return
	end if
	fb_profiler = PROFILER_CYCLES_create( )
	if( fb_profiler ) then
		fb_profiler->start_time = fb_Timer()
	end if
end sub

'':::::
public function fb_EndProfileCycles FBCALL ( byval errorlevel as long ) as long
	hProfilerWriteReport( fb_profiler )
	PROFILER_CYCLES_destroy( )
	return errorlevel
end function

'':::::
public function fb_ProfileGetCyclesProfiler FBCALL () as FB_PROFILER_CYCLES ptr
	return fb_profiler
end function

end extern
