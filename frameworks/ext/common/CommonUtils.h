#ifndef __kod_commonutils__
#define __kod_commonutils__
#define kKeychainBatcatStudioIdentifier          @"kKeychainBatcatStudioIdentifier"
#define kKeychainBatcatStudioKeyChainService             @"com.batcatstudio.keychain"
//copy text to Pasteboard
extern "C" void CopyText(const char * text);
extern "C" void DisableIdleTimer(bool disable=false);
extern "C" void CloseKeyboard();
extern "C" const char* GetOSVersion();
extern "C" const char* GetDeviceModel();
extern "C" void WriteLog_(const char *str);
extern "C" const char* GetAppVersion();
extern "C" const char* GetAppBundleVersion();
extern "C" const char* GetDeviceToken();
extern "C" long long getOSTime();
extern "C" const char* GetOpenUdid();
extern "C" void registereForRemoteNotifications();
extern "C" void ClearOpenUdidData(); // 注意！这个方法绝对不能在发布环境里调用
extern "C" const char* GetDeviceLanguage();
extern "C" float getBatteryLevel();
extern "C" const char* getInternetConnectionStatus();
#endif