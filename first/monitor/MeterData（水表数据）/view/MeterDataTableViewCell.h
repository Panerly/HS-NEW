//
//  MeterDataTableViewCell.h
//  first
//
//  Created by HS on 16/6/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterDataModel.h"

@interface MeterDataTableViewCell : UITableViewCell

//水表数据
@property (weak, nonatomic) IBOutlet UILabel *message;
//收发时间
@property (weak, nonatomic) IBOutlet UILabel *collect_dt;
//参考读数
@property (weak, nonatomic) IBOutlet UILabel *collect_num;
//处理状态
@property (weak, nonatomic) IBOutlet UILabel *messageFlg;

@property (weak, nonatomic) IBOutlet UILabel *serialNum;
@property (nonatomic, strong) MeterDataModel *meterDataModel;

@end
