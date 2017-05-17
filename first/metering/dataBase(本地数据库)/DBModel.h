//
//  DBModel.h
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface DBModel : JSONModel

@property (nonatomic, strong) NSString *meter_id;
@property (nonatomic, strong) NSString *user_addr;

@end
