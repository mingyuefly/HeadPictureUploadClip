//
//  MYActionSheet.h
//  
//
//  Created by Gguomingyue on 2018/1/9.
//  Copyright © 2018年 GMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MYSheetAction;
typedef void (^MYSheetActionBlock)(MYSheetAction *action);

@interface MYSheetAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) MYSheetActionBlock block;
+(instancetype)actionWithTitle:(NSString *)title hander:(MYSheetActionBlock)hander;

@end

@interface MYActionSheetViewController : UIViewController

+(instancetype)ActionSheetViewController;
-(void)addAction:(MYSheetAction *)action;
-(void)addCancelAction:(MYSheetAction *)action;
-(void)presentWith:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion;

@end
