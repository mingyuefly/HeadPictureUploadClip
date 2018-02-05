//
//  UIColor+Extension.h
//  IosGit
//
//  Created by Yi Gou on 16/3/4.
//  Copyright © 2016年 chenhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)
/**
 *  RGB转换为色值
 */
+ (UIColor *)colorWithRGBString:(NSString *)color;
/**
 *  RGB转换为色值 颜色的透明度
 */
+ (UIColor *)colorWithRGBString:(NSString *)color Alpha:(CGFloat)alpha;

/**
 *  根据颜色返回一张图片
 */
+ (UIImage *)ew_singleDotImageWithColor:(UIColor *)color;
@end
