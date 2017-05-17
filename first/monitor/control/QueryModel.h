//
//  QueryModel.h
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface QueryModel : JSONModel
//警报
@property (nonatomic, strong) NSString<Optional> *alarm;
//抄表时间
@property (nonatomic, strong) NSString *collect_dt;
//网络编号
@property (nonatomic, strong) NSString<Optional> *comm_id;
//抄收度数
@property (nonatomic, strong) NSString *collect_num;
//表口径
@property (nonatomic, strong) NSString<Optional> *meter_cali;
//网络编号
@property (nonatomic, strong) NSString<Optional> *meter_id;
//表名
@property (nonatomic, strong) NSString<Optional> *meter_name;
//用户地址
@property (nonatomic, strong) NSString<Optional> *user_addr;
//用户id
@property (nonatomic, strong) NSString<Optional> *user_id;
//用户名
@property (nonatomic, strong) NSString<Optional> *user_name;
//地理坐标 X
@property (nonatomic, strong) NSString<Optional> *x;
//地理坐标 Y
@property (nonatomic, strong) NSString<Optional> *y;
@property (nonatomic, strong) NSString<Optional> *collect_avg;


@end
