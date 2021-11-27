#ifdef HOST_LINUX

'' mkdir has an extra parameter on non Windows
'' These are from the glibc manual
'' https://www.gnu.org/software/libc/manual/html_node/Permission-Bits.html
#define S_IRUSR &O0400
#define S_IWUSR &O0200
#define S_IXUSR &O0100
#define S_IRWXU ( S_IXUSR or S_IWUSR or S_IRUSR )
#define S_IRGRP &O0040
#define S_IWGRP &O0020
#define S_IXGRP &O0010
#define S_IRWXG ( S_IXGRP or S_IWGRP or S_IRGRP )
#define S_IROTH &O0004
#define S_IWOTH &O0002
#define S_IXOTH &O0001
#define S_IRWXO ( S_IXOTH or S_IWOTH or S_IROTH )
#define S_ISUID &O04000
#define S_ISGID &O02000
#define S_ISVTX &O01000

#define S_IREAD S_IRUSR
#define S_IWRITE S_IWUSR
#define S_IEXEC S_IXUSR

extern "C"

declare function _mkdir alias "mkdir" cdecl (byval newdir as zstring ptr, byval perm as long) as long

end extern

#endif