#ifndef Android_jni_CommonUtils_h
#define Android_jni_CommonUtils_h
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

extern "C" {
	#include "tolua++.h"
	#include "tolua_fix.h"
}
int tolua_ext_getOpenUDID(lua_State* tolua_S);
//copy text to Pasteboard
void CopyText(const char * text);
#endif