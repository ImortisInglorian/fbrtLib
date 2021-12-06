#include "../fb.bi"
#include "fb_private_console.bi"
#include "sys/wait.bi"

Extern "c"
Function fb_ExecEx FBCALL( program as FBSTRING ptr, args as FBSTRING ptr, do_fork as long ) as long

	dim buffer as ubyte(0 To MAX_PATH)
	dim argv() as ubyte ptr
	dim arguments as ubyte ptr
	dim p as ubyte ptr

	dim as long i, argc = 0, res = -1, status
	dim len_arguments as ssize_t
	dim pid as pid_t
	dim allocated as Boolean = False

	if( (program = NULL) OrElse (program->data = NULL) ) then
	
		fb_hStrDelTemp( args )
		fb_hStrDelTemp( program )
		return -1
	end if

	strncpy( @buffer(0), program->data, sizeof( buffer ) )
	buffer(sizeof( buffer ) - 1) = 0

	fb_hConvertPath( buffer )

	if( args=NULL ) then
		arguments = sadd("")
	else
		len_arguments = FB_STRSIZE( args )
		arguments = Allocate( len_arguments + 1 )
		allocated = True
		DBG_ASSERT( arguments <> NULL )
		arguments[len_arguments] = 0
		if( len_arguments > 0 ) then
			argc = fb_hParseArgs( arguments, args->data, len_arguments )
		end if
	end if

	FB_STRLOCK()

	fb_hStrDelTemp_NoLock( args )
	fb_hStrDelTemp_NoLock( program )

	FB_STRUNLOCK()

	if( argc = -1 ) then
		If( allocated ) then DeAllocate(arguments) end if
		return -1
	end if

	argc += 1 			/' add 1 for program name '/

	Redim argv(0 to argc)

	argv(0) = buffer

	/' scan the processed args and set pointers '/
	p = arguments
	for i=1 to argc - 1
		argv(i) = p	/' set pointer to current argument '/
		p += (strlen(p) + 1) /' skip to 1 char past next null char '/
	Next
	argv(argc) = NULL


	/' Launch '/
	FB_LOCK( )
	fb_hExitConsole()
	FB_UNLOCK( )

	if( do_fork ) then
		pid = fork()
		if( pid <> -1 ) then
			if (pid = 0) then
				/' execvp() only returns if it failed '/
				execvp( buffer, @argv(0) )
				/' HACK: execvp() failed, this must be communiated to the parent process *somehow*,
				   so fb_ExecEx() can return -1 there '/
				/' Using _Exit() instead of exit() to prevent the child from flusing file I/O and
				   running global destructors (especially the rtlib's own cleanup), which may try
				   to wait on threads to finish (e.g. hinit.c::bg_thread()), but fork() doesn't
				   duplicate other threads besides the current one, so their pthread handles will be
				   invalid here in the child process. '/
				_Exit( 255 )
				/' FIXME: won't be able to tell the difference if the exec'ed program returned 255.
				   Maybe a pipe could be used instead of the 255 exit code? Unless that's too slow/has side-effects '/
			elseif( (waitpid(pid, @status, 0) > 0) AndAlso WIFEXITED(status) ) then
				res = WEXITSTATUS(status)
				if( res = 255 ) then
					/' See the HACK above '/
					res = -1
				end if
			end if
		end if
	else
		res = execvp( buffer, @argv(0) )
	end if

	If( allocated ) then DeAllocate(arguments) end if

	FB_LOCK( )
	fb_hInitConsole()
	FB_UNLOCK( )

	return res
End Function
End Extern