//
//  DetailViewController.h
//  first
//
//  Created by HS on 16/6/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRModel.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) NSString *titleName;
//网络编号
@property (weak, nonatomic) IBOutlet UILabel *netNum;
//用户号
@property (weak, nonatomic) IBOutlet UILabel *userNum;
//表位号
@property (weak, nonatomic) IBOutlet UILabel *meterNum;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *userName;
//用户地址
@property (weak, nonatomic) IBOutlet UILabel *userAddr;
//口径
@property (weak, nonatomic) IBOutlet UILabel *caliber;
//表型
@property (weak, nonatomic) IBOutlet UILabel *meterPhenoType;
//抄表时间
@property (weak, nonatomic) IBOutlet UILabel *readingTime;
//抄见度数
@property (weak, nonatomic) IBOutlet UILabel *degrees;
//警报
@property (weak, nonatomic) IBOutlet UILabel *alarm;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
- (IBAction)reportAction:(id)sender;

@property (nonatomic, strong) CRModel *crModel;

@end
