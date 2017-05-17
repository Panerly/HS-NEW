//
//  MeterDataTableViewCell.m
//  first
//
//  Created by HS on 16/6/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterDataTableViewCell.h"

@implementation MeterDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_meterDataModel.message) {
        
        _message.text = [NSString stringWithFormat:@"水表数据: %@",_meterDataModel.message];
    }else {
        _message.text = @"";
    }
    
    
    if (_meterDataModel.collect_dt) {
        
        _collect_dt.text = [NSString stringWithFormat:@"抄收时间: %@",_meterDataModel.collect_dt];
    } else {
        _collect_dt.text = [NSString stringWithFormat:@"抄收时间: %@", _meterDataModel.collect_data];
    }
    
    
    _collect_num.text = [NSString stringWithFormat:@"参考读数: %@",_meterDataModel.collect_num];
   
    
    _messageFlg.text = [self isNormol:_meterDataModel.messageFlg];
    
}

- (NSString *)isNormol :(NSString *)messageFlg
{
    if ([messageFlg isEqualToString:@"0"] || [messageFlg isEqualToString:@"1"]) {
        
        if ([messageFlg isEqualToString:@"0"]) {
            
            return @"处理状态: 已处理";
        }else
        {
            return @"处理状态: 未处理";
        }
    }else {
        NSString *str = [NSString stringWithFormat:@"水表状态：%@",_meterDataModel.meter_status?_meterDataModel.meter_status : _meterDataModel.collect_Status];
        if (![str isEqualToString:@"水表状态：正常"]) {
            _messageFlg.textColor = [UIColor redColor];
        } else {
            _messageFlg.textColor = [UIColor blackColor];
        }
        return [NSString stringWithFormat:@"水表状态：%@",_meterDataModel.meter_status?_meterDataModel.meter_status : _meterDataModel.collect_Status];
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
