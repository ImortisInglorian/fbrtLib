/' instr function '/

#include "fb.bi"

/'' Searches for a sub-string using the Quick Search algorithm.
 *
 * - simplification of the Boyer-Moore algorithm
 * - uses only the bad-character shift
 * - easy to implement
 * - preprocessing phase in O(m + o-) time and O(o-) space complexity
 * - searching phase in O(m * n) time complexity
 * - very fast in practice for short patterns and large alphabets
 *
 * o- = greek letter "sigma"
 *
 * From "Handbook of Exact String-Matching Algorithms" by
 * Christian Charras and Thierry Lecroq
 * ( http://www-igm.univ-mlv.fr/~lecroq/string/string.pdf ).
 '/

extern "C"
/'
static ssize_t fb_hFindQS
	(
		ssize_t start,
		const char *pachText,
		ssize_t len_text,
		const char *pachPattern,
		ssize_t len_pattern
	)
{
	ssize_t max_size = len_text - len_pattern + 1;
	ssize_t qs_bc[256];
	ssize_t i;

	/* create "bad character" shifts */
	for( i=0; i!=256; ++i)
		qs_bc[ i ] = len_pattern + 1;
	for( i=0; i!=len_pattern; ++i )
		qs_bc[ FB_CHAR_TO_INT(pachPattern[i]) ] = len_pattern - i;

	/* search for string */
	for (i=start;
		i<max_size;
		i+=qs_bc[ FB_CHAR_TO_INT(pachText[ i + len_pattern ]) ])
	{
		if( memcmp( pachPattern, pachText + i, len_pattern )==0 ) {
			return i + 1;
		}
	}

	return 0;
}
'/

/'
 * Searches for a sub-string using the Boyer-Moore algorithm.
 *
 * - performs the comparisons from right to left
 * - preprocessing phase in O(m + o-) time and space complexity
 * - searching phase in O(m * n) time complexity
 * - 3n text character comparisons in the worst case when searching
 *   for a non periodic pattern
 * - O(n / m) best performance
 *
 * o- = greek letter "sigma"
 *
 * From "Handbook of Exact String-Matching Algorithms" by
 * Christian Charras and Thierry Lecroq
 * ( http://www-igm.univ-mlv.fr/~lecroq/string/string.pdf ).
 *
 * Implementation from
 * http://www.iti.fh-flensburg.de/lang/algorithmen/pattern/bm.htm
 '/

function fb_hFindBM cdecl ( start as ssize_t, pachText as const ubyte ptr, len_text as ssize_t, pachPattern as const ubyte ptr, len_pattern as ssize_t ) as ssize_t
	dim as ssize_t i, j, len_max = len_text - len_pattern
	dim as ssize_t bm_bc(0 to 255)
	dim as ssize_t ptr bm_gc, suffixes
	dim as ssize_t ret

	bm_gc = cast(ssize_t ptr, malloc(sizeof(ssize_t) * (len_pattern + 1)))
	suffixes = cast(ssize_t ptr, malloc(sizeof(ssize_t) * (len_pattern + 1)))

	memset( bm_gc, 0, sizeof(ssize_t) * (len_pattern+1) )
	memset( suffixes, 0, sizeof(ssize_t) * (len_pattern+1) )

	/' create "bad character" shifts '/
	memset(@bm_bc(0), -1, ARRAY_SIZEOF(bm_bc))
	for i=0 to len_pattern - 1
		bm_bc( FB_CHAR_TO_INT(pachPattern[i]) ) = i
	next
	
	/' preprocessing for "good end strategy" case 1 '/
	i = len_pattern
	j = len_pattern + 1
	suffixes[ i ] = j

	while ( i <> 0 )
		dim as ubyte ch1 = pachPattern[i - 1]
		while ( j <= len_pattern and ch1 <> pachPattern[j-1] )
			if ( bm_gc[j] = 0 ) then
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
	for  i=0 to len_pattern - 1
		if ( bm_gc[i] = 0 ) then
			bm_gc[i] = j
		end if
		if( i = j ) then
			j = suffixes[j]
		end if
	next

	ret = 0

	/' search '/
	i = start
	while( i <= len_max )
		j = len_pattern

		while( j <> 0 andalso pachPattern[ j - 1] = pachText[i + j - 1] )
			j -= 1
		wend
		if( j = 0 ) then
			ret = i + 1
			exit while
		else
			dim as ubyte chText = pachText[i + j - 1]
			dim as ssize_t shift_gc = bm_gc[j]
			dim as ssize_t shift_bc = j - 1 - bm_bc( FB_CHAR_TO_INT(chText) )
			i += iif( (shift_gc > shift_bc), shift_gc, shift_bc )
		end if
	wend

	free( bm_gc )
	free( suffixes )

	return ret
end function

/'
static ssize_t fb_hFindNaive
	(
		ssize_t start,
		const char *pachText,
		ssize_t len_text,
		const char *pachPattern,
		ssize_t len_pattern
	)
{
	ssize_t i;
	ssize_t imax = (len_text - len_pattern + 1);
	pachText += start;
	if( start < imax )
	{
		for( i=start; i != imax; ++i ) {
			ssize_t j;
			for( j=0; j!=len_pattern; ++j ) {
				if( pachText[j]!=pachPattern[j] )
					break;
			}
			if( j==len_pattern )
				return i + 1;
			++pachText;
		}
	}
	return 0;
}
'/

function fb_StrInstr FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
	dim as ssize_t r

	if ( (src = NULL) orelse (src->data = NULL) orelse (patt = NULL) orelse (patt->data = NULL) ) then
		r = 0
	else
		dim as ssize_t size_src = FB_STRSIZE(src)
		dim as ssize_t size_patt = FB_STRSIZE(patt)

		if ( (size_src = 0) orelse (size_patt = 0) orelse ((start < 1) orelse (start > size_src)) orelse (size_patt > size_src) ) then
			r = 0
		elseif ( size_patt = 1 ) then
			dim as const ubyte ptr pszEnd = cast(const ubyte ptr, FB_MEMCHR( src->data + start - 1, patt->data[0], size_src - start + 1))
			if ( pszEnd = NULL ) then
				r = 0
			else
				r = pszEnd - src->data + 1
			end if
		else
			r = fb_hFindBM( start - 1, src->data, size_src, patt->data, size_patt )
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