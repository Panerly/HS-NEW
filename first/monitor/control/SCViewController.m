//
//  SCViewController.m
//  SCChart
//
//  Created by 2014-763 on 15/3/13.
//  Copyright (c) 2015年 meilishuo. All rights reserved.
//

#import "SCViewController.h"
#import "SCChartCell.h"
#import "SCBarCell.h"

typedef NS_ENUM(NSInteger, SectionNum) {
    SectionNum1 = 0,
    SectionNum2 = 1
};

@interface SCViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SCViewController
static NSString *reuseIdentifierChart = @"SCChartCell";
static NSString *reuseIdentifierBar = @"SCBarCell";

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[SCChartCell class] forCellReuseIdentifier:reuseIdentifierChart];
    [tableView registerClass:[SCBarCell class] forCellReuseIdentifier:reuseIdentifierBar];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionNum1:
            return SectionNum2;
            break;
        case SectionNum2:
            return SectionNum2;
            break;

        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.section) {
        case SectionNum1:
        {
            SCChartCell *cell  = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierChart forIndexPath:indexPath];
            cell.xNum = _xArr;
            cell.yNum = _yArr;
            if (!cell) {
                cell = [[SCChartCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifierChart];
            }
            [cell configUI:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
            break;
            
        case SectionNum2:
        {
            
            SCBarCell *barCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierBar forIndexPath:indexPath];
            barCell.xNum = _xArr;
            barCell.yNum = _yArr;
            if (!barCell) {
                barCell = [[SCBarCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifierBar];
            }
            [barCell configUI:indexPath];
            barCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return barCell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 30);
    UILabel *showingLabel = [[UILabel alloc] initWithFrame:frame];
    showingLabel.font = [UIFont systemFontOfSize:14];
    showingLabel.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3];
    
    switch (section) {
        case 0:
            showingLabel.text = @"折线图·水表读数";
            break;
        case 1:
            showingLabel.text = @"柱状图·水表读数·所有数据";
            break;

        default:
            break;
    }
    showingLabel.textColor = [UIColor colorWithRed:0.257 green:0.650 blue:0.478 alpha:1.000];
    showingLabel.textAlignment = NSTextAlignmentCenter;
    return showingLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
@end
