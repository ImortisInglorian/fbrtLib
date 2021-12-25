'' Simple wrapper so you can't forget to call fb_strDelete
type destructable_string
	as FBSTRING str_

	Declare Operator@() as FBSTRING ptr
	Declare Constructor()
	Declare Destructor()
	Declare Property len() as ssize_t
	Declare Property size() as ssize_t
	Declare Property data() as ubyte ptr
end type

Declare Operator*(byref str as destructable_string) as FBSTRING ptr
