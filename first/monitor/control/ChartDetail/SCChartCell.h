//
//  TableViewCell.h
//  UUChartView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCChartCell : UITableViewCell

//x轴坐标
@property (nonatomic, strong) NSMutableArray *xNum;
//y轴坐标
@property (nonatomic, strong) NSMutableArray *yNum;

- (void)configUI:(NSIndexPath *)indexPath;

@end
