//
//  MapDataModel.h
//  first
//
//  Created by HS on 2016/12/5.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MapDataModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*area_id;
@property (nonatomic, strong) NSString <Optional>*area_name;
@property (nonatomic, strong) NSString <Optional>*bs;
@property (nonatomic, strong) NSString <Optional>*collect_dt;
@property (nonatomic, strong) NSString <Optional>*collect_img_name1;
@property (nonatomic, strong) NSString <Optional>*collect_img_name2;
@property (nonatomic, strong) NSString <Optional>*collect_num;
@property (nonatomic, strong) NSString <Optional>*install_addr;
@property (nonatomic, strong) NSString <Optional>*meter_id;
@property (nonatomic, strong) NSString <Optional>*x;
@property (nonatomic, strong) NSString <Optional>*y;

@end
