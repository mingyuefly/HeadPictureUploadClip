//
//  MYCropImageViewController.m
//  CustomActionSheet
//
//  Created by Gguomingyue on 2018/1/10.
//  Copyright © 2018年 Gguomingyue. All rights reserved.
//

#import "MYCropImageViewController.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@interface MYCropImageViewController ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, assign) NSInteger limitRatio;

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;
@property (nonatomic, strong) UIView *squareView;

@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) UIButton *conformButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect lastFrame;
@property (nonatomic, assign) CGRect largeFrame;

@end

@implementation MYCropImageViewController

#pragma mark - constructed functions
-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithImage:(UIImage *)image cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio
{
    MYCropImageViewController *civc = [self init];
    if (civc) {
        self.originalImage = image;
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
    }
    return civc;
}

#pragma mark - view life time
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - setters and getters
-(UIImageView *)showImageView
{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc] init];
        _showImageView.frame = CGRectMake(0, 0, 320, 240);
        [_showImageView setMultipleTouchEnabled:YES];
        [_showImageView setUserInteractionEnabled:YES];
        _showImageView.image = self.originalImage;
        
        // scale to fit the screen
        CGFloat oriWidth = self.cropFrame.size.width;
        CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);//与宽度等比例缩放
        CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth)/2;//起始点是0
        CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight)/2;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        self.lastFrame = self.oldFrame;
        _showImageView.frame = self.oldFrame;
        self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    }
    return _showImageView;
}

-(UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] init];
        _overlayView.frame = self.view.bounds;
        _overlayView.alpha = 0.5f;
        _overlayView.backgroundColor = [UIColor blackColor];
        _overlayView.userInteractionEnabled = NO;
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _overlayView;
}

-(UIView *)ratioView
{
    if (!_ratioView) {
        _ratioView = [[UIView alloc] init];
        _ratioView.frame = self.cropFrame;
        _ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
        _ratioView.layer.borderWidth = 1.0f;
        _ratioView.autoresizingMask = UIViewAutoresizingNone;
    }
    return _ratioView;
}

-(UIView *)buttonContainerView
{
    if (!_buttonContainerView) {
        _buttonContainerView = [[UIView alloc] init];
        _buttonContainerView.frame = CGRectMake(0, self.view.frame.size.height - 70.0f, self.view.frame.size.width, 70.0f);
        _buttonContainerView.backgroundColor = [UIColor colorWithRed:40/255.f green:40/255.f blue:40/255.f alpha:0.8];
    }
    return _buttonContainerView;
}

-(UIView *)squareView
{
    if (!_squareView) {
        _squareView = [[UIView alloc] init];
    }
    return _squareView;
}

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 10, 100, 50);
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_cancelButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_cancelButton.titleLabel setNumberOfLines:0];
        [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)conformButton
{
    if (!_conformButton) {
        _conformButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _conformButton.frame = CGRectMake(self.view.frame.size.width - 100.0f, 10, 100, 50);
        _conformButton.backgroundColor = [UIColor clearColor];
        [_conformButton setTitle:@"选取" forState:UIControlStateNormal];
        [_conformButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_conformButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_conformButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_conformButton.titleLabel setNumberOfLines:0];
        [_conformButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_conformButton addTarget:self action:@selector(conformAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _conformButton;
}

#pragma mark - setup View
-(void)setupView
{
    [self initSubView];
    [self initControlButton];
    [self addGestureRecognizer];
}

-(void)initSubView
{
    
}

-(void)initControlButton
{
    [self.view addSubview:self.buttonContainerView];
    [self.buttonContainerView addSubview:self.cancelButton];
    [self.buttonContainerView addSubview:self.conformButton];
}

-(void)addGestureRecognizer
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchViewAction:)];
    [self.view addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panViewAction:)];
    [self.view addGestureRecognizer:pan];
}

#pragma mark - button actions
-(void)cancelAction
{
    NSLog(@"cancelAction");
    self.cancelBlock(self);
}

-(void)conformAction
{
    NSLog(@"conformAction");
    self.submitBlock(self, [self getSubImage]);
}

-(void)pinchViewAction:(UIPinchGestureRecognizer *)sender
{
    //NSLog(@"pinchViewAction");
    UIView *view = self.showImageView;
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale);
        sender.scale = 1;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImageView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImageView.frame = newFrame;
            self.lastFrame = newFrame;
        }];
    }
}

-(void)panViewAction:(UIPanGestureRecognizer *)sender
{
    //NSLog(@"panViewAction");
    UIView *view = self.showImageView;
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height;
        CGFloat scaleRatio = self.showImageView.frame.size.width/self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x)/(scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y)/(scaleRatio * absCenterY);
        CGPoint translation = [sender translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [sender setTranslation:CGPointZero inView:view.superview];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImageView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImageView.frame = newFrame;
            self.lastFrame = newFrame;
        }];
    }
}

#pragma mark - handle image
-(CGRect)handleScaleOverflow:(CGRect)newFrame
{
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        // 如果图片宽度小于crop宽度，弹回
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        // 如果图片宽度大于large宽度，直接放大为最大
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

-(CGRect)handleBorderOverflow:(CGRect)newFrame
{
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) {
        // 图片偏右，将其左侧和crop左侧对齐
        newFrame.origin.x = self.cropFrame.origin.x;
    }
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) {
        // 图片偏左，将其右侧和crop的右侧对齐
        newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    }
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) {
        // 偏下
        newFrame.origin.y = self.cropFrame.origin.y;
    }
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        // 偏上
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImageView.frame.size.width > self.showImageView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        // 如果图片高度小于crop高度，垂直居中
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height)/2;
    }
    return newFrame;
}

-(UIImage *)getSubImage
{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.lastFrame.size.width/self.originalImage.size.width;
    // 以下处理是因为图片的尺寸往往和屏幕控件的尺寸大小比例不同，或压缩或放大，截取的时候不能按控件的显示截取，而要根据比例在图片上截取
    CGFloat x = (squareFrame.origin.x - self.lastFrame.origin.x)/scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.lastFrame.origin.y)/scaleRatio;
    CGFloat w = squareFrame.size.width/scaleRatio;
    CGFloat h = squareFrame.size.height/scaleRatio;
    if (self.lastFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height/self.cropFrame.size.width);
        x = 0; y = y + (h - newH)/2;
        w = newW; h = newH;
    }
    if (self.lastFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width/self.cropFrame.size.height);
        x = x + (w - newW)/2; y = 0;
        w = newW; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return smallImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
