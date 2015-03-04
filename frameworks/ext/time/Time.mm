//
//  Time.mm
//  battlefront
//
//  Created by Modun on 14-4-25.
//
//

#include "Time.h"
#import <CoreFoundation/CoreFoundation.h>

double Time::getTime(){
    double currentTime = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    return (long long)(currentTime * 1000);
}