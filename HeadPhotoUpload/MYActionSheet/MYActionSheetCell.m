//
//  MYActionSheetCell.m
//  
//
//  Created by Gguomingyue on 2018/1/9.
//  Copyright © 2018年 GMY. All rights reserved.
//

#import "MYActionSheetCell.h"
#import "UIColor+Extension.h"
#import "MYActionSheetDefines.h"
#import "MYLayoutRate.h"

@interface MYActionSheetCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MYActionSheetCell

#pragma mark - constructed functions
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

+(instancetype)CellWithTableView:(UITableView *)tableView
{
    NSString *identifer = NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    return (MYActionSheetCell *)cell;
}

#pragma mark - setup UI
-(void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.contentView addSubview:self.label];
    [self addConstraints];
}

-(void)addConstraints
{
    self.label.frame = self.contentView.bounds;
}

#pragma mark - getters and setters
-(UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithRGBString:@"#333333"];
        _label.font = font18;
    }
    return _label;
}

-(void)setModel:(MYActionSheetCellModel *)model
{
    _model = model;
    self.label.text = _model.titleString;
}

#pragma mark - layout subviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
    [self.contentView addSubview:self.label];
}

-(void)dealloc
{
    
}


@end

