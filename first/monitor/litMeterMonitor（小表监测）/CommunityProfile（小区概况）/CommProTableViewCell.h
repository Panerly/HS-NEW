//
//  CommProTableViewCell.h
//  first
//
//  Created by HS on 2016/11/7.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LitMeterDetailModel.h"

@interface CommProTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *meterNum;
@property (weak, nonatomic) IBOutlet UILabel *collectDt;
@property (weak, nonatomic) IBOutlet UILabel *installAddr;

@property (nonatomic, strong) LitMeterDetailModel *litMeterDetailModel;

@end
