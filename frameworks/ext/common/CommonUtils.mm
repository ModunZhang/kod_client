#import <UIKit/UIKit.h>
#include "CommonUtils.h"
#include <sys/utsname.h>
#import "AppController.h"
#import <CoreFoundation/CoreFoundation.h>
#import "UICKeyChainStore.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
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
//log
extern "C" void WriteLog_(const char *str)
{
    NSLog(@"%@",[NSString stringWithUTF8String:str]);
}

extern "C" const char* GetAppVersion()
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]UTF8String];
}
extern "C" const char* GetAppBundleVersion()
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]UTF8String];;
}
extern "C" const char* GetDeviceToken()
{
    AppController * appController = (AppController *)[[UIApplication sharedApplication]delegate];
    return [[appController remoteDeviceToken] UTF8String];
}


extern "C" const char* GetDeviceLanguage()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [currentLanguage UTF8String];
}

extern "C" long long getOSTime()
{
    double currentTime = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    return (long long)(currentTime * 1000);
}
extern "C" float getBatteryLevel()
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];  
    return [[UIDevice currentDevice] batteryLevel];  
}

extern "C" const char* getInternetConnectionStatus()
{
    CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init]autorelease];
    return [networkInfo.currentRadioAccessTechnology UTF8String];
}
static NSString * shared_openUDID = NULL;
extern "C" const char* GetOpenUdid()
{
    if(shared_openUDID!=NULL)
    {
        return [shared_openUDID UTF8String];
    }
    NSError *error = nil;
    NSString *_openUDID = [UICKeyChainStore stringForKey:kKeychainBatcatStudioIdentifier service:kKeychainBatcatStudioKeyChainService error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    if(!_openUDID){
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        unsigned char result[16];
        CC_MD5( cStr, strlen(cStr), result );
        CFRelease(uuid);
        CFRelease(cfstring);
        
        _openUDID = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08x",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     (NSUInteger)(arc4random() % NSUIntegerMax)];

        
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:kKeychainBatcatStudioKeyChainService];
        NSError *error = nil;
        [store setString:_openUDID forKey:kKeychainBatcatStudioIdentifier error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    NSLog(@"GetOpenUdid:%@",_openUDID);
    shared_openUDID = [[NSString alloc]initWithString:_openUDID];
    return [shared_openUDID UTF8String];
}

extern "C" void registereForRemoteNotifications()
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }

}

extern "C" void ClearOpenUdidData()
{
#ifdef DEBUG
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:kKeychainBatcatStudioKeyChainService];
    [store removeItemForKey:kKeychainBatcatStudioIdentifier];
#endif

}