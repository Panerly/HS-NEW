//
//  LitMeterDetailDataModel.h
//  first
//
//  Created by HS on 2016/10/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface LitMeterDetailDataModel : JSONModel

//抄收时间
@property (nonatomic, strong) NSString *collect_dt;
//抄收读数
@property (nonatomic, strong) NSString *collect_num;

@end
