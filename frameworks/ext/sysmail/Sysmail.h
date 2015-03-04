//
//  Sysmail.h
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#ifndef kod_Sysmail_h
#define kod_Sysmail_h

bool CanSenMail();
bool SendMail(const char* to,const char* subject,const char* body,int lua_function_ref);
#endif
