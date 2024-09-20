/' fre() function '/

#include "../fb.bi"
'from mach/mach_host.h
type mach_msg_type_number_t as ulong
type integer_t as long
#define HOST_VM_INFO_COUNT ((mach_msg_type_number_t) \ (sizeof(vm_statistics_data_t)/sizeof(integer_t)))

Type vm_statistics
	as ulong       free_count             /' # of pages free '/
	as ulong       active_count           /' # of pages active '/
	as ulong       inactive_count         /' # of pages inactive '/
	as ulong       wire_count             /' # of pages wired down '/
	as ulong       zero_fill_count        /' # of zero fill pages '/
	as ulong       reactivations          /' # of pages reactivated '/
	as ulong       pageins                /' # of pageins '/
	as ulong       pageouts               /' # of pageouts '/
	as ulong       faults                 /' # of faults '/
	as ulong       cow_faults             /' # of copy-on-writes '/
	as ulong       lookups                /' object cache lookups '/
	as ulong       hits                   /' object cache hits '/

	/' added for rev1 '/
	as ulong       purgeable_count        /' # of pages purgeable '/
	as ulong       purges                 /' # of pages purged '/

	/' added for rev2 '/
	/'
	 * NB: speculative pages are already accounted for in "free_count",
	 * so "speculative_count" is the number of "free" pages that are
	 * used to hold data that was read speculatively from disk but
	 * haven't actually been used by anyone so far.
	 '/
	as ulong       speculative_count      /' # of pages speculative '/
end type

/' Used by all architectures '/
type vm_statistics_data_t as vm_statistics


'from mach/host_info.h
#define HOST_VM_INFO		2	/' Virtual memory stats '/
#define KERN_SUCCESS    0
type kern_return_t as long
type host_t as ulong
type host_flavor_t as long
type host_info_t as long

extern "C"
declare function host_statistics(host_priv as host_t, flavor as host_flavor_t, host_info_out as host_info_t, host_info_outCnt as mach_msg_type_number_t ptr) as kern_return_t
declare function extern getpagesize() as long
#include "crt/unistd.bi"

function fb_GetMemAvail  FBCALL ( mode as long ) as size_t
	dim as vm_statistics_data_t vmstat
	dim as ulong count = HOST_VM_INFO_COUNT
	if host_statistics( mach_host_self(), HOST_VM_INFO, cast(host_info_t, @vmstat), @count) <> KERN_SUCCESS  then
      return 0
   end if 
	return vmstat.free_count * getpagesize()
end function
end extern