#ifndef __kod_commonutils__
#define __kod_commonutils__

//copy text to Pasteboard
extern "C" void CopyText(const char * text);
extern "C" void DisableIdleTimer(bool disable=false);
extern "C" void CloseKeyboard();
extern "C" const char* GetOSVersion();
extern "C" const char* GetDeviceModel();
extern "C" void WriteLog_(const char *str);
#endif