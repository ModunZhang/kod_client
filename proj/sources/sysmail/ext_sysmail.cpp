//
//  ext_sysmail.cpp
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#include "ext_sysmail.h"

#include "Sysmail.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"

void OnSendMailEnd(int function_id,const char *event)
{
     auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
    if (strlen(event) > 0)
    {
        stack->pushString(event);
    }
    else
    {
        stack->pushNil();
    }
    stack->executeFunctionByHandler(function_id, 1);
}

static int tolua_sysmail_sendmail(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!toluafix_isfunction(tolua_S, 4, "LUA_FUNCTION", 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 4, 0);
        bool success = SendMail(tolua_tostring(tolua_S, 1, 0), tolua_tostring(tolua_S, 2, 0), tolua_tostring(tolua_S, 3, 0), func);
        lua_pushboolean(tolua_S, success?(1):(0));
        return 1;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_sysmail_sendmail'.",&tolua_err);
    return 0;
#endif
}

static int tolua_sysmail_can_sendmail(lua_State *tolua_S)
{
    lua_pushboolean(tolua_S, CanSenMail());
    return 1;
}

void tolua_ext_module_sysmail(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_SYSMAIL,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_SYSMAIL);
    tolua_function(tolua_S,"sendMail",tolua_sysmail_sendmail);
    tolua_function(tolua_S,"canSendMail",tolua_sysmail_can_sendmail);
    tolua_endmodule(tolua_S);
}