//
//  MeteringSingleTableViewCell.h
//  first
//
//  Created by HS on 2016/10/9.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterInfoModel.h"
@interface MeteringSingleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *install_addr;

@property (nonatomic, strong) MeterInfoModel *meterInfoModel;

@end
