#include "cocos2d.h"
#include "FileOperation.h"
#include <stdio.h>
#include <string>
#include <copyfile.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

using namespace std;

bool FileOperation::createDirectory(const char* path){
    string command = "mkdir -p ";
    // Path may include space.
    command += "\"" + string(path) + "\"";
    int succ = system(command.c_str());
    
    if(succ != 0){
        return false;
    }
    return true;
}

bool FileOperation::removeDirectory(const char* path){
    string command = "rm -r ";
    // Path may include space.
    command += "\"" + string(path) + "\"";
    int succ = system(command.c_str());

    if(succ != 0){
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