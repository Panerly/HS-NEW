//
//  HisDetailTableViewCell.h
//  first
//
//  Created by HS on 16/6/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HisDetailModel.h"
@interface HisDetailTableViewCell : UITableViewCell
//水表读数
@property (weak, nonatomic) IBOutlet UILabel *meterReadNum;
//序号
@property (weak, nonatomic) IBOutlet UILabel *serialNum;
//抄收时间
@property (weak, nonatomic) IBOutlet UILabel *readingTimeLabel;
//流量
@property (weak, nonatomic) IBOutlet UILabel *flowNum;

@property (nonatomic, strong) HisDetailModel *hisDetailModel;

@end
