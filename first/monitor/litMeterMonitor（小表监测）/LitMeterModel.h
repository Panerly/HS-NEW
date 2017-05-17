//
//  LitMeterModel.h
//  first
//
//  Created by HS on 16/9/26.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface LitMeterModel : JSONModel


/**
 *  小区名
 */
@property (nonatomic, strong) NSString *small_name;
///**
// *  用户地址
// */
//@property (nonatomic, strong) NSString *user_addr;
///**
// *  用户id
// */
//@property (nonatomic, strong) NSString *user_id;
/**
 *  经度
 */
@property (nonatomic, strong) NSString *x;
/**
 *  纬度
 */
@property (nonatomic, strong) NSString *y;

/**
 *  每个小区里面的户数
 */
@property (nonatomic, strong) NSString *count;

@end
