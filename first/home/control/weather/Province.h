//
//  Province.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Province : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, strong)NSMutableArray *cities;

@end
