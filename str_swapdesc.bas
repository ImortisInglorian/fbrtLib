/' temp string descriptor allocation for zstring's '/

#include "fb.bi"

extern "C"
Sub fb_StrSwapDesc FBCALL ( _str1 as FBSTRING ptr, _str2 as FBSTRING ptr )
	
	dim tempptr as ubyte ptr = _str1->data
	dim tempsize as ssize_t = _str1->size
	dim templen as ssize_t = _str1->len

	_str1->data = _str2->data
	_str1->len = _str2->len
	_str1->size = _str2->size

	_str2->data = _str1->data
	_str2->len = _str1->len
	_str2->size = _str1->size
end Sub
end extern