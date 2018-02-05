//
//  MYLayoutRate.c
//  
//
//  Created by Gguomingyue on 16/7/13.
//  Copyright © 2016年 Gguomingyue. All rights reserved.
//

#include "MYLayoutRate.h"
#import "MYActionSheetDefines.h"

float layoutRateByHeight(float orginLayout){
    
    if (DEVICE_HEIGHT > 667) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 568) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 480) {
        return 0.85 * orginLayout;
    }
    return 0.85 * orginLayout;
}

float layoutRateByHeightForPlus(float orginLayout){
    
    if (DEVICE_HEIGHT > 667) {
        return (736 * orginLayout)/664;
    } else if (DEVICE_HEIGHT > 568) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 480) {
        return 0.85 * orginLayout;
    }
    return 0.85 * orginLayout;
}


@implementation MYLayoutRate : NSObject

+ (CGFloat)layoutRateByOCHeight:(CGFloat)orginLayout
{
    if (DEVICE_HEIGHT > 667) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 568) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 480) {
        return 0.85 * orginLayout;
    }
    return 0.85 * orginLayout;
}

+ (CGFloat)layoutRateByOCHeightForPlus:(CGFloat)orginLayout
{
    if (DEVICE_HEIGHT > 667) {
        return (736 * orginLayout)/664;
    } else if (DEVICE_HEIGHT > 568) {
        return 1 * orginLayout;
    } else if (DEVICE_HEIGHT > 480) {
        return 0.85 * orginLayout;
    }
    return 0.85 * orginLayout;
}

@end
