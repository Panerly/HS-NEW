//
//  BigMeterDetailCell.h
//  first
//
//  Created by HS on 2016/12/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDataModel.h"

@interface BigMeterDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *collect_status;

@property (weak, nonatomic) IBOutlet UILabel *collect_dt;

@property (weak, nonatomic) IBOutlet UILabel *install_addr;

@property (weak, nonatomic) IBOutlet UILabel *collect_num;

@property (weak, nonatomic) IBOutlet UIImageView *collect_image;

@property (nonatomic, strong) MapDataModel *mapDataModel;

@end
