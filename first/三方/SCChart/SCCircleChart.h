//
//  PNCircleChart.h
//  PNChartDemo
//
//  Created by kevinzhow on 13-11-30.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCColor.h"
#import "UICountingLabel.h"

typedef NS_ENUM (NSUInteger, SCChartFormatType) {
    SCChartFormatTypePercent,
    SCChartFormatTypeDollar,
    SCChartFormatTypeNone
};

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface SCCircleChart : UIView

- (void)strokeChart;
- (void)growChartByAmount:(NSNumber *)growAmount;
- (void)updateChartByCurrent:(NSNumber *)current;
- (void)updateChartByCurrent:(NSNumber *)current byTotal:(NSNumber *)total;
- (id)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise;

- (id)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor;

- (id)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel;

- (id)initWithFrame:(CGRect)frame
              total:(NSNumber *)total
            current:(NSNumber *)current
          clockwise:(BOOL)clockwise
             shadow:(BOOL)hasBackgroundShadow
        shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel
  overrideLineWidth:(NSNumber *)overrideLineWidth;

@property (strong, nonatomic) UICountingLabel *countingLabel;
@property (nonatomic, assign) UIColor *strokeColor;
@property (nonatomic, assign) UIColor *strokeColorGradientStart;
@property (nonatomic, assign) NSNumber *total;
@property (nonatomic, assign) NSNumber *current;
@property (nonatomic, assign) NSNumber *lineWidth;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic) SCChartFormatType chartType;
@property (nonatomic, copy) NSString *format;


@property (nonatomic, assign) CAShapeLayer *circle;
@property (nonatomic, assign) CAShapeLayer *gradientMask;
@property (nonatomic, assign) CAShapeLayer *circleBackground;

@property (nonatomic) BOOL displayCountingLabel;

@end
