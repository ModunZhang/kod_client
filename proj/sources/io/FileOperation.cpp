#include "cocos2d.h"
#include "FileOperation.h"
#include <stdio.h>
#include <string>
#include <copyfile.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

using namespace std;

typedef struct stat Stat;
static int do_mkdir(const char *path, mode_t mode)
{
    Stat            st;
    int             status = 0;
    
    if (stat(path, &st) != 0)
    {
        /* Directory does not exist. EEXIST for race condition */
        if (mkdir(path, mode) != 0 && errno != EEXIST)
            status = -1;
    }
    else if (!S_ISDIR(st.st_mode))
    {
        errno = ENOTDIR;
        status = -1;
    }
    
    return(status);
}

int mkpath(const char *path, mode_t mode)
{
    char           *pp;
    char           *sp;
    int             status;
    char           *copypath = strdup(path);
    
    status = 0;
    pp = copypath;
    while (status == 0 && (sp = strchr(pp, '/')) != 0)
    {
        if (sp != pp)
        {
            /* Neither root nor double slash in path */
            *sp = '\0';
            status = do_mkdir(copypath, mode);
            *sp = '/';
        }
        pp = sp + 1;
    }
    if (status == 0)
        status = do_mkdir(path, mode);
    free(copypath);
    return (status);
}

bool FileOperation::createDirectory(const char* path){
    int succ = mkpath(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if(succ != 0){
        return false;
    }
    return true;
}

bool FileOperation::removeDirectory(const char* path){
    int succ = remove(path);
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