//
//  MeterChart.h
//  first
//
//  Created by HS on 16/8/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterChartView : UIView

@property (nonatomic, strong) IBInspectable UIColor *currentColor;
@property (nonatomic, strong) IBInspectable UIColor *color;
@property (nonatomic, strong) IBInspectable UIColor *textColor;
@property (nonatomic, copy) IBInspectable NSString *title;
@property (nonatomic, assign) IBInspectable CGFloat percent;//value 0 to 1.0
@property (nonatomic, assign) IBInspectable NSInteger lineWidth;//default 5
@property (nonatomic, strong) UIFont *font;

@end
