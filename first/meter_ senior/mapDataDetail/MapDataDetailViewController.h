//
//  MapDataDetailViewController.h
//  first
//
//  Created by HS on 2016/12/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDataModel.h"

@interface MapDataDetailViewController : UIViewController

@property (nonatomic, strong) NSString *collect_area_bs;

@property (nonatomic, strong) MapDataModel *mapDataModel;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end
