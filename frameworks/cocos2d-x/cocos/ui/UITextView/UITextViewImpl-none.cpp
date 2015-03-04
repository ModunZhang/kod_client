//
//  UITextViewImpl-none.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#include "UITextViewImpl.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)

//为其他平台提供空函数 TODO:Android
UITextViewImpl* __createSystemTextView(UITextView* pTextView)
{
    return NULL;
}

#endif/* #if (..) */