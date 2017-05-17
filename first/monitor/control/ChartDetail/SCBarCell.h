//
//  DCBarCell.h
//  UUChart
//
//  Created by 2014-763 on 15/3/13.
//  Copyright (c) 2015年 meilishuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCBarCell : UITableViewCell

//x轴坐标
@property (nonatomic, strong) NSMutableArray *xNum;
//y轴坐标
@property (nonatomic, strong) NSMutableArray *yNum;

- (void)configUI:(NSIndexPath *)indexPath;

@end
