//
//  TableViewCell.m
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.meter_id.text = [NSString stringWithFormat:@"户号:%@",self.DBModel.meter_id];
    self.user_id.text  = [NSString stringWithFormat:@"地址:%@",self.DBModel.user_addr];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
