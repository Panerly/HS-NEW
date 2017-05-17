//
//  LitMeterListTableViewCell.h
//  first
//
//  Created by HS on 16/9/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LitMeterModel.h"
@interface LitMeterListTableViewCell : UITableViewCell
/**
 *  小区名
 */
@property (weak, nonatomic) IBOutlet UILabel *village_name;
/**
 *  每个小区里面的户数
 */
@property (weak, nonatomic) IBOutlet UILabel *village_num;

@property (nonatomic, strong) LitMeterModel *litMeterModel;

@end
