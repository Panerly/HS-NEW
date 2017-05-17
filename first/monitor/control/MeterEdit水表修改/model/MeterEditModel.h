//
//  MeterEditModel.h
//  first
//
//  Created by HS on 16/7/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterEditModel : JSONModel
//用户号
@property (nonatomic, strong) UILabel *user_id;
//表位号
@property (nonatomic, strong) UILabel *meter_id;
//安装地址
@property (nonatomic, strong) UILabel *username;
//采集编号
@property (nonatomic, strong) UILabel *collector_id;
//字轮类型
@property (nonatomic, strong) UILabel *bz10;
//所属区域
@property (nonatomic, strong) UILabel *area;
//通讯联络号
@property (nonatomic, strong) UILabel *comm_id;
//安装时间
@property (nonatomic, strong) UILabel *install_time;
//经度
@property (nonatomic, strong) UILabel *x;
//纬度
@property (nonatomic, strong) UILabel *y;
//备注信息
@property (nonatomic, strong) UILabel *user_remark;
//单位地址
@property (nonatomic, strong) UILabel *user_addr;
//远传类型
@property (nonatomic, strong) UILabel *type_name;
//远传方式
@property (nonatomic, strong) UILabel *type;
//表身号
@property (nonatomic, strong) UILabel *meter_wid;
//表具类型
@property (nonatomic, strong) UILabel *meter_name;
//口径
@property (nonatomic, strong) UILabel *meter_cali;

@end
