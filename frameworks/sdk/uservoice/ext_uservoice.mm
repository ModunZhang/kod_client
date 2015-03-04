//
//  ext_uservoice.cpp
//  kod
//
//  Created by DannyHe on 1/4/15.
//
//

#include "ext_uservoice.h"
#import "UserVoice.h"

void OpenUserVoice()
{
    UVConfig *config = [UVConfig configWithSite:@"dannyhe.uservoice.com"];
    config.forumId = 280112;
     [config identifyUserWithEmail:@"email@example.com" name:@"User Name" guid:@"USER_ID"];
    [UserVoice initialize:config];
    // Call this wherever you want to launch UserVoice
    [UserVoice presentUserVoiceForumForParentViewController:[[[UIApplication sharedApplication]keyWindow] rootViewController]];
}