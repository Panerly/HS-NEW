//
//  LitMeterDetailTableViewCell.h
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LitMeterDetailModel.h"

@interface LitMeterDetailTableViewCell : UITableViewCell
/**
 *  用户地址
 */
@property (weak, nonatomic) IBOutlet UILabel *userAddr;
/**
 *  地址
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *meter_status;
- (IBAction)navi:(id)sender;

/**
 *  model
 */
@property (nonatomic, strong) LitMeterDetailModel *litMeterDetailModel;
- (IBAction)scanHisBtn:(id)sender;

@end
