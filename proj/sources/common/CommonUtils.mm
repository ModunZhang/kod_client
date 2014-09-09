#import <UIKit/UIKit.h>
#include "CommonUtils.h"

extern "C" void CopyText(const char * text)
{
    [UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text];
}


extern "C" void DisableIdleTimer(bool disable)
{
    [UIApplication sharedApplication].idleTimerDisabled = disable;
}