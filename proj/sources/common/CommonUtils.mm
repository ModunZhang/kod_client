#import <UIKit/UIKit.h>
#include "CommonUtils.h"
#include <sys/utsname.h>

extern "C" void CopyText(const char * text)
{
    [UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text];
}


extern "C" void DisableIdleTimer(bool disable)
{
    [UIApplication sharedApplication].idleTimerDisabled = disable;
}

extern "C" void CloseKeyboard()
{
    if ([[[[UIApplication sharedApplication]keyWindow]rootViewController].view respondsToSelector:@selector(handleTouchesAfterKeyboardShow)])
    {
        [[[[UIApplication sharedApplication]keyWindow]rootViewController].view
            performSelector:@selector(handleTouchesAfterKeyboardShow)
                 withObject:nil];
    }
}

extern "C" const char*GetOSVersion()
{
    return [[NSString stringWithFormat:@"iOS %@",[UIDevice currentDevice].systemVersion] UTF8String];
}
/***
 　  iphone 5,1 　　iphone5(移动,联通)
 　　iphone 5,2	　　iphone5(移动,电信,联通)
 　　iphone 4,1	　   iphone4S
 　　iphone 3,1	　   iphone4(移动,联通)
 　　iphone 3,2  　  iphone4(联通)
 　　iphone 3,3	　   iphone4(电信)
 　　iphone 2,1       iphone3GS
 　　iphone 1,2	　   iphone3G
 　　iphone 1,1	　   iphone
 　　ipad 1,1	　　　 ipad 1
 　　ipad 2,1	　　　 ipad 2(Wifi)
 　　ipad 2,2	　　　 ipad 2(GSM)
 　　ipad 2,3	　　　 ipad 2(CDMA)
 　　ipad 2,4	　　　 ipad 2(32nm)
 　　ipad 2,5	　　　 ipad mini(Wifi)
 　　ipad 2,6	　　　 ipad mini(GSM)
 　　ipad 2,7	　　　 ipad mini(CDMA)
 　　ipad 3,1	　　　 ipad 3(Wifi)
 　　ipad 3,2	　　　 ipad 3(CDMA)
 　　ipad 3,3	　　　 ipad 3(4G)
 　　ipad 3,4　　　  ipad 4(Wifi)
 　　ipad 3,5　　　  ipad 4(4G)
 　　ipad 3,6　　　  ipad 4(CDMA)
 　　ipod 5,1　　　  ipod touch 5
 　　ipod 4,1　　　  ipod touch 4
 　　ipod 3,1	　　　 ipod touch 3
 　　ipod 2,1	　　　 ipod touch 2
 　　ipod 1,1	　　　 ipod touch
 ***/
extern "C" const char* GetDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [[NSString stringWithCString:systemInfo.machine
                               encoding:NSUTF8StringEncoding]UTF8String];
}

static NSFileHandle *outFile = NULL;
static NSString *logFilePath = NULL;
static dispatch_queue_t aDQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
extern "C" void WriteLog_(const char *str)
{
    if (logFilePath == NULL)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM_dd-HH_mm"];
        logFilePath = [[NSString stringWithFormat:@"%@/Documents/%@.log",NSHomeDirectory(),[dateFormatter stringFromDate:[NSDate date]]]retain];
    }
    if(outFile == NULL)
    {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil] ;
        outFile = [[NSFileHandle fileHandleForWritingAtPath:logFilePath]retain];
    }
    dispatch_async(aDQueue, ^{
        NSData * data = [[NSString stringWithCString:str  encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        [outFile writeData:data];
        //outFile close
    });
}