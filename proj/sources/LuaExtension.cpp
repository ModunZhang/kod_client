//
//  LuaExtension.cpp
//  battlefront
//
//  Created by Modun on 14-4-9.
//
//

#include "LuaExtension.h"
#include "tolua_fix.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "CCPomelo.h"
#include "AppDelegate.h"
#include "crc/crc32.c"
#include "io/FileOperation.h"
#include "time/Time.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "jni/jni_CommonUtils.h"
#else
#include "common/CommonUtils.h"
#include "LocalNotification/LocalNotification.h"
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "GameCenter/GameCenter.h"
#endif
using namespace std;


static long getCurrentTime()
{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

static void tolua_reg_pomelo_type(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "CCPomelo");
}

static int tolua_CCPomelo_getInstance(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertable(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* tolua_ret = (CCPomelo*)  CCPomelo::getInstance();
        tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCPomelo");
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_destroyInstance(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertable(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo::destroyInstance();
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'destroyInstance'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_connect(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err) ||
        !toluafix_isfunction(tolua_S, 4, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,4,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_connect'\n", NULL);
            return 0;
        }
#endif
        const char* addr = tolua_tostring(tolua_S, 2, 0);
        int port = tolua_tonumber(tolua_S, 3, 0);
        LUA_FUNCTION func = toluafix_ref_function(tolua_S, 4, 0);
        CCLOG("trying connect %s:%d", addr, port);
        int status = pomelo->connect(addr, port);
        CCLOG("connect status:%d", status);
        auto stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushBoolean(status == 0);
        stack->executeFunctionByHandler(func, 1);
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_connect'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_asyncConnect(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err) ||
        !toluafix_isfunction(tolua_S, 4, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,5,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_connect'\n", NULL);
            return 0;
        }
#endif
        const char* addr = tolua_tostring(tolua_S, 2, 0);
        int port = tolua_tonumber(tolua_S, 3, 0);
        LUA_FUNCTION func = toluafix_ref_function(tolua_S, 4, 0);
        CCLOG("trying connect %s:%d", addr, port);
        pomelo->asyncConnect(addr, port, [=](const CCPomeloReponse& resp){
            CCLOG("connect status:%d", resp.status);
            auto stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushBoolean(resp.status == 0);
            stack->executeFunctionByHandler(func, 1);
        });
        
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_connect'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_stop(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_stop'\n", NULL);
            return 0;
        }
#endif
        CCLOG("disconnect from server");
        pomelo->stop();
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_stop'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_request(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !toluafix_isfunction(tolua_S, 4, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,5,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_request'\n", NULL);
            return 0;
        }
#endif
        const char* route = tolua_tostring(tolua_S, 2, 0);
        const char* msg = tolua_tostring(tolua_S, 3, 0);
        json_error_t err;
        json_t* msgj = json_loads(msg, JSON_COMPACT, &err);
        LUA_FUNCTION func = toluafix_ref_function(tolua_S, 4, 0);
        CCLOG("request route:%s", route);
        CCLOG("request message:%s", msg);
        pomelo->request(route, msgj, [=](const CCPomeloReponse& resp){
            char* msg = json_dumps(resp.docs, JSON_COMPACT);
            CCLOG("response status:%d", resp.status);
            CCLOG("response data:%s", msg);
            auto stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushBoolean(resp.status == 0);
            stack->pushString(msg);
            stack->executeFunctionByHandler(func, 2);
        });
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_request'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_notify(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !toluafix_isfunction(tolua_S, 4, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,5,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_notify'\n", NULL);
            return 0;
        }
#endif
        const char* route = tolua_tostring(tolua_S, 2, 0);
        const char* msg = tolua_tostring(tolua_S, 3, 0);
        json_error_t err;
        json_t* msgj = json_loads(msg, JSON_COMPACT, &err);
        LUA_FUNCTION func = toluafix_ref_function(tolua_S, 4, 0);
        CCLOG("notify route:%s", route);
        CCLOG("notify message:%s", msg);
        pomelo->notify(route, msgj, [=](const CCPomeloReponse& resp){
            CCLOG("notify status:%d", resp.status);
            auto stack = LuaEngine::getInstance()->getLuaStack();
            
            stack->pushBoolean(resp.status == 0);
            stack->executeFunctionByHandler(func, 1);
        });
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_notify'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_addListener(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !toluafix_isfunction(tolua_S, 3, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,4,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_addListener'\n", NULL);
            return 0;
        }
#endif
        const char* event = tolua_tostring(tolua_S, 2, 0);
        LUA_FUNCTION func = toluafix_ref_function(tolua_S, 3, 0);
        CCLOG("add event listener:%s", event);
        pomelo->addListener(event, [=](const CCPomeloReponse& resp){
            char* msg = json_dumps(resp.docs, JSON_COMPACT);
            CCLOG("event status:%d", resp.status);
            CCLOG("event data:%s", msg);
            auto stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushBoolean(resp.status == 0);
            stack->pushString(msg);
            stack->executeFunctionByHandler(func, 2);
        });
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_addListener'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_removeListener(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,3,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_removeListener'\n", NULL);
            return 0;
        }
#endif
        const char* event = tolua_tostring(tolua_S, 2, 0);
        CCLOG("remove event listener:%s", event);
        pomelo->removeListener(event);
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_removeListener'.",&tolua_err);
    return 0;
#endif
}

static int tolua_CCPomelo_cleanup(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"CCPomelo",0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        CCPomelo* pomelo = static_cast<CCPomelo*>(tolua_tousertype(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (nullptr == pomelo)
        {
            tolua_error(tolua_S,"invalid 'CCPomelo' in function 'tolua_CCPomelo_cleanup'\n", NULL);
            return 0;
        }
#endif
        CCLOG("pomelo cleanup");
        pomelo->cleanup();
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_CCPomelo_cleanup'.",&tolua_err);
    return 0;
#endif
}


TOLUA_API int tolua_cc_pomelo_open(lua_State* tolua_S)
{
    tolua_open(tolua_S);
    tolua_reg_pomelo_type(tolua_S);
    tolua_module(tolua_S,NULL,0);
    tolua_beginmodule(tolua_S, NULL);
    tolua_cclass(tolua_S,"CCPomelo","CCPomelo","",NULL);
    tolua_beginmodule(tolua_S,"CCPomelo");
    tolua_function(tolua_S, "getInstance", tolua_CCPomelo_getInstance);
    tolua_function(tolua_S, "destroyInstance", tolua_CCPomelo_destroyInstance);
    tolua_function(tolua_S, "connect", tolua_CCPomelo_connect);
    tolua_function(tolua_S, "asyncConnect", tolua_CCPomelo_asyncConnect);
    tolua_function(tolua_S, "stop", tolua_CCPomelo_stop);
    tolua_function(tolua_S, "request", tolua_CCPomelo_request);
    tolua_function(tolua_S, "notify", tolua_CCPomelo_notify);
    tolua_function(tolua_S, "addListener", tolua_CCPomelo_addListener);
    tolua_function(tolua_S, "removeListener", tolua_CCPomelo_removeListener);
    tolua_function(tolua_S, "cleanup", tolua_CCPomelo_cleanup);
    tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
    
	return 1;
}



static void tolua_reg_ext_type(lua_State* tolua_S)
{
    tolua_usertype(tolua_S, "ext");
}

static int tolua_ext_now(lua_State* tolua_S){
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isnoobj(tolua_S,1,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        
          double now;
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
        now = getCurrentTime();
#else
        now = Time::getTime();
#endif
        tolua_pushnumber(tolua_S, now);
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'now'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_copyText(lua_State* tolua_S){
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isstring(tolua_S,1,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* str = ((const char*)  tolua_tostring(tolua_S,1,0));
        CopyText(str);
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'createDir'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_createDirectory(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isstring(tolua_S,1,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* strFolderPath = ((const char*)  tolua_tostring(tolua_S,1,0));
        bool isCreated = FileOperation::createDirectory(strFolderPath);
        tolua_pushboolean(tolua_S,isCreated);
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'createDir'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_removeDirectory(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isstring(tolua_S,1,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* strFolderPath = ((const char*)  tolua_tostring(tolua_S,1,0));
        bool isRemoved = FileOperation::removeDirectory(strFolderPath);
        tolua_pushboolean(tolua_S,isRemoved);
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'createDir'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_isDirectoryExist(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isstring(tolua_S,1,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        FileUtils* self = FileUtils::getInstance();
        const char* strFolderPath = ((const char*)  tolua_tostring(tolua_S,1,0));
#ifndef TOLUA_RELEASE
        if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isDirectoryExist'", NULL);
#endif
        {
            bool isExist = self->isDirectoryExist(strFolderPath);
            tolua_pushboolean(tolua_S,isExist);
        }
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'isDirectoryExist'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_disableIdleTimer(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isboolean(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
        bool disable = tolua_toboolean(tolua_S, 1, 0);
        DisableIdleTimer(disable);
#endif
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'disableIdleTimer'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_restart(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isnoobj(tolua_S,1,&tolua_err) )
        goto tolua_lerror;
    else
#endif
    {
        AppDelegateExtern delegateExtern;
        Director::getInstance()->getScheduler()->schedule(schedule_selector(AppDelegateExtern::restartGame), &delegateExtern, 0, false, 0, false);
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'restart'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_crc32(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isstring(tolua_S,1,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* filePath = tolua_tostring(tolua_S, 1, 0);
        FILE *file = fopen(filePath, "rb");
#ifndef TOLUA_RELEASE
        if(file == NULL){
            tolua_err.index = 2;
            tolua_err.array = 0;
            tolua_err.type = "string";
            goto tolua_lerror;
        }
        else
#endif
        {
            char crc32S[32];
            unsigned long crc32;
            Crc32_ComputeFile(file, &crc32);
            sprintf(crc32S, "%08lx", crc32);
            tolua_pushstring(tolua_S, crc32S);
        }
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'crc32'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_close_keyboard(lua_State* tolua_S)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    CloseKeyboard();
#endif
    return 0;
}
static void ResgisterGlobalExtFunctions(lua_State* tolua_S)
{
    tolua_function(tolua_S, "now", tolua_ext_now);
    tolua_function(tolua_S, "createDirectory", tolua_ext_createDirectory);
    tolua_function(tolua_S, "removeDirectory", tolua_ext_removeDirectory);
    tolua_function(tolua_S, "isDirectoryExist", tolua_ext_isDirectoryExist);
    tolua_function(tolua_S, "crc32", tolua_ext_crc32);
    tolua_function(tolua_S, "restart", tolua_ext_restart);
    tolua_function(tolua_S, "copyText", tolua_ext_copyText);
    tolua_function(tolua_S, "disableIdleTimer", tolua_ext_disableIdleTimer);
    tolua_function(tolua_S, "closeKeyboard", tolua_ext_close_keyboard);
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    tolua_function(tolua_S,"getOpenUDID",tolua_ext_getOpenUDID);
#endif

}

static void RegisterExtModules(lua_State* tolua_S)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    tolua_ext_module_localpush(tolua_S); //local push
    tolua_ext_module_gamecenter(tolua_S);
#endif
}


TOLUA_API int tolua_cc_lua_extension(lua_State* tolua_S)
{
    tolua_open(tolua_S);
    tolua_reg_ext_type(tolua_S);
    tolua_module(tolua_S,NULL,0);
    tolua_beginmodule(tolua_S, NULL);
    tolua_cclass(tolua_S,"ext","ext","",NULL);
    tolua_beginmodule(tolua_S,"ext");
    ResgisterGlobalExtFunctions(tolua_S);
    RegisterExtModules(tolua_S);
    tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
    return 1;
}