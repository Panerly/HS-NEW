//
//  CRModel.h
//  first
//
//  Created by HS on 16/6/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface CRModel :JSONModel

//用户名
@property (nonatomic, strong) NSString *meter_name;

//网络编号
@property (nonatomic, strong) NSString *meter_name2;
//@property (nonatomic, strong) NSString *userPic;

//抄收时间
@property (nonatomic, strong) NSString *collect_dt;

//度数
@property (nonatomic, strong) NSString *collect_num;

//口径
@property (nonatomic, strong) NSString *meter_cali;

//用户地址
@property (nonatomic, strong) NSString *meter_user_addr;

//表号
@property (nonatomic, strong) NSString<Optional> *meter_id;

//标题名
@property (nonatomic, strong) NSString<Optional> *titleName;

//经纬度
@property (nonatomic, strong) NSString<Optional> *x;
@property (nonatomic, strong) NSString<Optional> *y;

//警报
@property (nonatomic, strong) NSString<Optional> *alarm;

@end
