//
//  MeterInfoModel.h
//  first
//
//  Created by HS on 16/8/10.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterInfoModel : JSONModel
//小区名
@property (nonatomic, strong) NSString<Optional> *install_Addr;
//照片名称1
@property (nonatomic, strong) NSString<Optional> *collect_Img_Name1;
//照片名称2
@property (nonatomic, strong) NSString<Optional> *collect_Img_Name2;
//照片名称3
@property (nonatomic, strong) NSString<Optional> *collect_Img_Name3;
//所属小区或区域
@property (nonatomic, strong) NSString<Optional> *collector_Area;
//通讯联络号
@property (nonatomic, strong) NSString<Optional> *comm_Id;
//安装时间
@property (nonatomic, strong) NSString<Optional> *install_Time;
//水表口径
@property (nonatomic, strong) NSString<Optional> *meter_Cali;
@property (nonatomic, strong) NSString<Optional> *meter_Id;
@property (nonatomic, strong) NSString<Optional> *meter_Name;
@property (nonatomic, strong) NSString<Optional> *meter_Txm;
@property (nonatomic, strong) NSString<Optional> *meter_Wid;
@property (nonatomic, strong) NSString<Optional> *remark;
@property (nonatomic, strong) NSString<Optional> *user_Id;
@property (nonatomic, strong) NSString<Optional> *water_Kind;
//标示
@property (nonatomic, strong) NSString<Optional> *bs;

//经纬度
@property (nonatomic, strong) NSString<Optional> *x;
@property (nonatomic, strong) NSString<Optional> *y;

@property (nonatomic, strong) NSString<Optional> *id;


//区域编码
@property (nonatomic, strong) NSString<Optional> *area_Id;
//小区
@property (nonatomic, strong) NSString<Optional> *area_Name;

@end
