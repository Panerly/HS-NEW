//
//  HisDetailViewController.h
//  first
//
//  Created by HS on 16/6/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HisDetailModel.h"

@interface HisDetailViewController : UIViewController
- (IBAction)dateBtn:(UIButton *)sender;
//用户号
@property (weak, nonatomic) IBOutlet UILabel *meter_id;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *meter_name;
//表类型
@property (weak, nonatomic) IBOutlet UILabel *meter_name2;
//表口径
@property (weak, nonatomic) IBOutlet UILabel *meter_cali;

//流量统计
@property (weak, nonatomic) IBOutlet UILabel *flowStatistics;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *formDate;
@property (weak, nonatomic) IBOutlet UITextField *toDate;
- (IBAction)confirmBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chartBtn;

//用户信息
@property (nonatomic, strong) NSString *ipLabel;
@property (nonatomic, strong) NSString *dbLabel;
@property (nonatomic, strong) NSString *userNameLabel;
@property (nonatomic, strong) NSString *passWordLabel;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) HisDetailModel *hisDetailModel;


//横坐标数组
@property (nonatomic, strong) NSMutableArray *xArr;
//纵坐标数组
@property (nonatomic, strong) NSMutableArray *yArr;

@end
