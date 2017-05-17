//
//  MeteringSingleViewController.h
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterInfoModel.h"

@interface MeteringSingleViewController : UIViewController

- (IBAction)segmentCtrl:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MeterInfoModel *meterInfoModel;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSString *area_id;

//任务数量
@property (weak, nonatomic) IBOutlet UILabel *messionCount;
@property (weak, nonatomic) IBOutlet UILabel *completeNum;

@end
