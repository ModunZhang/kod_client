#ifndef __HELLOWORLD_FILE_OPERATION__
#define __HELLOWORLD_FILE_OPERATION__

class FileOperation 
{
public:
    static bool createDirectory(const char* path);
    static bool removeDirectory(const char* path);
    static bool copyFile(const char* from, const char* to);
};

#endif
