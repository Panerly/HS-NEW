//
//  CompleteTableViewCell.m
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CompleteTableViewCell.h"
#import "CompleteViewController.h"


@implementation CompleteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.completeModel.collect_num) {
        self.meter_id.text = [NSString stringWithFormat:@"本期抄收值： %@ m³",self.completeModel.collect_num];
    }
    if (self.completeModel.user_id) {
        self.user_id.text = [NSString stringWithFormat:@"%@",self.completeModel.user_id];
    }
    if (self.completeModel.collect_time) {
        self.collect_time.text = [NSString stringWithFormat:@"抄表时间：%@",self.completeModel.collect_time];
    }
    if (self.completeModel.image) {
        self.compImage.image = self.completeModel.image;
    }
    _click = self.completeModel.user_id;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        self.meter_id.textColor = [UIColor blackColor];
    
        self.meter_id.font = [UIFont systemFontOfSize:17];
    }];
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

}

//上传数据
- (IBAction)upload:(id)sender {
    
    [self createDB];
    
}
- (void)createDB {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    NSLog(@"大表数据库路径%@",fileName);
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where user_id = '%@'",_click]];
    
    FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
    [((CompleteViewController *)[self findVC]).dataArr removeAllObjects];
    while ([restultSet next]) {
        
        NSString *meter_id  = [restultSet stringForColumn:@"meter_id"];
        NSString *user_id   = [restultSet stringForColumn:@"user_id"];

        CompleteModel *completeModel    = [[CompleteModel alloc] init];
        completeModel.meter_id          = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id           = [NSString stringWithFormat:@"%@",user_id];
        [((CompleteViewController *)[self findVC]).dataArr addObject:completeModel];
    }
    [db close];
    
    [((CompleteViewController *)[self findVC]).tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [SCToastView showInView:((CompleteViewController *)[self findVC]).tableView text:@"上传成功" duration:.5 autoHide:YES];
}

@end
