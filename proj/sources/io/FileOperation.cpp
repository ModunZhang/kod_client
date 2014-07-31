#include "cocos2d.h"
#include "FileOperation.h"
#include <stdio.h>
#include <string>
#include <copyfile.h>
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#endif

using namespace std;

bool FileOperation::createDirectory(const char* path){
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, NULL);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
	{
		return false;
	}
    return true;
#endif
}

bool FileOperation::removeDirectory(const char* path){
    int succ = -1;
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    string command = "rm -r ";
    // Path may include space.
    command += "\"" + string(path) + "\"";
    succ = system(command.c_str());
#else
    string command = "rd /s /q ";
    // Path may include space.
    command += "\"" + string(path) + "\"";
    succ = system(command.c_str());
#endif
    if(succ != 0)
    {
        return false;
    }
    return true;
}

bool FileOperation::copyFile(const char* from, const char* to){
    copyfile_state_t _copyfileState;
    _copyfileState = copyfile_state_alloc();
    mode_t processMask = umask(0);
    int ret = copyfile(from, to, _copyfileState, COPYFILE_ALL);
    umask(processMask);
    copyfile_state_free(_copyfileState);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
}