//
//  WeatherModel.m
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "WeatherModel.h"

static WeatherModel *loadingWeather = nil;
static WeatherModel *errorWeather = nil;
static WeatherModel *load;

@implementation WeatherModel
//创建一个默认的用于显示加载中对象的单例
+ (instancetype)loadingWeather {
    if (loadingWeather == nil) {
        loadingWeather = [[self alloc] init];
        loadingWeather.city = @"加载中";
        loadingWeather.weather = @"加载中";
        loadingWeather.time = @"";
        loadingWeather.date = @"加载中";
        loadingWeather.temp = @"加载中";
        loadingWeather.WD = @"加载中";
        loadingWeather.WS = @"加载中";
    }
    return loadingWeather;
}
//创建一个默认的用于显示加载失败对象的单例
+ (instancetype)errorWeather {
    if (errorWeather == nil) {
        errorWeather = [[self alloc] init];
        errorWeather.city = @"加载失败";
        errorWeather.weather = @"加载失败";
        errorWeather.time = @"";
        errorWeather.date = @"加载失败";
        errorWeather.temp = @"加载失败";
        errorWeather.WD = @"加载失败";
        errorWeather.WS = @"加载失败";
    }
    return errorWeather;
}

//+ (instancetype)loadweatherWithDic:(NSDictionary *)Dic
//{
//    loadingWeather.temp = [Dic valueForKey:@"SD"];
//    return loadingWeather;
//}

- (void)setTemp:(NSString *)temp {
    if ([temp isEqualToString:@"加载中"] || [temp isEqualToString:@"加载失败"]) {
        _temp = temp;
    }
    else {
        _temp = [NSString stringWithFormat:@"%@℃",temp];
    }
}

@end
