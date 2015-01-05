//
//  ext_sysmail.h
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#ifndef __kod__ext_sysmail__
#define __kod__ext_sysmail__
#include "tolua++.h"
void OnSendMailEnd(int function_id,const char *event);

#define EXT_MODULE_NAME_SYSMAIL "sysmail"
void tolua_ext_module_sysmail(lua_State* tolua_S);
#endif /* defined(__kod__ext_sysmail__) */
