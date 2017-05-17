//
//  MeterDataViewController.h
//  first
//
//  Created by HS on 16/6/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterDataViewController : UIViewController


- (IBAction)dateBtn:(UIButton *)sender;

//查询日期
@property (weak, nonatomic) IBOutlet UITextField *fromDate;
@property (weak, nonatomic) IBOutlet UITextField *toDate;

//主叫方
@property (weak, nonatomic) IBOutlet UILabel *callerName;
@property (weak, nonatomic) IBOutlet UITextField *callerLabel;
//用户号
@property (weak, nonatomic) IBOutlet UILabel *userNumLabel;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//数量
@property (weak, nonatomic) IBOutlet UILabel *dataNum;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)conformBtn:(id)sender;

@property (nonatomic, retain) NSMutableArray *dataArr;


//用户信息
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *passWord;
@property (nonatomic, strong) NSString *db;
@property (nonatomic, strong) NSString *ip;

@property (nonatomic, assign) BOOL isBigMeter;

@property (nonatomic, strong) NSString *user_id_str;

@end
