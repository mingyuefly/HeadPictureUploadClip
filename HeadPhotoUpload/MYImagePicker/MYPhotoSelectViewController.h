//
//  MYPhotoSelectViewController.h
//  HeadPhotoUpload
//
//  Created by Gguomingyue on 2018/1/26.
//  Copyright © 2018年 Gmingyue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SubmitBlock)(UIViewController *viewController, UIImage *image);
typedef void(^CancelBlock)(UIViewController *viewController);

@interface MYPhotoSelectViewController : UIViewController

@property (nonatomic, copy) SubmitBlock submitBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;

-(instancetype)initWithImage:(UIImage *)image;

@end
