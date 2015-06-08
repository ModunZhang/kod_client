//
//  LocalNotification.cpp
//  kod
//
//  Created by Dannyhe on 8/23/14.
//
//

#include "LocalNotification.h"
#import <UIKit/UIKit.h>
#include <map>
#include <string>

static std::map<std::string, bool> m_localNotificationState;

NSMutableDictionary *m_localNotification_dictionary = NULL;


static void _cancelAllLocalDic()
{
    if (m_localNotification_dictionary == NULL)
    {
         m_localNotification_dictionary = [[NSMutableDictionary alloc]init];
    }
    if (m_localNotification_dictionary != NULL)
    {
        [m_localNotification_dictionary removeAllObjects];
    }
}

static  bool _cancelNotificationWithIdentity(NSString *identity)
{
    if (m_localNotification_dictionary != NULL)
    {
        UILocalNotification *exist_notification = [m_localNotification_dictionary objectForKey:identity];
        if (exist_notification)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:exist_notification];
            [m_localNotification_dictionary removeObjectForKey:identity];
            NSLog(@"cancelNotificationWithIdentity------>%@",identity);
            return true;
        }
    }
    return false;
}

static void _addLocalDic(NSString *identity,UILocalNotification *localNotification)
{    
    _cancelNotificationWithIdentity(identity);
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [m_localNotification_dictionary setObject:localNotification forKey:identity];
#ifdef DEBUG
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *notifDate = [formatter stringFromDate:localNotification.fireDate];
    NSLog(@"scheduleLocalNotification--->%@:@%@",identity,notifDate);
#endif

}



void cancelAll()
{
    NSLog(@"cancelAll------>");
    _cancelAllLocalDic();
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

void switchNotification(const char *type, bool enable)
{
    std::map<std::string, bool>::iterator it = m_localNotificationState.find(type);
    if (it != m_localNotificationState.end())
    {
        m_localNotificationState.erase(it);
    }
    
    m_localNotificationState.insert(std::pair<std::string, bool>(type, enable));
}

bool addNotification(const char *type, long finishTime, const char *body, const char* identity)
{
    std::map<std::string, bool>::const_iterator it = m_localNotificationState.find(type);
    if (it != m_localNotificationState.end())
    {
        if ( !it->second )
        {
            return false;
        }
    }
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[[NSDate alloc] initWithTimeIntervalSince1970:finishTime] autorelease];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithUTF8String:identity], @"identity",nil];
    localNotification.alertBody = [NSString stringWithCString:body encoding:NSUTF8StringEncoding];
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    _addLocalDic([NSString stringWithUTF8String:identity],localNotification);
    [localNotification release];
    return true;
}

bool cancelNotificationWithIdentity(const char* identity)
{
    if (_cancelNotificationWithIdentity([NSString stringWithUTF8String:identity]))
    {
        return true;
    }
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSString *identity_ns = [NSString stringWithUTF8String:identity];
    for (UILocalNotification *notification in notifications)
    {
        
        NSString* identityObject = (NSString*)[notification.userInfo objectForKey:@"identity"];
        if (identityObject && [identityObject isEqualToString:identity_ns])
        {
            NSLog(@"cancelNotificationWithIdentity------>%@",identity_ns);
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            return  true;
        }
    }
    return  false;
}

static int tolua_localpush_cancelAll(lua_State* tolua_S)
{
    cancelAll();
    return 0;
}

static int tolua_localpush_addNotification(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if ((lua_gettop(tolua_S)< 4) ||
        !tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 4, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* type = tolua_tostring(tolua_S, 1, 0);
        long finishTime  = tolua_tonumber(tolua_S, 2,0);
        const char* body = tolua_tostring(tolua_S, 3, 0);
        const char* identity = "";
        if (lua_gettop(tolua_S) > 3)
        {
            identity = tolua_tostring(tolua_S, 4, 0);
        }
        bool r = addNotification(type, finishTime, body,identity);
        tolua_pushboolean(tolua_S,r);
        return 1;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_addNotification'.",&tolua_err);
#endif
    return 0;
}

static int tolua_localpush_switchNotification(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (lua_gettop(tolua_S)!= 2)
        goto tolua_lerror;
    else
#endif
    {
        const char* type = tolua_tostring(tolua_S, 1, 0);
        bool  enable  = tolua_toboolean(tolua_S, 2, 0);
        switchNotification(type,enable);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_switchNotification'.",&tolua_err);
#endif
    return 0;
}


static int tolua_localpush_cancelNotificationWithIdentity(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (lua_gettop(tolua_S)!= 1)
        goto tolua_lerror;
    else
#endif
    {
        const char* identity = tolua_tostring(tolua_S, 1, 0);
        bool r = cancelNotificationWithIdentity(identity);
        tolua_pushboolean(tolua_S, r);
        return 1;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_cancelNotificationWithIdentity'.",&tolua_err);
#endif
    return 0;
}

void tolua_ext_module_localpush(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME);
    tolua_function(tolua_S,"cancelAll",tolua_localpush_cancelAll);
    tolua_function(tolua_S,"addNotification",tolua_localpush_addNotification);
    tolua_function(tolua_S,"switchNotification",tolua_localpush_switchNotification);
    tolua_function(tolua_S,"cancelNotification",tolua_localpush_cancelNotificationWithIdentity);
    tolua_endmodule(tolua_S);
}
