/' set the with for devices '/

#include "fb.bi"
#include "crt/ctype.bi"

type DEV_INFO_WIDTH
    as FB_LISTELEM elem
    as ubyte ptr   device
    as long        width
end type

extern "C"
/'* Initialize the list of device info nodes.
 '/
private sub fb_hListDevInit ( list as FB_LIST ptr )
    fb_hListDynInit( list )
end sub

/'* Allocate a new device info node.
 *
 * @return pointer to the new node
 '/
private function fb_hListDevElemAlloc ( list as FB_LIST ptr, device as ubyte const ptr, _width as long ) as DEV_INFO_WIDTH ptr
    dim as DEV_INFO_WIDTH ptr node = cast(DEV_INFO_WIDTH ptr, allocate( 1, sizeof(DEV_INFO_WIDTH) ))
    node->device = strdup(device)
    node->width = _width
    fb_hListDynElemAdd( list, @node->elem )
    return node
end function

#if 0
/'* Remove the device info node and release its memory.
 '/
private sub fb_hListDevElemFree ( list as FB_LIST ptr, node as DEV_INFO_WIDTH ptr )
    fb_hListDynElemRemove( list, @node->elem )
    deallocate(node->device)
    deallocate(node)
end sub
#endif

/'* Pointer to the device info list.
 '/
dim shared as FB_LIST ptr dev_info_widths = NULL

/':::::'/
function fb_WidthDev FBCALL ( dev as FBSTRING ptr, _width as long ) as long
    dim as long cur = _width
    dim as DEV_INFO_WIDTH ptr node
    dim as size_t i, size
    dim as ubyte ptr device

    FB_LOCK()

    /' create list of device info nodes (if not created yet) '/
    if ( dev_info_widths = NULL ) then
        dev_info_widths = allocate( sizeof(FB_LIST) )
        fb_hListDevInit( dev_info_widths )
    end if

    FB_UNLOCK()

    /' '/
    size = FB_STRSIZE(dev)
    device = allocate(size + 1)
    memcpy( device, dev->data, size )
    device[size] = 0

    /' make the name uppercase '/
    for i = 0 to size - 1
        dim as ulong ch = cast(ulong, device[i])
        if ( islower(ch) <> NULL ) then
            device[i] = cast(ubyte, toupper(ch))
		end if
    next

    FB_LOCK()

    /' Search list of devices for the requested device name '/
	node = dev_info_widths->head
	while (node <> cast(DEV_INFO_WIDTH ptr,  NULL))
        if ( strcmp( device, node->device ) = 0 ) then
            exit while
        end if
		node = cast(DEV_INFO_WIDTH ptr,node->elem.next)
	wend

    if ( _width <> -1 ) then
        if ( node = NULL ) then
            /' Allocate a new list node if device name not found '/
            node = fb_hListDevElemAlloc ( dev_info_widths, device, _width )
        else
            /' Set device width '/
            node->width = _width
        end if
    elseif ( node <> NULL ) then
        cur = node->width
    end if

    /' search the width for all open (and known) devices '/
    if ( strcmp( device, "SCRN:" ) = 0 ) then
        /' SCREEN device '/
        if ( _width <> -1 ) then
            fb_Width( _width, -1 )
        end if
        cur = FB_HANDLE_SCREEN.width

    elseif ( fb_DevLptTestProtocol( NULL, device, size ) <> NULL ) then
        /' PRINTER device '/
        cur = fb_DevPrinterSetWidth( device, _width, cur )
    elseif ( fb_DevComTestProtocol( NULL, device, size ) <> NULL ) then
        /' SERIAL device '/
        cur = fb_DevSerialSetWidth( device, _width, cur )
    else
        /' unknown device '/
    end if
    
	deallocate(device)
	
	FB_UNLOCK()

    if ( _width = -1 ) then
        return cur
    end if

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern