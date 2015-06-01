//
//  LuaExtension.h
//  battlefront
//
//  Created by Modun on 14-4-9.
//
//

#ifndef __battlefront__LuaExtension__
#define __battlefront__LuaExtension__
#include "tolua++.h"

TOLUA_API int tolua_cc_pomelo_open(lua_State* tolua_S);
TOLUA_API int tolua_cc_lua_extension(lua_State* tolua_S);
unsigned long getFileCrc32(const char* filePath);


#include "2d/CCTransition.h"
NS_CC_BEGIN
int lua_register_cocos2dx_TransitionCustom(lua_State* tolua_S);


class CC_DLL TransitionCustom : public TransitionScene
{
public:
    static TransitionCustom* create(float duration, Scene* scene);
    void hideOutEnterShow();
    virtual void onEnter() override;
    virtual void onExit() override;
CC_CONSTRUCTOR_ACCESS:
    TransitionCustom();
    virtual ~TransitionCustom();
private:
    CC_DISALLOW_COPY_AND_ASSIGN(TransitionCustom);
};

NS_CC_END


#endif /* defined(__battlefront__LuaExtension__) */
