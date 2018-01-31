/' generic internal dynamic lists '/

#include "fb.bi"

extern "C"
/'* Initializes a list.
 *
 * This list implementation doesn't care where the data will be stored to.
 * It's up to the caller to do all memory operations.
 *
 * @param list      Pointer to list structure to initialize.
 '/
sub fb_hListDynInit( list as FB_LIST ptr )
    memset(list, 0, sizeof(FB_LIST))
end sub

/'* Adds an element to the list.
 *
 * This function adds a list element to the list. It's up to the
 * caller to allocate the memory required by this element.
 *
 * @param list      Pointer to the list structure.
 * @param elem      Pointer to the element to add to the list.
 '/
sub fb_hListDynElemAdd( list as FB_LIST ptr, elem as FB_LISTELEM ptr )
	if ( list->tail <> NULL ) then
		list->tail->next = elem
	else
		list->head = elem
	end if

	elem->prev = list->tail
	elem->next = NULL

	list->tail = elem

	list->cnt += 1
end sub

/'* Remove an element from the list.
 *
 * This function removes a list element from the list. It's up to the
 * caller to free the memory allocated by this element.
 *
 * @param list      Pointer to the list structure.
 * @param elem      Pointer to the element to remove from the list.
 '/
sub fb_hListDynElemRemove( list as FB_LIST ptr, elem as FB_LISTELEM ptr )
	/' del from used list '/
	if ( elem->prev <> NULL ) then
		elem->prev->next = elem->next
	else
		list->head = elem->next
	end if

	if ( elem->next <> NULL ) then
		elem->next->prev = elem->prev
	else
		list->tail = elem->prev
	end if

	/' reset element pointers '/
    elem->prev = NULL
	elem->next = NULL

    /' don't forget to change the number of elements in the list '/
	list->cnt -= 1
end sub
end extern