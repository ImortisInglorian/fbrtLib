#define FBCALL

/* newline for console/file I/O */
#define FB_NEWLINE "\r\n"
#define FB_NEWLINE_WSTR _LC("\r\n")

/* newline for printer I/O */
#define FB_BINARY_NEWLINE "\r\n"
#define FB_BINARY_NEWLINE_WSTR _LC("\r\n")

#define FB_LL_FMTMOD "ll"

#define FB_CONSOLE_MAXPAGES 8

#define FB_DYLIB Any Ptr

/* In DJGPP we don't use fseeko() at all, the DJGPP semi-2.04 setup used for
   FB doesn't even seem to have it. */
type fb_off_t As Long
#define fseeko(stream, offset, whence) fseek(stream, offset, whence)
#define ftello(stream)                 ftell(stream)

#define FB_COLOR_BLACK     (0)
#define FB_COLOR_BLUE      (1)
#define FB_COLOR_GREEN     (2)
#define FB_COLOR_CYAN      (3)
#define FB_COLOR_RED       (4)
#define FB_COLOR_MAGENTA   (5)
#define FB_COLOR_BROWN     (6)
#define FB_COLOR_WHITE     (7)
#define FB_COLOR_GREY      (8)
#define FB_COLOR_LBLUE     (9)
#define FB_COLOR_LGREEN    (10)
#define FB_COLOR_LCYAN     (11)
#define FB_COLOR_LRED      (12)
#define FB_COLOR_LMAGENTA  (13)
#define FB_COLOR_YELLOW    (14)
#define FB_COLOR_BWHITE    (15)

Type __dpmi_regs_d
    As Ulong edi, _
    esi, _
    ebp, _
    res, _
    ebx, _
    edx, _
    ecx, _
    eax
End Type

extern __fb_startup_cwd As UByte Ptr

Extern "C"
Type FnIntHandler As Function( ByVal irq_number As ULong ) As Long
Declare Function fb_hGetPageAddr( ByVal pg As Long, ByVal cols As Long, ByVal rows As Long ) As Ulong
Declare Function fb_isr_set( _
		ByVal irq_number As ULong, _
                ByVal pfnIntHandler As FnIntHandler, _
                ByVal fn_size As size_t, _
                ByVal stack_size As size_t ) As Long

Declare Function fb_isr_reset( ByVal irq_number As Ulong ) As Long
Declare Function fb_isr_get( ByVal irq_number As Ulong ) As FnIntHandler
/* To allow recursive CLI/STI */
Declare Function fb_dos_cli( ) As Long
Declare Function fb_dos_sti( ) As Long
Declare Function fb_dos_lock_data( ByVal address As Const Any Ptr, ByVal size As size_t ) As Long
Declare Function fb_dos_lock_code( ByVal address As Const Any Ptr, ByVal size As size_t ) As Long
Declare Function fb_dos_unlock_data( ByVal address As Const Any Ptr, ByVal size As size_t ) As Long
Declare Function fb_dos_unlock_code( ByVal address As Const Any Ptr, ByVal size As size_t  ) As Long

#define lock_var(var)           fb_dos_lock_data(   @(var), SizeOf(var) )
#define lock_array(array)       fb_dos_lock_data(   (array), SizeOf(array) )
#define lock_proc(proc)         fb_dos_lock_code(   @proc, Cast(ULong, @end_##proc ) - Cast( Ulong, @proc ) )
#define lock_data(start, end)   fb_dos_lock_data(   (@start), Cast(Any Ptr, @(end)) - Cast(Any Ptr, @(start) ) )
#define lock_code(start, end)   fb_dos_lock_code(   (start), Cast(Any Ptr, (end)) - Cast(Any Ptr, (start) ) )

#define unlock_var(var)         fb_dos_unlock_data( @(var), SizeOf(var) )
#define unlock_array(array)     fb_dos_unlock_data( (array), SizeOf(array) )
#define unlock_proc(proc)       fb_dos_unlock_code( @proc, Cast(ULong, @end_##proc ) - Cast( Ulong, @proc ) )
#define unlock_data(start, end) fb_dos_unlock_data( (@start), Cast(Any Ptr, @(end)) - Cast(Any Ptr, @(start) ) )
#define unlock_code(start, end) fb_dos_unlock_code( (start), Cast(Any Ptr, (end)) - Cast(Any Ptr, (start) ) )

/* multikey() declarations also used by gfxlib2 */
#define END_OF_FUNCTION(proc)               Sub end_##proc () End Sub
#define END_OF_STATIC_FUNCTION(proc) Private Sub end_##proc () End Sub
Type __fb_dos_multikey_hook As Function(ByVal scancode As Long, ByVal flags As Long) As Long
#define KB_PRESS    0x00000001
#define KB_REPEAT   0x00000002
#define KB_SHIFT    0x00000004
#define KB_CTRL     0x00000008
#define KB_ALT      0x00000010
#define KB_CAPSLOCK 0x00000020
#define KB_NUMLOCK  0x00000040
#define KB_EXTENDED 0x00000080

Declare Sub fb_hFarMemSet ( ByVal selector As UShort, ByVal dest As Ulong, ByVal char_to_set As Ubyte, ByVal bytes As size_t )
Declare Sub fb_hFarMemSetW( ByVal selector As UShort, ByVal dest As Ulong, ByVal word_to_set As Ushort, ByVal words As size_t )

End Extern