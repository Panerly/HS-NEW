//
//  LitMeterDetailModel.h
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface LitMeterDetailModel : JSONModel

/**
 *  户名
 */
@property (nonatomic, strong) NSString *user_addr;

/**
 *  用户ID
 */
@property (nonatomic, strong) NSString *user_Id;


/**
 *  地理坐标
 */
@property (nonatomic, strong) NSString *small_x;
@property (nonatomic, strong) NSString *small_y;

//水表状态
@property (nonatomic, strong) NSString *collect_Status;

//本期抄表日期
@property (nonatomic, strong) NSString *collect_dt;
//采集编号
@property (nonatomic, strong) NSString *collect_no;
//本期抄见
@property (nonatomic, strong) NSString *collect_num;
//本期用量
@property (nonatomic, strong) NSString *collect_yl;
//所属区域
@property (nonatomic, strong) NSString *collector_area;
//所属地区
@property (nonatomic, strong) NSString <Optional>*collector_region;
//通讯编号
@property (nonatomic, strong) NSString *comm_id;
//集中器号
@property (nonatomic, strong) NSString *con_no;

//集中器经纬度
@property (nonatomic, strong) NSString *con_x;
@property (nonatomic, strong) NSString *con_y;

//水表口径
@property (nonatomic, strong) NSString *meter_cali;
//表号
@property (nonatomic, strong) NSString *meter_id;
//小区名称
@property (nonatomic, strong) NSString *small_name;
//上期抄见日期
@property (nonatomic, strong) NSString *up_collect_dt;
//上期抄见读数
@property (nonatomic, strong) NSString *up_collect_num;
//上期用量
@property (nonatomic, strong) NSString *up_collect_yl;

@end
