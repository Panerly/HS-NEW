//
//  SearchResultViewController.h
//  first
//
//  Created by HS on 16/6/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultViewController : UIViewController
// 搜索结果数据
@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) UITableView *tableView;
@end
