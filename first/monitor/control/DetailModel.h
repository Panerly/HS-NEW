//
//  DetailModel.h
//  first
//
//  Created by HS on 16/6/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface DetailModel : JSONModel

//用户名
@property (nonatomic, strong) NSString *username;
//网络编号
@property (nonatomic, strong) NSString *comm_id;
//用户号、表位号
@property (nonatomic, strong) NSString *user_id;
//警报
@property (nonatomic, strong) NSString *alarm;

@end
