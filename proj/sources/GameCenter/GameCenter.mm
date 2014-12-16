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

typedef void (^AuthenticateCallback)(const char*,const char*);
@interface KodGameCenter : NSObject<GKAchievementViewControllerDelegate>
{
    GKLocalPlayer*		_localPlayer;
    NSMutableDictionary* _achievements;
}
@property (nonatomic, readonly) GKLocalPlayer* localPlayer;
@property (nonatomic, readonly) NSDictionary* achievements;
@property (nonatomic, readonly) BOOL isAuthenticated;
+ (BOOL)isGameCenterAPIAvailable;
- (void)authenticate:(AuthenticateCallback) callback;
- (void)reportScore:(int64_t)value withCategoryIdentifier:(NSString*)categoryIdentifier;
- (void)reportAchievementComplete:(double)percentComplete withIdentifier:(NSString*)achievementIdentifier;
- (void)reportAchievementComplete:(double)percentComplete
                   withIdentifier:(NSString*)achievementIdentifier
                     alsoComplete:(NSArray*)otherAchievementIdentifiers;
- (void)showAchivevementController;
- (void)loadAchievements;
@end
@implementation KodGameCenter
@synthesize achievements = _achievements;
@synthesize localPlayer = _localPlayer;

- (id)init
{
    self = [super init];
    if(self)
    {
        _localPlayer = [[GKLocalPlayer localPlayer] retain];
#ifdef COCOS2D_DEBUG
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GKPlayerChangedNotifaction) name:
         GKPlayerDidChangeNotificationName object:nil];
#endif
    }
    return self;
}

- (void)dealloc
{
    [_localPlayer release];
    [_achievements release];
    
    [super dealloc];
}
#ifdef COCOS2D_DEBUG
-(void)GKPlayerChangedNotifaction{
    CCLOG("GKPlayerChangedNotifaction-->%d",[self isAuthenticated]);
}
#endif

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

- (NSString*)identifier:(NSString*)identifier
{
    return identifier;
}

- (NSDictionary*)achievements
{
    return _achievements;
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

- (void)authenticate:(AuthenticateCallback) callback
{
    if([KodGameCenter isGameCenterAPIAvailable] && !self.isAuthenticated)
    {
        [self.localPlayer authenticateWithCompletionHandler:^(NSError* error)
         {
             if(self.localPlayer.authenticated) // Authentication Successful
             {
                 [self loadAchievements];
                 CCLOG("Enter Game Center -->%s,%s",[[GKLocalPlayer localPlayer].alias UTF8String],[[GKLocalPlayer localPlayer].playerID UTF8String]);
                 callback([[GKLocalPlayer localPlayer].alias UTF8String],[[GKLocalPlayer localPlayer].playerID UTF8String]);
             }
             else
             {
                 CCLOG("Disable Game Center->%s",[[error localizedDescription] UTF8String]);
                 callback("","");
             }
         }];
    }
}

- (void)reportScore:(int64_t)value withCategoryIdentifier:(NSString*)categoryIdentifier
{
    if(self.isAuthenticated)
    {
        GKScore* score = [[[GKScore alloc] initWithCategory:categoryIdentifier] autorelease];
        score.value = value;
        //	score.context = updatedStatistics;
        [score reportScoreWithCompletionHandler:^(NSError* error)
         {
             if(error)
             {
                 CCLOG("Report Score(%lld) for category(%s) Failed!", value, [categoryIdentifier UTF8String]);
             }
             else
             {
                 CCLOG("Report Score(%lld) for category(%s) Successfully!", value, [categoryIdentifier UTF8String]);
             }
         }];
    }
}

- (void)reportAchievementComplete:(double)percentComplete withIdentifier:(NSString*)achievementIdentifier
{
    [self reportAchievementComplete:percentComplete withIdentifier:achievementIdentifier alsoComplete:nil];
}

- (void)reportAchievementComplete:(double)percentComplete
                   withIdentifier:(NSString*)achievementIdentifier
                     alsoComplete:(NSArray*)otherAchievementIdentifiers
{
    if(self.isAuthenticated && _achievements)
    {
        achievementIdentifier = [self identifier:achievementIdentifier];
        GKAchievement* achievement = [self.achievements objectForKey:achievementIdentifier];
        if(!achievement || achievement.percentComplete != percentComplete)
        {
            achievement = [[[GKAchievement alloc] initWithIdentifier:achievementIdentifier] autorelease];
            achievement.percentComplete = percentComplete;
            if([achievement respondsToSelector:@selector(setShowsCompletionBanner:)])
                achievement.showsCompletionBanner = YES;
            [achievement reportAchievementWithCompletionHandler:^(NSError* error)
             {
                 if(error) // only should occur duration development
                 {
                     CCLOG("Report Achievement(%s) Failed!", [achievementIdentifier UTF8String]);
                 }
                 else // submitted successfully
                 {
                     CCLOG("Report Achievement(%s) Sucessfully!", [achievementIdentifier UTF8String]);
                     
                     // add to complete list
                     [_achievements setObject:achievement forKey:achievementIdentifier];
                 }
             }];
        }
        
        for(NSString* identifier in otherAchievementIdentifiers)
        {
            [self reportAchievementComplete:100.0 withIdentifier:identifier];
        }
    }
}

- (void)loadAchievements
{
    if(self.isAuthenticated)
    {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* achievements, NSError* error)
         {
             if(nil == error)
             {
                 [_achievements release];
                 _achievements = [[NSMutableDictionary alloc] init];
                 for(GKAchievement* anAchievement in achievements)
                 {
                     [_achievements setObject:anAchievement forKey:anAchievement.identifier];
                 }
             }
             else
             {
                 // handle error
                 CCLOG("Load achievement failed, error: %s", [[error localizedDescription]UTF8String]);
             }
         }];
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
    if (!toluafix_isfunction(tolua_S, 1, "LUA_FUNCTION", 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 1, 0);
        [shareIntance authenticate:^(const char*Name,const char*Id){
            auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
            if (strlen(Name) > 0)
            {
                stack->pushString(Name);
            }
            else
            {
                stack->pushNil();
            }
            if (strlen(Id) > 0)
            {
                stack->pushString(Id);
            }
            else
            {
                stack->pushNil();
            }
            stack->executeFunctionByHandler(func, 2);
        }];
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_GameCenter_authenticate'.",&tolua_err);
    return 0;
#endif
}

static int tolua_GameCenter_reportScore(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) || !tolua_isnumber(tolua_S, 2, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        const char* achievementIdentifier = tolua_tostring(tolua_S, 1, 0);
        int64_t score = tolua_tonumber(tolua_S, 2, 0);
        NSString* achievementIdentifierOC = [NSString stringWithCString:achievementIdentifier encoding:NSASCIIStringEncoding];
        [shareIntance reportScore:score withCategoryIdentifier:achievementIdentifierOC];
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_GameCenter_reportScore'.",&tolua_err);
    return 0;
#endif
}

static int tolua_GameCenter_reportAchievementComplete(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) || !tolua_isnumber(tolua_S, 2, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        const char* achievementIdentifier = tolua_tostring(tolua_S, 1, 0);
        double percentComplete = tolua_tonumber(tolua_S, 2, 0);
        NSString* achievementIdentifierOC = [NSString stringWithCString:achievementIdentifier encoding:NSASCIIStringEncoding];
        [shareIntance reportAchievementComplete:percentComplete withIdentifier:achievementIdentifierOC];
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_GameCenter_reportAchievementComplete'.",&tolua_err);
    return 0;
#endif
}

static int tolua_GameCenter_reportAchievementCompleteWithOthers(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) || !tolua_isnumber(tolua_S, 2, 0, &tolua_err)||!tolua_istable(tolua_S, 3, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        const char* achievementIdentifier = tolua_tostring(tolua_S, 1, 0);
        double percentComplete = tolua_tonumber(tolua_S, 2, 0);
        NSString* achievementIdentifierOC = [NSString stringWithCString:achievementIdentifier encoding:NSASCIIStringEncoding];
        NSMutableArray *array = [NSMutableArray array];
        int tableLen = lua_objlen(tolua_S, 3);
        for ( int i = 1; i <= tableLen; ++i ) {
            lua_pushinteger(tolua_S, i);
            lua_gettable(tolua_S, -2);
            const char  *key = lua_tostring(tolua_S, -1);
            if(strlen(key)>0)
            {
                [array addObject:[NSString stringWithCString:key encoding:NSASCIIStringEncoding]];
            }
            lua_pop( tolua_S, 1 );
        }
        [shareIntance reportAchievementComplete:percentComplete withIdentifier:achievementIdentifierOC alsoComplete:array];
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_GameCenter_reportAchievementCompleteWithOthers'.",&tolua_err);
    return 0;
#endif

}

static int tolua_GameCenter_isAuthenticated(lua_State *tolua_S)
{
    tolua_pushboolean(tolua_S,[shareIntance isAuthenticated]?true:false);
    return 1;
}

//MARK:Lua Part
void tolua_ext_module_gamecenter(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_GAMECENTER,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_GAMECENTER);
    tolua_function(tolua_S,"isGameCenterEnabled",tolua_GameCenter_isGameCenterEnabled);
    tolua_function(tolua_S,"authenticate",tolua_GameCenter_authenticate);
    tolua_function(tolua_S,"reportAchievementComplete",tolua_GameCenter_reportAchievementComplete);
    tolua_function(tolua_S,"reportAchievementCompleteWithOthers",tolua_GameCenter_reportAchievementCompleteWithOthers);
    tolua_function(tolua_S,"reportScore",tolua_GameCenter_reportScore);
    tolua_function(tolua_S,"showAchivevementController",tolua_GameCenter_showAchivevementController);
    tolua_function(tolua_S,"isAuthenticated",tolua_GameCenter_isAuthenticated);
    tolua_endmodule(tolua_S);
}