//
//  LitMeterDetailViewController.h
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LitMeterDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *usageLabel;

/**
 *  用户名
 */
@property (weak, nonatomic) IBOutlet UILabel *user_name;
/**
 *  采集编号
 */
@property (weak, nonatomic) IBOutlet UILabel *collect_id;

/**
 *  用水类型
 */
@property (weak, nonatomic) IBOutlet UILabel *water_type;

/**
 *  手机号
 */
@property (weak, nonatomic) IBOutlet UILabel *phone_num;

/**
 *  用户地址
 */
@property (weak, nonatomic) IBOutlet UILabel *user_addr;

/**
 *  区域
 */
@property (weak, nonatomic) IBOutlet UILabel *location;

/**
 *  表况
 */
@property (weak, nonatomic) IBOutlet UILabel *meter_condition;

/**
 *  上期读数
 */
@property (weak, nonatomic) IBOutlet UILabel *previous_reading;

/**
 *  本期读数
 */
@property (weak, nonatomic) IBOutlet UILabel *current_reading;

/**
 *  用量
 */
@property (weak, nonatomic) IBOutlet UILabel *usage;

/**
 *  备注
 */
@property (weak, nonatomic) IBOutlet UILabel *remark;


@property (nonatomic, strong) NSString *meter_ID;
@property (nonatomic, strong) NSString *user_name_str;
@property (nonatomic, strong) NSString *collect_id_str;
@property (nonatomic, strong) NSString *water_type_str;
@property (nonatomic, strong) NSString *phone_num_str;
@property (nonatomic, strong) NSString *location_str;
@property (nonatomic, strong) NSString *meter_condition_str;
@property (nonatomic, strong) NSString *previous_reading_str;
@property (nonatomic, strong) NSString *current_reading_str;
@property (nonatomic, strong) NSString *usage_str;
@property (nonatomic, strong) NSString *remark_str;
@property (nonatomic, strong) NSString *user_addr_str;


@end
