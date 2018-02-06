//
//  MYPhotoSelectViewController.m
//  HeadPhotoUpload
//
//  Created by Gguomingyue on 2018/1/26.
//  Copyright © 2018年 Gmingyue. All rights reserved.
//

#import "MYPhotoSelectViewController.h"
#import <math.h>

typedef NS_ENUM(NSInteger, SelectTouchType){
    Default         = 0,   // 中间区域
    LeftUpSquare    = 1,   // 左上角区域
    RightUpSquare   = 2,   // 右上角区域
    LeftDownSquare  = 3,   // 左下角区域
    RightDownSquare = 4,   // 右下角区域
    LeftLine        = 5,   // 左边线区域
    RightLine       = 6,   // 右边线区域
    UpLine          = 7,   // 上边线区域
    DownLine        = 8,   // 下边线区域
    OutSquare       = 9    // 外边区域
};

typedef NS_ENUM(NSInteger, RotateType)
{
    OneQuater     = 0,    //原位置
    TwoQuater     = 1,    //1/4
    ThreeQuater   = 2,    //2/4
    DefaultRotate = 3,    //3/4
};

#define pointRotatedAroundAnchorPoint(point,anchorPoint,angle) CGPointMake((point.x-anchorPoint.x)*cos(angle) - (point.y-anchorPoint.y)*sin(angle) + anchorPoint.x, (point.x-anchorPoint.x)*sin(angle) + (point.y-anchorPoint.y)*cos(angle)+anchorPoint.y)

static CGFloat smallLength = 80.0f;
static CGFloat selectRegionLength = 30.0f;

@interface MYPhotoSelectViewController ()

@property (nonatomic, strong) UIView *backgroundView;//选择框背景
@property (nonatomic, strong) UIView *squareView;//选择框
@property (nonatomic, strong) UIImageView *imageView;//被编辑图片
@property (nonatomic, strong) UIImage *oldImage;//保存传进来的原图
@property (nonatomic, strong) UIImage *originalImage;//传入进来的原图
//@property (nonatomic, strong) UIImage *rotateImage; // 旋转后的图片
@property (nonatomic, strong) UIImageView *clipImageView;//裁剪结果图片
@property (nonatomic, strong) UIImage *clipImage;//裁剪结果图片
//@property (nonatomic, strong) UIImage *rotateClipImage;//旋转裁剪图片
@property (nonatomic, assign) CGRect cropFrame;//最终裁剪框frame
@property (nonatomic, assign) CGRect oldFrame;//初始化imageView的frame
@property (nonatomic, assign) CGRect oriFrame;//初次update后的imageView的frame
@property (nonatomic, assign) CGRect lastFrame;//每次操作后imageView的frame
@property (nonatomic, assign) CGRect largeFrame;//限制最大imageView的frame
@property (nonatomic, assign) NSInteger limitRatio;//限制最大比例
@property (nonatomic, assign) BOOL bigHeight;//图片高大于宽

@property (nonatomic, assign) SelectTouchType selectTouchType;
@property (nonatomic, assign) CGMutablePathRef path1;//right line
@property (nonatomic, assign) CGMutablePathRef path2;//down line
@property (nonatomic, assign) CGMutablePathRef path3;//left line
@property (nonatomic, assign) CGMutablePathRef path4;//up line
@property (nonatomic, assign) CGMutablePathRef path5;//right up square
@property (nonatomic, assign) CGMutablePathRef path6;//right down square
@property (nonatomic, assign) CGMutablePathRef path7;//left down square
@property (nonatomic, assign) CGMutablePathRef path8;//left up square
@property (nonatomic, assign) CGMutablePathRef path0;//inside
@property (nonatomic, assign) CGMutablePathRef path10;//outside
@property (nonatomic, assign) CGPoint beginPoint;//拖动时初始点

@property (nonatomic, strong) UIView *buttonContainerView;// buttons容器
@property (nonatomic, strong) UIButton *conformButton;//选取
@property (nonatomic, strong) UIButton *cancelButton;//撤销
@property (nonatomic, strong) UIButton *restoreButton;//还原

@property (nonatomic, strong) UIButton *rotateButton;//旋转
@property (nonatomic, assign) RotateType rotateType;//旋转状态

@end

@implementation MYPhotoSelectViewController

#pragma mark - constructed functions
-(instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.originalImage = image;
        self.oldImage = image;
        self.limitRatio = 10.0f;
    }
    return self;
}

#pragma mark - getters and setters
-(UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.frame = self.cropFrame;
        _backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        _backgroundView.layer.borderWidth = 1.0f;
    }
    return _backgroundView;
}

-(UIView *)squareView
{
    if (!_squareView) {
        _squareView = [[UIView alloc] init];
        if (self.bigHeight) {
            _squareView.frame = self.oldFrame;
        } else {
            _squareView.frame = CGRectMake(self.cropFrame.origin.x, self.oldFrame.origin.y, self.cropFrame.size.width, self.oldFrame.size.height);
        }
        _squareView.layer.borderColor = [UIColor yellowColor].CGColor;
        _squareView.layer.borderWidth = 1.0f;
    }
    return _squareView;
}

-(CGRect)cropFrame
{
    return CGRectMake(30, self.view.center.y - ([UIScreen mainScreen].bounds.size.width - 2 * 30)/2 - 60, [UIScreen mainScreen].bounds.size.width - 2 * 30, [UIScreen mainScreen].bounds.size.width - 2 * 30);
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, 0, 320, 240);
        [_imageView setMultipleTouchEnabled:YES];
        [_imageView setUserInteractionEnabled:YES];
        _imageView.image = self.originalImage;
        
        // scale to fit the screen
        CGRect screenFrame = self.view.frame;
        CGFloat screenWidth = screenFrame.size.width;
        if (self.originalImage.size.height > self.originalImage.size.width) {
            self.bigHeight = YES;
        } else {
            self.bigHeight = NO;
        }
        if (self.bigHeight) {
            CGFloat oriWidth = self.cropFrame.size.width;
            CGFloat oriHeight = self.originalImage.size.height * (oriWidth/self.originalImage.size.width);
            CGFloat oriX = self.cropFrame.origin.x;
            CGFloat oriY = self.cropFrame.origin.y + self.cropFrame.size.height/2 - oriHeight/2;
            self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
            self.lastFrame = self.oldFrame;
            _imageView.frame = self.oldFrame;
            self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
        } else {
            CGFloat oriWidth = screenWidth;
            CGFloat oriHeight = self.originalImage.size.height * (oriWidth/self.originalImage.size.width);
            CGFloat oriX = 0;
            CGFloat oriY = self.cropFrame.origin.y + self.cropFrame.size.height/2 - oriHeight/2;
            self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
            self.lastFrame = self.oldFrame;
            _imageView.frame = self.oldFrame;
            self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
        }
    }
    return _imageView;
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

-(UIButton *)restoreButton
{
    if (!_restoreButton) {
        _restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _restoreButton.frame = CGRectMake(self.view.frame.size.width/2 - 50.0f, 10, 100, 50);
        _restoreButton.backgroundColor = [UIColor clearColor];
        [_restoreButton setTitle:@"还原" forState:UIControlStateNormal];
        [_restoreButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_restoreButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_restoreButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_restoreButton.titleLabel setNumberOfLines:0];
        [_restoreButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_restoreButton addTarget:self action:@selector(restoreAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _restoreButton;
}

-(UIButton *)rotateButton
{
    if (!_rotateButton) {
        _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotateButton.frame = CGRectMake(0, self.view.frame.size.height - 130.0f, 100, 50);
        _rotateButton.backgroundColor = [UIColor clearColor];
        [_rotateButton setTitle:@"旋转" forState:UIControlStateNormal];
        [_rotateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_rotateButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_rotateButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_rotateButton.titleLabel setNumberOfLines:0];
        [_rotateButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_rotateButton addTarget:self action:@selector(rotateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateButton;
}

-(UIImageView *)clipImageView
{
    if (!_clipImageView) {
        _clipImageView = [[UIImageView alloc] initWithFrame:self.cropFrame];
    }
    return _clipImageView;
}

// special region 0 center
-(CGMutablePathRef)path0
{
    CGMutablePathRef path0 = CGPathCreateMutable();
    CGPathMoveToPoint(path0, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path0, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path0, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path0, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path0, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathCloseSubpath(path0);
    return path0;
}

// special region 1 right
-(CGMutablePathRef)path1
{
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path1, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path1, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path1, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path1, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path1);
    return path1;
}

// special region 2 down
-(CGMutablePathRef)path2
{
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path2, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path2, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path2, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path2, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path2);
    return path2;
}

// special region 3 left
-(CGMutablePathRef)path3
{
    CGMutablePathRef path3 = CGPathCreateMutable();
    CGPathMoveToPoint(path3, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path3, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path3, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path3, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path3, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathCloseSubpath(path3);
    return path3;
}

// special region 4 up
-(CGMutablePathRef)path4
{
    CGMutablePathRef path4 = CGPathCreateMutable();
    CGPathMoveToPoint(path4, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path4, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path4, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path4, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path4, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path4);
    return path4;
}

//special region 5 right up
-(CGMutablePathRef)path5
{
    CGMutablePathRef path5 = CGPathCreateMutable();
    CGPathMoveToPoint(path5, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path5, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path5, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path5, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path5, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path5);
    return path5;
}

//special region 6 right down
-(CGMutablePathRef)path6
{
    CGMutablePathRef path6 = CGPathCreateMutable();
    CGPathMoveToPoint(path6, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path6, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path6, nil, CGRectGetMaxX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path6, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path6, nil, CGRectGetMaxX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path6);
    return path6;
}

//special region 7 left down
-(CGMutablePathRef)path7
{
    CGMutablePathRef path7 = CGPathCreateMutable();
    CGPathMoveToPoint(path7, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path7, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path7, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path7, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path7, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMaxY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path7);
    return path7;
}

//special region 8 left up
-(CGMutablePathRef)path8
{
    CGMutablePathRef path8 = CGPathCreateMutable();
    CGPathMoveToPoint(path8, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path8, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathAddLineToPoint(path8, nil, CGRectGetMinX(self.squareView.frame) + selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path8, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) + selectRegionLength);
    CGPathAddLineToPoint(path8, nil, CGRectGetMinX(self.squareView.frame) - selectRegionLength, CGRectGetMinY(self.squareView.frame) - selectRegionLength);
    CGPathCloseSubpath(path8);
    return path8;
}

#pragma mark - root view life time
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.rotateType = DefaultRotate;
    
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.squareView];
    
    // update subView
    [self updateSubView];
}

-(void)updateSubView
{
    CGRect newRect = CGRectZero;
    if (self.bigHeight) {
        newRect = self.lastFrame;
    } else {
        CGFloat newHeight = self.cropFrame.size.height;
        CGFloat newWidth = self.lastFrame.size.width * (newHeight/self.lastFrame.size.height);
        newRect = CGRectMake(self.view.frame.size.width/2 - newWidth/2, self.cropFrame.origin.y, newWidth, newHeight);
    }
    self.oriFrame = newRect;
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.frame = newRect;
        self.squareView.frame = self.cropFrame;
        self.lastFrame = newRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.alpha = 0.2;
        }];
    }];
    
    // 点亮要裁剪的图片
    [self illumeClipPicture];
}

-(void)illumeClipPicture
{
    [self.view addSubview:self.clipImageView];
    self.clipImage = [self getSubImage];
    self.clipImageView.image = self.clipImage;
    [self.view bringSubviewToFront:self.squareView];
}

-(void)clearClipPicture
{
    [self.clipImageView removeFromSuperview];
    //self.clipImage = nil;
    self.imageView.alpha = 1.0f;
}

-(void)initControlButton
{
    [self.view addSubview:self.buttonContainerView];
    [self.buttonContainerView addSubview:self.cancelButton];
    [self.buttonContainerView addSubview:self.conformButton];
    [self.buttonContainerView addSubview:self.restoreButton];
    [self.view addSubview:self.rotateButton];
}

-(void)addGestureRecognizer
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchViewAction:)];
    [self.view addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panViewAction:)];
    [self.view addGestureRecognizer:pan];
}

#pragma mark - move touch begin
-(void)moveTouchBegin:(CGPoint)point
{
    if (CGPathContainsPoint(self.path1, nil, point, NO)) {
        NSLog(@"point in path1");
        self.selectTouchType = RightLine;
    } else if (CGPathContainsPoint(self.path2, nil, point, NO)) {
        NSLog(@"point in path2");
        self.selectTouchType = DownLine;
    } else if (CGPathContainsPoint(self.path3, nil, point, NO)) {
        NSLog(@"point in path3");
        self.selectTouchType = LeftLine;
    } else if (CGPathContainsPoint(self.path4, nil, point, NO)) {
        NSLog(@"point in path4");
        self.selectTouchType = UpLine;
    } else if (CGPathContainsPoint(self.path5, nil, point, NO)) {
        NSLog(@"point in path5");
        self.selectTouchType = RightUpSquare;
    } else if (CGPathContainsPoint(self.path6, nil, point, NO)) {
        NSLog(@"point in path6");
        self.selectTouchType = RightDownSquare;
    } else if (CGPathContainsPoint(self.path7, nil, point, NO)) {
        NSLog(@"point in path7");
        self.selectTouchType = LeftDownSquare;
    } else if (CGPathContainsPoint(self.path8, nil, point, NO)) {
        NSLog(@"point in path8");
        self.selectTouchType = LeftUpSquare;
    } else if (CGPathContainsPoint(self.path0, nil, point, NO)) {
        NSLog(@"point in path0");
        self.selectTouchType = Default;
        self.beginPoint = point;
    } else {
        NSLog(@"point is outside");
        self.selectTouchType = OutSquare;
    }
}

#pragma mark - move touch end
-(void)moveTouchEnd
{
    if (self.selectTouchType == OutSquare) {
        return;
    }
    if (self.selectTouchType == Default) {
        self.beginPoint = CGPointZero;
        CGRect frame = [self handleBorderOverflow:self.imageView.frame];
        [UIView animateWithDuration:0.5 animations:^{
            self.squareView.frame = self.cropFrame;
            self.imageView.frame = frame;
            self.lastFrame = frame;
        } completion:^(BOOL finished) {
            self.imageView.alpha = 0.2;
            // 点亮要裁剪的图片
            [self illumeClipPicture];
        }];
    } else {
        // 图像与选择框等比例缩放并位移
        CGFloat scaleRatio = self.squareView.frame.size.width/self.cropFrame.size.width;
        CGFloat newWidth = self.imageView.frame.size.width/scaleRatio;
        CGFloat newHeight = self.imageView.frame.size.height/scaleRatio;
        // 最终选择框中心点
        CGPoint oldCenter = CGPointMake(self.squareView.frame.origin.x + self.squareView.frame.size.width/2, self.squareView.frame.origin.y + self.squareView.frame.size.height/2);
        // cropFrame 中心点
        CGPoint cropCenter = CGPointMake(self.cropFrame.origin.x + self.cropFrame.size.width/2, self.cropFrame.origin.y + self.cropFrame.size.height/2);
        // 移动距离
        CGFloat distanceX = cropCenter.x - oldCenter.x;
        CGFloat distanceY = cropCenter.y - oldCenter.y;
        CGRect imageViewFrame = self.imageView.frame;
        CGFloat middleX = imageViewFrame.origin.x + distanceX;
        CGFloat middleY = imageViewFrame.origin.y + distanceY;
        //CGRect middleFrame = CGRectMake(middleX, middleY, imageViewFrame.size.width, imageViewFrame.size.height);
        // 等比例放大
        CGFloat middleDistanceXAndDatumX = self.cropFrame.origin.x + self.cropFrame.size.width/2 - middleX;
        CGFloat middleDistanceYAndDatumY = self.cropFrame.origin.y + self.cropFrame.size.height/2 - middleY;
        CGFloat newX = self.cropFrame.origin.x + self.cropFrame.size.width/2 - middleDistanceXAndDatumX/scaleRatio;
        CGFloat newY = self.cropFrame.origin.y + self.cropFrame.size.height/2 - middleDistanceYAndDatumY/scaleRatio;
        CGRect newFrame = CGRectMake(newX, newY, newWidth, newHeight);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.squareView.frame = self.cropFrame;
                self.imageView.frame = newFrame;
                self.lastFrame = newFrame;
            } completion:^(BOOL finished) {
                self.imageView.alpha = 0.2;
                // 点亮要裁剪的图片
                [self illumeClipPicture];
            }];
        });
    }
}

#pragma mark - move touch
-(void)moveTouch:(CGPoint)point
{
    if (self.selectTouchType == OutSquare) {
        return;
    }
    [self clearClipPicture];
    switch (self.selectTouchType) {
        case RightLine:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            if (point.x > backgroundFrame.origin.x + backgroundFrame.size.width) {
                self.squareView.frame = backgroundFrame;
            } else if (point.x < backgroundFrame.origin.x + smallLength) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + smallLength/2, backgroundFrame.origin.y + backgroundFrame.size.height/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else {
                CGFloat newWidth = point.x - backgroundFrame.origin.x;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + newWidth/2, self.backgroundView.center.y);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case DownLine:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            if (point.y > backgroundFrame.origin.y + backgroundFrame.size.height) {
                self.squareView.frame = backgroundFrame;
            } else if (point.y < backgroundFrame.origin.y + smallLength) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width/2, backgroundFrame.origin.y + smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else {
                CGFloat newHeight = point.y - backgroundFrame.origin.y;
                CGPoint newCenter = CGPointMake(self.backgroundView.center.x, backgroundFrame.origin.y + newHeight/2);
                CGRect newFrame = CGRectMake(0, 0, newHeight, newHeight);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case LeftLine:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            if (point.x < backgroundFrame.origin.x) {
                self.squareView.frame = backgroundFrame;
            } else if (point.x > backgroundFrame.origin.x + backgroundFrame.size.width - smallLength) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - smallLength/2, backgroundFrame.origin.y + backgroundFrame.size.height/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else {
                CGFloat newWidth = backgroundFrame.origin.x + backgroundFrame.size.width - point.x;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - newWidth/2, self.backgroundView.center.y);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case UpLine:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            if (point.y < backgroundFrame.origin.y) {
                self.squareView.frame = backgroundFrame;
            } else if (point.y > backgroundFrame.origin.y + backgroundFrame.size.height - smallLength) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width/2, backgroundFrame.origin.y + backgroundFrame.size.height - smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else {
                CGFloat newHeight = backgroundFrame.origin.y + backgroundFrame.size.height - point.y;
                CGPoint newCenter = CGPointMake(self.backgroundView.center.x, backgroundFrame.origin.y + backgroundFrame.size.height - newHeight/2);
                CGRect newFrame = CGRectMake(0, 0, newHeight, newHeight);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case RightUpSquare:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            CGPoint leftDownPoint = CGPointMake(backgroundFrame.origin.x, backgroundFrame.origin.y + backgroundFrame.size.height);
            CGFloat backgroundDiagonal = sqrt(backgroundFrame.size.height * backgroundFrame.size.width + backgroundFrame.size.height * backgroundFrame.size.height);
            CGFloat diagonal = sqrt((point.x - leftDownPoint.x) * (point.x - leftDownPoint.x) + (point.y - leftDownPoint.y) * (point.y - leftDownPoint.y));
            if (diagonal < sqrt(smallLength*smallLength*2)) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + smallLength/2, backgroundFrame.origin.y + backgroundFrame.size.height - smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else if (diagonal > backgroundDiagonal) {
                self.squareView.frame = backgroundFrame;
            } else {
                CGFloat newWidth = sin(M_PI_4) * diagonal;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + newWidth/2, backgroundFrame.origin.y + backgroundFrame.size.height - newWidth/2);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case RightDownSquare:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            CGFloat backgroundDiagonal = sqrt(backgroundFrame.size.height * backgroundFrame.size.width + backgroundFrame.size.height * backgroundFrame.size.height);
            CGPoint leftUpPoint = CGPointMake(backgroundFrame.origin.x, backgroundFrame.origin.y);
            CGFloat diagonal = sqrt((point.x - leftUpPoint.x) * (point.x - leftUpPoint.x) + (point.y - leftUpPoint.y) * (point.y - leftUpPoint.y));
            if (diagonal < sqrt(smallLength*smallLength*2)) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + smallLength/2, backgroundFrame.origin.y + smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else if (diagonal > backgroundDiagonal) {
                self.squareView.frame = backgroundFrame;
            } else {
                CGFloat newWidth = sin(M_PI_4) * diagonal;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + newWidth/2, backgroundFrame.origin.y + newWidth/2);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case LeftDownSquare:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            CGFloat backgroundDiagonal = sqrt(backgroundFrame.size.height * backgroundFrame.size.width + backgroundFrame.size.height * backgroundFrame.size.height);
            CGPoint RightUpPoint = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width, backgroundFrame.origin.y);
            CGFloat diagonal = sqrt((point.x - RightUpPoint.x) * (point.x - RightUpPoint.x) + (point.y - RightUpPoint.y) * (point.y - RightUpPoint.y));
            if (diagonal < sqrt(smallLength*smallLength*2)) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - smallLength/2, backgroundFrame.origin.y + smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else if (diagonal > backgroundDiagonal) {
                self.squareView.frame = backgroundFrame;
            } else {
                CGFloat newWidth = sin(M_PI_4) * diagonal;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - newWidth/2, backgroundFrame.origin.y + newWidth/2);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case LeftUpSquare:
        {
            CGRect backgroundFrame = self.backgroundView.frame;
            CGFloat backgroundDiagonal = sqrt(backgroundFrame.size.height * backgroundFrame.size.width + backgroundFrame.size.height * backgroundFrame.size.height);
            CGPoint rightDownPoint = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width, backgroundFrame.origin.y + backgroundFrame.size.height);
            CGFloat diagonal = sqrt((point.x - rightDownPoint.x) * (point.x - rightDownPoint.x) + (point.y - rightDownPoint.y) * (point.y - rightDownPoint.y));
            if (diagonal < sqrt(smallLength*smallLength*2)) {
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - smallLength/2, backgroundFrame.origin.y + backgroundFrame.size.height - smallLength/2);
                CGRect newFrame = CGRectMake(0, 0, smallLength, smallLength);
                self.squareView.frame = newFrame;
                self.squareView.center = newCenter;
            } else if (diagonal > backgroundDiagonal) {
                self.squareView.frame = backgroundFrame;
            } else {
                CGFloat newWidth = sin(M_PI_4) * diagonal;
                CGPoint newCenter = CGPointMake(backgroundFrame.origin.x + backgroundFrame.size.width - newWidth/2, backgroundFrame.origin.y + backgroundFrame.size.height - newWidth/2);
                CGRect newFrame = CGRectMake(0, 0, newWidth, newWidth);
                [UIView animateWithDuration:0.1 animations:^{
                    self.squareView.frame = newFrame;
                    self.squareView.center = newCenter;
                }];
            }
        }
            break;
        case Default:
        {
            CGRect frame = self.imageView.frame;
            frame.origin.x += (point.x - self.beginPoint.x);
            frame.origin.y += (point.y - self.beginPoint.y);
            self.imageView.frame = frame;
            self.beginPoint = point;
        }
        default:
            break;
    }
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
    self.submitBlock(self, self.clipImage);
}

-(void)restoreAction
{
    NSLog(@"restoreAction");
    [self clearClipPicture];
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.rotateType = DefaultRotate;
        self.imageView.frame = self.oriFrame;
        self.lastFrame = self.oriFrame;
        self.squareView.frame = self.cropFrame;
        self.imageView.image = self.oldImage;
        self.originalImage = self.oldImage;
        //self.imageView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.alpha = 0.2;
        }];
        [self illumeClipPicture];
    }];
}

#pragma mark - rotate operation
-(void)rotateAction
{
    NSLog(@"rotateAction");
    [self clearClipPicture];
    self.imageView.alpha = 0.2;
    if (!self.originalImage) {
        self.originalImage = self.oldImage;
    }
    [self rotateImageAction];
}

-(void)rotateImageAction
{
    CGRect bnds = CGRectZero;
    UIImage *image = self.originalImage;
    CGContextRef context = nil;
    CGImageRef imageRef = image.CGImage;
    CGRect rect = CGRectZero;
    rect.size.width = CGImageGetWidth(imageRef);
    rect.size.height = CGImageGetHeight(imageRef);
    bnds = rect;
    bnds = swapWidthAndHeight(bnds);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(rect.size.height, 0);
    transform = CGAffineTransformRotate(transform, M_PI_2);
    
    UIGraphicsBeginImageContext(bnds.size);
    context = UIGraphicsGetCurrentContext();
    
    
    CGContextScaleCTM(context, -1.0f, 1.0f);
    CGContextTranslateCTM(context, -rect.size.height, 0.0f);
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imageRef);
    self.originalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPoint roundPoint = self.squareView.center;
    CGAffineTransform transfrom = CGAffineTransformIdentity;
    switch (self.rotateType) {
        case DefaultRotate:
        {
            transfrom = GetCGAffineTransformRotateAroundPoint(self.imageView.center.x, self.imageView.center.y, roundPoint.x, roundPoint.y, M_PI_2);
            self.rotateType = OneQuater;
        }
            break;
        case OneQuater:
        {
            transfrom = GetCGAffineTransformRotateAroundPoint(self.imageView.center.x, self.imageView.center.y, roundPoint.x, roundPoint.y, M_PI);
            self.rotateType = TwoQuater;
        }
            break;
        case TwoQuater:
        {
            transfrom = GetCGAffineTransformRotateAroundPoint(self.imageView.center.x, self.imageView.center.y, roundPoint.x, roundPoint.y, 3 * M_PI/2);
            self.rotateType = ThreeQuater;
        }
            break;
        case ThreeQuater:
        {
            transfrom = CGAffineTransformIdentity;
            self.rotateType = DefaultRotate;
        }
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.transform = transfrom;
        self.lastFrame = self.imageView.frame;
        self.squareView.frame = self.cropFrame;
        //self.imageView.image = self.originalImage;
    } completion:^(BOOL finished) {
        self.imageView.alpha = 0.2;
        // 点亮要裁剪的图片
        [self rotateClipImageAction];
    }];
}

-(void)rotateClipImageAction
{
    CGRect bnds = CGRectZero;
    UIImage *image = self.clipImage;
    CGContextRef context = nil;
    CGImageRef imageRef = image.CGImage;
    CGRect rect = CGRectZero;
    rect.size.width = CGImageGetWidth(imageRef);
    rect.size.height = CGImageGetHeight(imageRef);
    bnds = rect;
    bnds = swapWidthAndHeight(bnds);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(rect.size.height, 0);
    transform = CGAffineTransformRotate(transform, M_PI_2);
    
    UIGraphicsBeginImageContext(bnds.size);
    context = UIGraphicsGetCurrentContext();
    
    
    CGContextScaleCTM(context, -1.0f, 1.0f);
    CGContextTranslateCTM(context, -rect.size.height, 0.0f);
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imageRef);
    self.clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.clipImageView.image = self.clipImage;
    [self.view addSubview:self.clipImageView];
    [self.view bringSubviewToFront:self.squareView];
}

static CGAffineTransform  GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swapWidth = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = swapWidth;
    return rect;
}

#pragma mark - gesture actions
-(void)pinchViewAction:(UIPinchGestureRecognizer *)sender
{
    NSLog(@"pinchViewAction");
    UIView *view = self.imageView;
    if (sender.state == UIGestureRecognizerStateBegan) {
        //view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale);
        //sender.scale = 1;
        CGRect oldFrame = view.frame;
        CGRect newFrame = CGRectZero;
        newFrame.size.width = oldFrame.size.width * sender.scale;
        newFrame.size.height = oldFrame.size.height * sender.scale;
        newFrame.origin.x = oldFrame.origin.x + oldFrame.size.width/2 - newFrame.size.width/2;
        newFrame.origin.y = oldFrame.origin.y + oldFrame.size.height/2 - newFrame.size.height/2;
        view.frame = newFrame;
        sender.scale = 1;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        [self clearClipPicture];
        //view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale);
        //sender.scale = 1;
        CGRect oldFrame = view.frame;
        CGRect newFrame = CGRectZero;
        newFrame.size.width = oldFrame.size.width * sender.scale;
        newFrame.size.height = oldFrame.size.height * sender.scale;
        newFrame.origin.x = oldFrame.origin.x + oldFrame.size.width/2 - newFrame.size.width/2;
        newFrame.origin.y = oldFrame.origin.y + oldFrame.size.height/2 - newFrame.size.height/2;
        view.frame = newFrame;
        sender.scale = 1;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.imageView.frame;
        frame = [self handleScaleOverflow:frame];
        frame = [self handleBorderOverflow:frame];
        [UIView animateWithDuration:0.5 animations:^{
            self.squareView.frame = self.cropFrame;
            self.imageView.frame = frame;
            self.lastFrame = frame;
        } completion:^(BOOL finished) {
            self.imageView.alpha = 0.2;
            // 点亮要裁剪的图片
            [self illumeClipPicture];
        }];
    }
}

-(void)panViewAction:(UIPanGestureRecognizer *)sender
{
    //NSLog(@"panViewAction");
    UIView *view = self.view;
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:view];
        [self moveTouchBegin:point];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender locationInView:view];
        [self moveTouch:point];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self moveTouchEnd];
    }
}

#pragma mark - handle imageView
-(CGRect)handleBorderOverflow:(CGRect)newFrame;
{
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) {
        // 图片偏右，将其左侧和crop左侧对齐
        newFrame.origin.x = self.cropFrame.origin.x;
    }
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) {
        // 图片偏左，将其右侧和crop的右侧对齐
        newFrame.origin.x = self.cropFrame.origin.x + self.cropFrame.size.width - newFrame.size.width;
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
    if (self.imageView.frame.size.width > self.imageView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        // 如果图片高度小于crop高度，垂直居中
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height)/2;
    }
    return newFrame;
}

-(CGRect)handleScaleOverflow:(CGRect)newFrame
{
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        // 如果图片宽度小于crop宽度，弹回
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        // 如果图片宽度大于large宽度，控制放大为最大
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

#pragma mark - get subImage
-(UIImage *)getSubImage
{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.lastFrame.size.width/self.originalImage.size.width;
    // 以下处理是因为图片的尺寸往往和屏幕控件的尺寸大小比例不同，或压缩或放大，截取的时候不能按控件的显示截取，而要根据比例在图片上截取
    CGFloat x = (squareFrame.origin.x - self.lastFrame.origin.x)/scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.lastFrame.origin.y)/scaleRatio;
    CGFloat w = squareFrame.size.width/scaleRatio;
    CGFloat h = squareFrame.size.height/scaleRatio;

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

