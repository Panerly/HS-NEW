//
//  CompleteModel.h
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompleteModel : NSObject

@property (nonatomic, strong) NSString *meter_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *collect_time;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *install_time;
@property (nonatomic, strong) NSString *collect_num;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *install_addr;
@property (nonatomic, strong) NSString *collect_area;
@property (nonatomic, strong) NSString *collect_avg;
@property (nonatomic, strong) NSString *metering_status;

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *second_img;
@property (nonatomic, strong) UIImage *third_img;

@end
