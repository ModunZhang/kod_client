//
//  ext_uservoice.cpp
//  kod
//
//  Created by DannyHe on 1/4/15.
//
//

#include "ext_uservoice.h"
#import "UserVoice.h"
#define utf8strToNSString(str) [NSString stringWithUTF8String:str]
void OpenUserVoice(const char* site,int forumId,const char* email,const char* user_name,const char* guid)
{
    UVConfig *config = [UVConfig configWithSite:utf8strToNSString(site)]; //dannyhe.uservoice.com
    config.forumId = forumId; // 280112
    [config identifyUserWithEmail:utf8strToNSString(email) name:utf8strToNSString(user_name) guid:utf8strToNSString(guid)];
    [UserVoice initialize:config];
    // Call this wherever you want to launch UserVoice
    [UserVoice presentUserVoiceForumForParentViewController:[[[UIApplication sharedApplication]keyWindow] rootViewController]];
    
}