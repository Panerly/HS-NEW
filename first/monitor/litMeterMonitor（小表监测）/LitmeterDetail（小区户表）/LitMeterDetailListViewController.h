//
//  LitMeterDetailListViewController.h
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnTextBlock)(NSString *showText);

@interface LitMeterDetailListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *dataArr;//所有数据
@property (nonatomic, strong) NSMutableArray *abnormalDataArr;//异常数据

@property (nonatomic, strong) NSString *village_name;

@property (nonatomic, strong) ReturnTextBlock returnTextBlock;

@property (nonatomic, strong) NSString *isNormal;

- (void)ReturnTextBlock:(ReturnTextBlock)block;

@end
