extern "C"
declare function fb_LCASE           FBCALL ( src as FBSTRING ptr, dst as FBSTRING ptr ) as FBSTRING ptr
declare function fb_UCASE           FBCALL ( src as FBSTRING ptr, dst as FBSTRING ptr ) as FBSTRING ptr

declare function fb_WstrLcase       FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrUcase       FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
end extern