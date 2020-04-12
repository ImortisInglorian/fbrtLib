# fbrtLib
FreeBASIC Runtime Library written in FreeBASIC

Attempt at writing the fbrt in freeBASIC to remove the dependence on C.

As I am working primarily on windows right now, here are build instructions for windows.

You will need:
* a working install of freeBASIC. See here: https://www.freebasic.net/forum/viewforum.php?f=1 
* a properly configured environment for compiling FB itself.  See here: https://www.freebasic.net/wiki/wikka.php?wakka=DevBuild
* a copy of the current rtlib source code. See here: https://github.com/freebasic/fbc
* a second copy of the freeBASIC folder structure for testing.

For the purpose of this I will assume the follow:
* fbc.exe installed in the following location: C:\fbc
* testing fbc at the following location: C:\fbcTest
* current rtlib source at following location: C:\fbsrc
* this project checked out as follwoing location: C:\fbrtlib

The current rtlib source from github is in the folder src\rtlib.  The files there are the onlt ones you need for this process.

Using the msys console, run the following commands:

```
cd /c/fbrtlib
make FBC=../fbc/fbc.exe FB_SRC_PATH=../fbsrc
```

Then you can go to C:\fbrtlib\lib\freebasic\win32\ and copy all three files out.  Paste them into C:\fbcTest\lib\win32\

You should now be able to compile using the generated libs.