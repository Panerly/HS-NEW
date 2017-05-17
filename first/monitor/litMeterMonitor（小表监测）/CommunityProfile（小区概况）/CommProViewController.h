//
//  CommProViewController.h
//  first
//
//  Created by HS on 16/8/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface CommProViewController : UIViewController
<
BMKMapViewDelegate,
BMKLocationServiceDelegate
>

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *houseHoldArray;//存用户地址

@end
