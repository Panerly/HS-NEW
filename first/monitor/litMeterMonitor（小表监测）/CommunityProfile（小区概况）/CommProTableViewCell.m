//
//  CommProTableViewCell.m
//  first
//
//  Created by HS on 2016/11/7.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CommProTableViewCell.h"

@implementation CommProTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.meterNum.text = [NSString stringWithFormat:@"采集编号: %@",self.litMeterDetailModel.collect_no];
//    self.collectDt.text = [NSString stringWithFormat:@"抄收时间: %@",self.litMeterDetailModel.collect_dt];
//    self.installAddr.text = self.litMeterDetailModel.user_addr;
    
    //排版需要 更换位置
    self.meterNum.text = self.litMeterDetailModel.user_addr;
    self.collectDt.text = [NSString stringWithFormat:@"采集编号: %@",self.litMeterDetailModel.collect_no];
    self.installAddr.text = [NSString stringWithFormat:@"抄收时间: %@",self.litMeterDetailModel.collect_dt];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
