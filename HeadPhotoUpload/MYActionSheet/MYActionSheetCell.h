//
//  ActionSheetCell.h
//  
//
//  Created by Gguomingyue on 2018/1/9.
//  Copyright © 2018年 GMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYActionSheetCellModel.h"

@interface MYActionSheetCell : UITableViewCell

@property (nonatomic, strong) MYActionSheetCellModel *model;

+(instancetype)CellWithTableView:(UITableView *)tableView;

@end
