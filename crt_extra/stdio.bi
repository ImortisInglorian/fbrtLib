declare function fseeko64 cdecl ( as FILE ptr, as off64_t, as long ) as long

function ftello64 cdecl (stream as FILE ptr) as off64_t
	dim as fpos_t _pos
	if ( fgetpos(stream, @_pos) ) then
		return  -1
	else
		return (cast(off64_t, _pos))
	end if
end function