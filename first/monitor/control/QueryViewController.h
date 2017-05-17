//
//  QueryViewController.h
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueryModel.h"

@interface QueryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *manageMeterNum;
@property (nonatomic, strong) NSString *manageMeterNumValue;

@property (weak, nonatomic) IBOutlet UILabel *meterType;
@property (weak, nonatomic) IBOutlet UILabel *flowStatisticsLabel;
@property (nonatomic, strong) NSString *meterTypeValue;

//此处通讯类型修改为口径
@property (weak, nonatomic) IBOutlet UILabel *communicationType;
@property (nonatomic, strong) NSString *communicationTypeValue;

@property (weak, nonatomic) IBOutlet UILabel *installAddr;
@property (nonatomic, strong) NSString *installAddrValue
;
- (IBAction)flowStatistics:(UISegmentedControl *)sender;

//IP地址
@property (nonatomic, strong) NSString *ip;
//数据库
@property (nonatomic, strong) NSString *db;
//密码
@property (nonatomic, strong) NSString *passWord;
//用户名
@property (nonatomic, strong) NSString *userName;

@property (weak, nonatomic) IBOutlet UILabel *previousLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;

//当天时间
@property (nonatomic, strong) NSString *dayDateTime;
//一小时时间
@property (nonatomic, strong) NSString *hourDateTime;
//一个月时间
@property (nonatomic, strong) NSString *monthDateTime;


//用户号
@property (nonatomic, strong) NSString *meter_id;

@property (nonatomic, strong) NSMutableArray *dataArr;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *btnAction;

@property (weak, nonatomic) IBOutlet UIView *curveView;

@property (nonatomic, strong) QueryModel *queryModel;

//横坐标数组
@property (nonatomic, strong) NSMutableArray *xArr;
//纵坐标数组
@property (nonatomic, strong) NSMutableArray *yArr;


@property (weak, nonatomic) IBOutlet UISegmentedControl *switchBtn;


@end
