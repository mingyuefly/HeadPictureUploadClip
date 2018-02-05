//
//  MYCropImageViewController.h
//  CustomActionSheet
//
//  Created by Gguomingyue on 2018/1/10.
//  Copyright © 2018年 Gguomingyue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SubmitBlock)(UIViewController *viewController, UIImage *image);
typedef void(^CancelBlock)(UIViewController *viewController);

@interface MYCropImageViewController : UIViewController

@property (nonatomic, copy) SubmitBlock submitBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;

-(instancetype)initWithImage:(UIImage *)image cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
