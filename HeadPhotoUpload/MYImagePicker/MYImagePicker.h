//
//  MYImagePicker.h
//  CustomActionSheet
//
//  Created by Gguomingyue on 2018/1/10.
//  Copyright © 2018年 Gguomingyue. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ImagePickerType){
    ImagePickerCamera = 0,
    ImagePickerPhoto = 1
};

@class MYImagePicker;
@protocol MYImagePickerDelegate<NSObject>
@optional
- (void)imagePicker:(MYImagePicker *)imagePicker didFinished:(UIImage *)editedImage;
- (void)imagePickerDidCancel:(MYImagePicker *)imagePicker;

@end

@interface MYImagePicker : NSObject

@property (nonatomic, weak) id<MYImagePickerDelegate>delegate;

+(instancetype)sharedInstance;

- (void)showOriginalImagePickerWithType:(ImagePickerType)type InViewController:(UIViewController *)viewController;
- (void)showImagePickerWithType:(ImagePickerType)type InViewController:(UIViewController *)viewController Scale:(double)scale;


@end
