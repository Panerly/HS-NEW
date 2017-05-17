//
//  LitMeterDetailTableViewCell.m
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailTableViewCell.h"
#import "MeterDataViewController.h"

@implementation LitMeterDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.userAddr.text      = [self _clearLineBreak:self.litMeterDetailModel.user_addr];
    self.meter_status.text  = [self isNormal:self.litMeterDetailModel.collect_Status];
}

- (NSString *)isNormal :(NSString *)isNormal {
    if (![isNormal isEqualToString:@"正常"]) {
        
        self.meter_status.textColor = [UIColor redColor];
    } else {
        
        self.meter_status.textColor = [UIColor blueColor];
    }
    return [NSString stringWithFormat:@"状态：%@",isNormal];
}

- (NSString *)_clearLineBreak:(NSString *)string {

    //去除\n
    if ([string rangeOfString:@"\n"].location != NSNotFound) {
        
        [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    return string;
}

- (UIViewController *)findVC
{
    UIResponder *next = self.nextResponder;
    
    while (1) {
        
        if ([next isKindOfClass:[UIViewController class]]) {
            
            return  (UIViewController *)next;
        }
        next =  next.nextResponder;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  导航
 *
 *  @param sender <#sender description#>
 */
- (IBAction)navi:(id)sender {
    
    if ([self.litMeterDetailModel.con_x isEqualToString:@"0"]) {
        NSLog(@"暂无坐标信息");
    }
    GUAAlertView *alert = [GUAAlertView alertViewWithTitle:@"提示" message:@"无法获取用户地理信息！" buttonTitle:@"确定" buttonTouchedAction:^{
        
    } dismissAction:^{
        
    }];
    [alert show];
}
- (IBAction)scanHisBtn:(id)sender {
    
    MeterDataViewController *meterDataVC    = [[MeterDataViewController alloc] init];
    meterDataVC.isBigMeter                  = NO;
    meterDataVC.user_id_str                 = self.litMeterDetailModel.user_Id;
    [[self findVC] showViewController:meterDataVC sender:nil];
}
@end
