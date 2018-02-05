//
//  ViewController.m
//  HeadPhotoUpload
//
//  Created by Gguomingyue on 2018/1/26.
//  Copyright © 2018年 Gmingyue. All rights reserved.
//

#import "ViewController.h"
#import "MYActionSheetViewController.h"
#import "MYImagePicker.h"

@interface ViewController ()<MYImagePickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)selectAction:(id)sender {
    MYActionSheetViewController *asvc = [MYActionSheetViewController ActionSheetViewController];
    MYSheetAction *cancelAction = [MYSheetAction actionWithTitle:@"取消" hander:nil];
    [asvc addCancelAction:cancelAction];
    MYSheetAction *cameraAction = [MYSheetAction actionWithTitle:@"拍照" hander:^(MYSheetAction *action) {
        NSLog(@"拍照");
        MYImagePicker *imagePicker = [MYImagePicker sharedInstance];
        imagePicker.delegate = self;
        //[imagePicker showOriginalImagePickerWithType:ImagePickerCamera InViewController:self];
        [imagePicker showImagePickerWithType:ImagePickerCamera InViewController:self Scale:0.80];
    }];
    [asvc addAction:cameraAction];
    MYSheetAction *photoAction = [MYSheetAction actionWithTitle:@"从相册中选择" hander:^(MYSheetAction *action) {
        NSLog(@"从相册中选择");
        MYImagePicker *imagePicker = [MYImagePicker sharedInstance];
        imagePicker.delegate = self;
        //[imagePicker showOriginalImagePickerWithType:ImagePickerPhoto InViewController:self];
        [imagePicker showImagePickerWithType:ImagePickerPhoto InViewController:self Scale:0.80];
    }];
    [asvc addAction:photoAction];
    [asvc presentWith:self animated:YES completion:nil];
}

#pragma mark - MYImagePickerDelegate
- (void)imagePickerDidCancel:(MYImagePicker *)imagePicker{
    
}
- (void)imagePicker:(MYImagePicker *)imagePicker didFinished:(UIImage *)editedImage{
    self.imageView.image = editedImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
