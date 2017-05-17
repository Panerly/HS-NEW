//
//  weatherModel.h
//  first
//
//  Created by HS on 16/6/17.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface weatherModel : JSONModel

//城市
@property (nonatomic, strong) NSString *city;
//城市拼音
@property (nonatomic, strong) NSString *pinyin;
//城市编码
@property (nonatomic, strong) NSString *citycode;
//日期
@property (nonatomic, strong) NSString *date;
//发布时间
@property (nonatomic, strong) NSString *time;
//天气情况
@property (nonatomic, strong) NSString *weather;
//气温
@property (nonatomic, strong) NSString *temp;
//风向
@property (nonatomic, strong) NSString *WD;
//风力
@property (nonatomic, strong) NSString *WS;

@end
