//
//  HisDetailTableViewCell.m
//  first
//
//  Created by HS on 16/6/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "HisDetailTableViewCell.h"

@implementation HisDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _meterReadNum.text      = [NSString stringWithFormat:@"水表读数: %@",_hisDetailModel.collect_num];
    _readingTimeLabel.text  = [NSString stringWithFormat:@"抄收时间: %@",_hisDetailModel.collect_dt];
    _flowNum.text           = [NSString stringWithFormat:@"流量: %@m³/h",_hisDetailModel.collect_avg];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
