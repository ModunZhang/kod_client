//
//  GameCenter.cpp
//  kod
//
//  Created by DannyHe on 12/16/14.
//
//

#include "GameCenter.h"
//MARK:IOS Part
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppController.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"


static void __CallLuaCallback(const char *gcName,const char *gcId)
{
    auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
    auto _state= stack->getLuaState();
    lua_pushstring(_state, "__G__GAME_CENTER_CALLBACK");
    lua_rawget(_state, LUA_GLOBALSINDEX);
    if (!lua_isfunction(_state, -1))
    {
        lua_pop(_state, 1);
    }
    else
    {
        if (strlen(gcName) > 0)
        {
            lua_pushstring(_state, gcName);
            lua_pushstring(_state, gcId);
        }
        else
        {
            lua_pushnil(_state);
            lua_pushnil(_state);
        }
        
        lua_pcall(_state, 2, 0, NULL);
    }
}

@interface KodGameCenter : NSObject<GKAchievementViewControllerDelegate>
{
    GKLocalPlayer*		_localPlayer;
}
@property (nonatomic, readonly) GKLocalPlayer* localPlayer;
+ (BOOL)isGameCenterAPIAvailable;
- (void)authenticate:(BOOL) forceLogin;
- (void)showAchivevementController;
@end
@implementation KodGameCenter
@synthesize localPlayer = _localPlayer;

- (id)init
{
    self = [super init];
    if(self)
    {
        _localPlayer = [[GKLocalPlayer localPlayer] retain];
    }
    return self;
}

- (void)dealloc
{
    [_localPlayer release];
    [super dealloc];
}

- (void)showAchivevementController
{
    GKAchievementViewController* achievementViewController = [[[GKAchievementViewController alloc] init] autorelease];
    achievementViewController.achievementDelegate = self;
    [[[[UIApplication sharedApplication]keyWindow] rootViewController]presentModalViewController:achievementViewController animated:YES];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [viewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)isAuthenticated
{
    return self.localPlayer.isAuthenticated;
}

+ (BOOL)isGameCenterAPIAvailable
{
    Class gcClass = NSClassFromString(@"GKLocalPlayer");
    
    BOOL osVersionSupported = [[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending;
    
    return gcClass && osVersionSupported;
}

- (void)authenticate:(BOOL) forceLogin
{
   
    if ([self isAuthenticated])
    {
        __CallLuaCallback([self.localPlayer.alias UTF8String],[self.localPlayer.playerID UTF8String]);
        return;
    };
    if (forceLogin)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
        return;
    }
    
    if (![KodGameCenter isGameCenterAPIAvailable])
    {
        __CallLuaCallback("","");
        return;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        [self.localPlayer authenticateWithCompletionHandler:^(NSError *error)
         {
             [self checkLocalPlayer];
         }];
    }
    else
    {
        [self.localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
            if (!error && viewcontroller)
            {
                [[[[UIApplication sharedApplication]keyWindow] rootViewController]presentViewController:viewcontroller animated:YES completion:nil];
            }
            else
            {
                [self checkLocalPlayer];
            }
        })];
    }
}
- (void)checkLocalPlayer
{
    if(self.localPlayer.authenticated) // Authentication Successful
    {
        __CallLuaCallback([self.localPlayer.alias UTF8String],[self.localPlayer.playerID UTF8String]);
    }
    else
    {
        __CallLuaCallback("","");
    }
}
@end



//MARK:C Part
static KodGameCenter *shareIntance = nil;
static int tolua_GameCenter_isGameCenterEnabled(lua_State *tolua_S)
{
    if ([KodGameCenter isGameCenterAPIAvailable])
    {
        lua_pushboolean(tolua_S, true);
        if (shareIntance == NULL)
        {
            shareIntance = [[KodGameCenter alloc]init];
        }
        
    }else
    {
        lua_pushboolean(tolua_S, false);
    }
    return 1;
}
static int tolua_GameCenter_showAchivevementController(lua_State *L)
{
    [shareIntance showAchivevementController];
    return 0;
}

static int tolua_GameCenter_authenticate(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isboolean(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        [shareIntance authenticate:tolua_toboolean(tolua_S, 1, 0)?YES:NO];
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_GameCenter_authenticate'.",&tolua_err);
    return 0;
#endif
}
static int tolua_GameCenter_isAuthenticated(lua_State *tolua_S)
{
    tolua_pushboolean(tolua_S,[shareIntance isAuthenticated]?true:false);
    return 1;
}

static int tolua_GameCenter_getPlayerNameAndId(lua_State *tolua_S)
{
    if([shareIntance isAuthenticated])
    {
        lua_pushstring(tolua_S, [[[shareIntance localPlayer]alias]UTF8String]);
        lua_pushstring(tolua_S, [[[shareIntance localPlayer]playerID]UTF8String]);
    }
    else
    {
        lua_pushnil(tolua_S);
        lua_pushnil(tolua_S);
    }
    return 2;
}

//MARK:Lua Part
void tolua_ext_module_gamecenter(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_GAMECENTER,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_GAMECENTER);
    tolua_function(tolua_S,"isGameCenterEnabled",tolua_GameCenter_isGameCenterEnabled);
    tolua_function(tolua_S,"authenticate",tolua_GameCenter_authenticate);
    tolua_function(tolua_S,"showAchivevementController",tolua_GameCenter_showAchivevementController);
    tolua_function(tolua_S,"isAuthenticated",tolua_GameCenter_isAuthenticated);
    tolua_function(tolua_S,"getPlayerNameAndId",tolua_GameCenter_getPlayerNameAndId); /** `return alias,playerID` in lua **/
    tolua_endmodule(tolua_S);
}
