//
//  BigMeterDetailCell.m
//  first
//
//  Created by HS on 2016/12/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "BigMeterDetailCell.h"
#import "UIImageView+WebCache.h"

@implementation BigMeterDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (_mapDataModel.bs) {
        self.collect_status.text = [NSString stringWithFormat:@"%@",[self returnCollectStatus:_mapDataModel.bs]];
    }
    if (_mapDataModel.collect_dt) {
        self.collect_dt.text = [NSString stringWithFormat:@"抄收时间: %@",_mapDataModel.collect_dt];
    }
    if (_mapDataModel.collect_num) {
        self.collect_num.text = [NSString stringWithFormat:@"%@m³",_mapDataModel.collect_num];
    }
    if (_mapDataModel.install_addr) {
        self.install_addr.text = [NSString stringWithFormat:@"安装地址: %@",_mapDataModel.install_addr];
    }
    if (_mapDataModel.collect_img_name1) {
        [self.collect_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,_mapDataModel.collect_img_name1]] placeholderImage:[UIImage imageNamed:@"icon_thumb_img"]];
    }
    
}

- (NSString *)returnCollectStatus :(NSString *)meterBs {
    
    if ([meterBs isEqualToString:@"0"]) {
        
        self.collect_status.textColor = [UIColor redColor];
        return @"待抄收";
    }
    self.collect_status.textColor = [UIColor blueColor];
    return @"已抄收";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
