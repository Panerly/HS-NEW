//
//  HisDetailModel.h
//  first
//
//  Created by HS on 16/6/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface HisDetailModel : JSONModel
//用户名
@property (nonatomic, strong) NSString <Optional>*meter_name;
//用户号
@property (nonatomic, strong) NSString *meter_id;
//表类型
@property (nonatomic, strong) NSString <Optional>*meter_name2;
//表口径
@property (nonatomic, strong) NSString <Optional>*meter_cali;

//水表读数
@property (nonatomic, strong) NSString *collect_num;
//流量
@property (nonatomic, strong) NSString *collect_avg;
//抄收时间
@property (nonatomic, strong) NSString *collect_dt;

@end
