//
//  MeteringSingleTableViewCell.m
//  first
//
//  Created by HS on 2016/10/9.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringSingleTableViewCell.h"

@implementation MeteringSingleTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.install_addr.text = self.meterInfoModel.install_Addr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
