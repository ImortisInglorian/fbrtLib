#include "fb.bi"
#include "destruct_string.bi"

Private Constructor destructable_string()
	str_ = __fb_ctx.null_desc
End Constructor

Private Destructor destructable_string()
	fb_strDelete(@str_)
End Destructor

Private Operator destructable_string.@() as FBSTRING ptr
	Return @str_
End Operator

Private Property destructable_string.len() as ssize_t
	Return str_.len
End Property

Private Property destructable_string.size() as ssize_t
	Return str_.size
End Property

Private Property destructable_string.data() as ubyte ptr
	Return str_.data
End Property

Private Operator *(byref dest_str as destructable_string) as FBSTRING ptr
	Return @dest_str.str_
End Operator