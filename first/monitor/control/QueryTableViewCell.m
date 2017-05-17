//
//  QueryTableViewCell.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "QueryTableViewCell.h"

@implementation QueryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

//- (void)setQueryModel:(QueryModel *)queryModel
//{
//    if (_queryModel != queryModel) {
//        _queryModel = queryModel;
//        self.dayLabel.text = self.queryModel.collect_dt;
//        if (self.queryModel.collect_avg == nil) {
//            
//            [self.collect_avg removeFromSuperview];
//            self.dosageLabel.text = [NSString stringWithFormat:@"用量: %@ 吨",self.queryModel.collect_num];
//            [self.dosageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.centerX);
//            }];
//            [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.mas_left);
//                make.centerX.equalTo(self.centerX);
//                make.size.equalTo(CGSizeMake(150, 25));
//            }];
//            
//        } else {
//            [self addSubview:self.collect_avg];
//            
//            [self.collect_avg mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.mas_top);
//                make.right.equalTo(self.mas_right);
//                make.size.equalTo(CGSizeMake(110, 25));
//            }];
//            [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.mas_left);
//                make.centerX.equalTo(self.centerX);
//                make.size.equalTo(CGSizeMake(150, 25));
//            }];
//            [self.dosageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.collect_avg.mas_bottom);
//                make.right.equalTo(self.mas_right);
//                //make.top.equalTo(self.collect_avg.mas_bottom);
//                make.size.equalTo(CGSizeMake(110, 25));
//            }];
//            
//            self.dosageLabel.text = [NSString stringWithFormat:@"水表读数: %@ 吨",self.queryModel.collect_num];
//            self.collect_avg.text = [NSString stringWithFormat:@"水表流量: %@m³/h",self.queryModel.collect_avg];
//        }
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dayLabel.text = self.queryModel.collect_dt;
    
    if (self.queryModel.collect_avg == nil) {
        
//        [self.collect_avg removeFromSuperview];
//        self.collect_avg = nil;
        self.collect_avg.alpha = 0;
        self.dosageLabel.text = [NSString stringWithFormat:@"用量: %@ 吨",self.queryModel.collect_num];
        
    } else {
        self.collect_avg.alpha = 1;
    self.dosageLabel.text = [NSString stringWithFormat:@"水表读数: %@ 吨",self.queryModel.collect_num];
    self.collect_avg.text = [NSString stringWithFormat:@"水表流量: %@m³/h",self.queryModel.collect_avg];
        
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
