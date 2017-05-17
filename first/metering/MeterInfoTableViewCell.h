//
//  MeterInfoTableViewCell.h
//  first
//
//  Created by HS on 16/8/10.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterInfoModel.h"
@interface MeterInfoTableViewCell : UITableViewCell

//所属小区
@property (weak, nonatomic) IBOutlet UILabel *area;

- (IBAction)naviBtn:(id)sender;

@property (nonatomic, strong) MeterInfoModel *meterInfoModel;

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;
@property (weak, nonatomic) IBOutlet UILabel *num;

@end
