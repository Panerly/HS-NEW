//
//  LitMeterListViewController.h
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LitMeterListViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;//数据
@property (nonatomic, strong) NSMutableArray *abnormalDataArray;//异常数据
//@property (nonatomic, strong)NSMutableArray<NSNumber *> *isExpland;//这里用到泛型，防止存入非数字类型

@property (nonatomic, strong) NSString *isHisData;

@end
