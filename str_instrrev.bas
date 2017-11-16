/' instrrev function '/

#include "fb.bi"

extern "C"
#if 0 /' FIXME: implementation is bugged somewhere, missing some matches '/
function fb_hFindBM cdecl ( start as ssize_t, pachText as ubyte const ptr, len_text as ssize_t, pachPattern as ubyte const ptr, len_pattern as ssize_t ) as ssize_t
	dim as ssize_t i, j, len_max = len_text - len_pattern
	dim as ssize_t bm_bc(0 to 255)
	dim as ssize_t ptr bm_gc, suffixes

	bm_gc = cast(ssize_t ptr, alloca(sizeof(ssize_t) * (len_pattern + 1)))
	suffixes = cast(ssize_t ptr, alloca(sizeof(ssize_t) * (len_pattern + 1)))

	memset( @bm_gc(0), 0, sizeof(ssize_t) * (len_pattern+1) )
	memset( suffixes, 0, sizeof(ssize_t) * (len_pattern+1) )

	/' create "bad character" shifts '/
	memset(@bm_bc(0), -1, sizeof(bm_bc))
	for i=0 to len_pattern
		bm_bc( FB_CHAR_TO_INT(pachPattern[i]) ) = i

	/' preprocessing for "good end strategy" case 1 '/
	i = len_pattern
	j = len_pattern + 1
	suffixes[ i ] = j
	while ( i <> 0 )
		dim as ubyte ch1 = pachPattern[len_pattern-i]
		while ( j <= len_pattern and ch1 <> pachPattern[len_pattern-j] )
			if ( bm_gc[j]==0 ) then
				bm_gc[j] = j - i
			end if
			j = suffixes[j]
		wend
		i -= 1 
		j -= 1
		suffixes[i] = j
	wend

	/' preprocessing for "good end strategy" case 2 '/
	j = suffixes[0]
	for i = 0 to len_pattern
		if ( bm_gc[i]=0 ) then
			bm_gc[i] = j
		end if
		if( i = j ) then
			j = suffixes[j]
		end if
	next

	/' search '/
	i = len_max - start
	while ( i <= len_max ) 
		j = len_pattern
		while ( j <> 0 and pachPattern[len_pattern-j] = pachText[len_text - i - j] )
			j -= 1
		wend
		if ( j = 0 ) then
			return len_text - len_pattern - i + 1
		else
			dim as ubyte chText = pachText[len_text - i - j]
			dim as ssize_t shift_gc = bm_gc[j]
			dim as ssize_t shift_bc = j - 1 - bm_bc(FB_CHAR_TO_INT(chText) )
			i += iif( (shift_gc > shift_bc), shift_gc, shift_bc )
		end if
	wend
	return 0
end function
#endif

#if 1
function fb_hFindNaive cdecl ( start as ssize_t, pachText as ubyte ptr, len_text as ssize_t, pachPattern as ubyte const ptr, len_pattern as ssize_t ) as ssize_t
	dim as ssize_t i
	pachText += start
	for i = 0 to start
		dim as ssize_t j
		for j = 0 to len_pattern
			if ( pachText[j] <> pachPattern[j] ) then
				exit for
			end if
		next
		if ( j = len_pattern ) then
			return start - i + 1
		end if
		pachText -= 1
	next
	return 0
end function
#endif

function fb_StrInstrRev FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
	dim as ssize_t r = 0

	if ( (src <> NULL) and (src->data <> NULL) and (patt <> NULL) and (patt->data <> NULL) ) then
		dim as ssize_t size_src = FB_STRSIZE(src)
		dim as ssize_t size_patt = FB_STRSIZE(patt)

		if ( (size_src <> 0) and (size_patt <> 0) and (size_patt <= size_src) and (start <> 0)) then
			/' handle signed/unsigned comparisons of start and size_* vars '/
			if ( start < 0 ) then
				start = size_src - size_patt + 1
			elseif ( start > size_src ) then
				start = 0
			elseif ( start > size_src - size_patt ) then
				start = size_src - size_patt + 1
			end if
			
			if ( start > 0 ) then
				#if 1
				r = fb_hFindNaive( start - 1, src->data, size_src,patt->data, size_patt )
				#else
				r = fb_hFindBM( start - 1, src->data, size_src, patt->data, size_patt )
				#endif
			end if
		end if
	end if

	FB_STRLOCK()

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )
	fb_hStrDelTemp_NoLock( patt )

	FB_STRUNLOCK()

	return r
end function
end extern