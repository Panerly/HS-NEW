//
//  City.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherModel.h"

@interface City : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSNumber *code;
@property (nonatomic, strong)WeatherModel *weather;

@end
