#include "jni_FileOperation.h"
#define LOG_TAG ("jni_LuaExtension.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/kod/jni/JniFileOperation"

bool FileOperation::createDirectory(const char* path){
	cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "createDir", "(Ljava/lang/String;)Z")) {
		jstring jFilename =  t.env->NewStringUTF(path);
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jFilename);
		t.env->DeleteLocalRef(jFilename);
		t.env->DeleteLocalRef(t.classID);
	}
	return ret;
}

bool FileOperation::removeDirectory(const char* path){
	cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "removeDir", "(Ljava/lang/String;)Z")) {
		jstring jFilename =  t.env->NewStringUTF(path);
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jFilename);
		t.env->DeleteLocalRef(jFilename);
		t.env->DeleteLocalRef(t.classID);
	}
    return ret;
}

bool FileOperation::copyFile(const char* from, const char* to){
    cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "copyFileTo", "(Ljava/lang/String;Ljava/lang/String;)Z")) {
		jstring jfrom =  t.env->NewStringUTF(from);
		jstring jto =  t.env->NewStringUTF(to);
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jfrom,jto);
		t.env->DeleteLocalRef(jfrom);
		t.env->DeleteLocalRef(jto);
		t.env->DeleteLocalRef(t.classID);
	}
	return ret;
}