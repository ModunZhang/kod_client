#ifndef Android_jni_FileOperation_h
#define Android_jni_FileOperation_h
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

extern "C" {
	#include "tolua++.h"
	#include "tolua_fix.h"
}
class FileOperation 
{
public:
    static bool createDirectory(const char* path);
    static bool removeDirectory(const char* path);
    static bool copyFile(const char* from, const char* to);
};
#endif