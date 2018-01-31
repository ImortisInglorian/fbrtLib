/' generic internal lists based on static arrays '/

#include "fb.bi"

extern "C"
/'* Initializes a list.
 *
 * This list implementation is based on a static array.
 *
 * @param list      Pointer to list structure to initialize.
 * @param table     Pointer to the pool of available list elements.
 * @param elem_size Size of elements in the array.
 * @param size      Number of elements in the array.
 '/
sub fb_hListInit( list as FB_LIST ptr, table as any ptr, elem_size as size_t, size as size_t )
	dim as size_t i
	dim as FB_LISTELEM ptr _next
    dim as ubyte ptr elem = cast(ubyte ptr, table)

    fb_hListDynInit( list )
	
	list->fhead = cast(FB_LISTELEM ptr, elem)
	
	for i = 0 to size - 1
		if ( i < size-1 ) then
			_next = cast(FB_LISTELEM ptr, (elem + elem_size))
		else
			_next = NULL
		end if
		cast(FB_LISTELEM ptr,elem)->prev = NULL
		cast(FB_LISTELEM ptr,elem)->next = _next
		
		elem += elem_size
	next
end sub

/'* Allocate a new list element.
 *
 * This function gets an element from the list of free elements
 * ( struct _FB_LIST::fhead ) and adds to the tail. It also increases the
 * number of used elements ( struct _FB_LIST::cnt ).
 *
 * @param list      Pointer to the list structure.
 *
 * @return A new element.
 '/
function fb_hListAllocElem( list as FB_LIST ptr ) as FB_LISTELEM ptr
	dim as FB_LISTELEM ptr elem

	/' take from free list '/
	elem = list->fhead
	if ( elem = NULL ) then
		return NULL
	end if

	list->fhead = elem->next

    /' add to entry used list '/
    fb_hListDynElemAdd( list, elem )

	return elem
end function

/'* Free a list element.
 *
 * This function frees a list element by removing it from the list of
 * used elements and adding it to the list of free elements
 * ( struct _FB_LIST::fhead ). It also decreses the number of used
 * elements ( struct _FB_LIST::cnt ).
 *
 * @param list      Pointer to the list structure.
 * @param elem      List element to add to the list of free elements.
 '/
sub fb_hListFreeElem( list as FB_LIST ptr, elem as FB_LISTELEM ptr )
    /' remove entry from the list of used elements '/
    fb_hListDynElemRemove( list, elem )

	/' add to free list '/
	elem->next = list->fhead
	list->fhead = elem
end sub
end extern
