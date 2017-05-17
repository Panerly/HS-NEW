//
//  QueryTableViewCell.h
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueryModel.h"

@interface QueryTableViewCell : UITableViewCell
//日期
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

//用量
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;

@property (weak, nonatomic) IBOutlet UILabel *collect_avg;

@property (nonatomic, strong) QueryModel *queryModel;

@end
