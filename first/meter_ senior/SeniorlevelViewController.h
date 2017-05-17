//
//  SeniorlevelViewController.h
//  first
//
//  Created by HS on 2016/12/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDataModel.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface SeniorlevelViewController : UIViewController
<
BMKMapViewDelegate,
BMKLocationServiceDelegate
>

@property (nonatomic, strong) MapDataModel *mapDataModel;

@property (nonatomic, strong) NSMutableArray *infoDataArr;
@property (nonatomic, strong) NSMutableArray *bigMeterDataArr;
@property (nonatomic, strong) NSMutableArray *litMeterDataArr;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bigMeterDetailArr;

@end
