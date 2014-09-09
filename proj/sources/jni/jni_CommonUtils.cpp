#include "jni_CommonUtils.h"
#define LOG_TAG ("jni_CommonUtils.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/kod/jni/JniCommonUtils"

static char* m_UDID = NULL;

int tolua_ext_getOpenUDID(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isnoobj(tolua_S,1,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
#ifdef OS_ANDROID
    	if (m_UDID == NULL)
    	{
    		cocos2d::JniMethodInfo t;
		    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getOpenUDID", "()Ljava/lang/String;")) {

				jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
				const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

				m_UDID = new char[strlen(resultC) + 2];
				strcpy(m_UDID, resultC);
				t.env->ReleaseStringUTFChars(jResult, resultC);
				t.env->DeleteLocalRef(jResult);

				tolua_pushstring(tolua_S, m_UDID);
		    	return 1;
			}
    	}else
    	{
    		tolua_pushstring(tolua_S, m_UDID);
		    return 1;
    	}
#endif
	return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'getOpenUDID'.",&tolua_err);
    return 0;
#endif
}
//copy file
void CopyText(const char * text){
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "copyText", "()Ljava/lang/String;")) {
        jstring jtext = t.env->NewStringUTF(text);
        t.env->CallStaticVoidMethod(t.classID,t.methodID,jtext);
        t.env->DeleteLocalRef(jtext);
    }
}