#ifdef PCC_MINGW

#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>
#undef SOCKET
#include <winsock2.h>

typedef unsigned int uint;

//#include <my_global.h>


#endif //PCC_MINGW