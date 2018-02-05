//
//  MYActionSheet.m
//  
//
//  Created by Gguomingyue on 2018/1/9.
//  Copyright © 2018年 GMY. All rights reserved.
//

#import "MYActionSheetViewController.h"
#import "MYActionSheetCellModel.h"
#import "MYActionSheetCell.h"
#import "MYActionSheetDefines.h"
#import "MYLayoutRate.h"
#import "UIColor+Extension.h"

@implementation MYSheetAction

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)actionWithTitle:(NSString *)title hander:(MYSheetActionBlock)hander
{
    MYSheetAction *action = [[self alloc] init];
    if (action) {
        action.title = title;
        action.block = hander;
    }
    return action;
}

@end

static NSString *const cellSeparatorLineColor = @"#ECECEC";

@interface MYActionSheetViewController ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<MYSheetAction *> *sourceArray;
@property (nonatomic, strong) NSMutableArray<MYSheetActionBlock> *blockArray;
@property (nonatomic, strong) NSMutableArray<MYActionSheetCellModel *> *modelArray;
@property (nonatomic, assign) BOOL tableViewVisible;

@end

@implementation MYActionSheetViewController
#pragma mark - constructed functions
-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)ActionSheetViewController
{
    MYActionSheetViewController *actionSheetViewController = [[MYActionSheetViewController alloc] init];
    return actionSheetViewController;
}

#pragma mark - setters and getters
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, MYLAYOUTRATE(3 * 54 + 6)) style:UITableViewStylePlain];
        _tableView.backgroundColor = KGlobalViewBgColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = [[UIView alloc] init];
        
        // 适配iOS11，用于有效设置section的header和footer的高度
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}

-(NSMutableArray<MYSheetAction *> *)sourceArray
{
    if (!_sourceArray) {
        _sourceArray = [@[] mutableCopy];
    }
    return _sourceArray;
}

-(NSMutableArray<MYActionSheetCellModel *> *)modelArray
{
    if (!_modelArray) {
        _modelArray = [@[] mutableCopy];
    }
    return _modelArray;
}

-(NSMutableArray<MYSheetActionBlock> *)blockArray
{
    if (!_blockArray) {
        _blockArray = [@[] mutableCopy];
    }
    return _blockArray;
}

-(void)setTableViewVisible:(BOOL)tableViewVisible
{
    if (tableViewVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.transform = CGAffineTransformTranslate(self.tableView.transform, 0, -MYLAYOUTRATE(3 * 54 + 6));
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.transform = CGAffineTransformIdentity;
        }];
    }
    _tableViewVisible = tableViewVisible;
}

#pragma mark - setup view
-(void)setupView
{
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - view life time
-(void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = KGlobalViewBgColor;
    self.view.backgroundColor = [UIColor colorWithRGBString:@"#FAFAFA" Alpha:0.5f];
    //self.modalViewController.definesPresentationContext = YES;
    //self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableViewVisible = YES;
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

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MYLAYOUTRATE(54);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 0.01f;
    }
    return MYLAYOUTRATE(6.0f);
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor colorWithRGBString:@"#F0F0F0"];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        cell.backgroundColor = [UIColor whiteColor];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 0, 0);
        BOOL addLine = NO;
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            addLine = YES;
        } else {
            addLine = NO;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        
        //颜色修改
        layer.strokeColor = [UIColor colorWithRGBString:cellSeparatorLineColor].CGColor;
        layer.fillColor=[UIColor whiteColor].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (2.0f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width
                                         , lineHeight);
            lineLayer.backgroundColor = [UIColor colorWithRGBString:cellSeparatorLineColor].CGColor;
            [layer addSublayer:lineLayer];
        }
        
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            [self popActionSheet];
            MYSheetActionBlock block = [self.blockArray objectAtIndex:indexPath.section * (self.blockArray.count - 1) + indexPath.row];
            MYSheetAction *action = [self.sourceArray objectAtIndex:indexPath.section * (self.sourceArray.count - 1) + indexPath.row];
            block(action);
        }
            break;
        case 1:
        {
            [self popActionSheet];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sourceArray.count == 1) {
        return 1;
    } else if (self.sourceArray.count == 0) {
        return 0;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sourceArray.count == 1) {
        return 1;
    }
    if (section == 0) {
        return self.modelArray.count - 1;
    } else {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYActionSheetCell *cell = [MYActionSheetCell CellWithTableView:tableView];
    cell.model = self.modelArray[indexPath.section * (self.modelArray.count - 1) + indexPath.row];
    return cell;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - add actions and cancel action
-(void)addAction:(MYSheetAction *)action
{
    if (self.sourceArray.count > 0) {
        [self.sourceArray insertObject:action atIndex:self.sourceArray.count - 1];
        MYActionSheetCellModel *model = [[MYActionSheetCellModel alloc] init];
        model.titleString = action.title;
        [self.modelArray insertObject:model atIndex:self.modelArray.count - 1];
        if (action.block) {
            [self.blockArray insertObject:action.block atIndex:self.blockArray.count - 1];
        } else {
            MYSheetActionBlock block = ^(MYSheetAction * action){};
            [self.blockArray insertObject:block atIndex:self.blockArray.count - 1];
        }
    } else {
        [self.sourceArray addObject:action];
        MYActionSheetCellModel *model = [[MYActionSheetCellModel alloc] init];
        model.titleString = action.title;
        [self.modelArray addObject:model];
        if (action.block) {
            [self.blockArray addObject:action.block];
        } else {
            MYSheetActionBlock block = ^(MYSheetAction * action){};
            [self.blockArray addObject:block];
        }
    }
    [self.tableView reloadData];
}

-(void)addCancelAction:(MYSheetAction *)action
{
    if (self.sourceArray.count > 0) {
        [self.sourceArray insertObject:action atIndex:self.sourceArray.count];
        MYActionSheetCellModel *model = [[MYActionSheetCellModel alloc] init];
        model.titleString = action.title;
        [self.modelArray insertObject:model atIndex:self.modelArray.count];
        if (action.block) {
            [self.blockArray insertObject:action.block atIndex:self.blockArray.count];
        } else {
            MYSheetActionBlock block = ^(MYSheetAction * action){};
            [self.blockArray insertObject:block atIndex:self.blockArray.count];
        }
    } else {
        [self.sourceArray addObject:action];
        MYActionSheetCellModel *model = [[MYActionSheetCellModel alloc] init];
        model.titleString = action.title;
        [self.modelArray addObject:model];
        if (action.block) {
            [self.blockArray addObject:action.block];
        } else {
            MYSheetActionBlock block = ^(MYSheetAction * action){};
            [self.blockArray addObject:block];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - button actions
-(void)tapAction
{
    [self popActionSheet];
}

#pragma mark - private actions
-(void)popActionSheet
{
    self.tableViewVisible = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - custom present action
-(void)presentWith:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion
{
    controller.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [controller presentViewController:self animated:animated completion:nil];
}


@end
