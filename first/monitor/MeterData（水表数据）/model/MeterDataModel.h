//
//  MeterDataModel.h
//  first
//
//  Created by HS on 16/6/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterDataModel : JSONModel
//参考读数
@property (nonatomic, strong) NSString <Optional>*collect_num;
//收发时间
@property (nonatomic, strong) NSString <Optional>*collect_dt;
//水表数据
@property (nonatomic, strong) NSString <Optional>*message;
//处理状态
@property (nonatomic, strong) NSString <Optional>*messageFlg;


//小表抄收时间（date->data）
@property (nonatomic, strong) NSString <Optional>*collect_data;

//大小表水表状态
@property (nonatomic, strong) NSString <Optional>*meter_status;
@property (nonatomic, strong) NSString <Optional>*collect_Status;

//所属区域
@property (nonatomic, strong) NSString <Optional>*vallage_name;
//用户地址
@property (nonatomic, strong) NSString <Optional>*user_addr;

@end
