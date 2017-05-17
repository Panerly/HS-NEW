//
//  WeatherModel.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "JSONModel.h"

@interface WeatherModel : JSONModel
//温度
@property (nonatomic, copy)NSString *temp;
//天气
@property (nonatomic, copy)NSString *weather;
//城市
@property (nonatomic, copy)NSString *city;
//风向
@property (nonatomic, copy)NSString *WD;
//风级
@property (nonatomic, copy)NSString *WS;
//更新日期
@property (nonatomic, copy)NSString *date;
//更新时间
@property (nonatomic, copy)NSString *time;

@end
