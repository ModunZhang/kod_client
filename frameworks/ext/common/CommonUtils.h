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
#endif