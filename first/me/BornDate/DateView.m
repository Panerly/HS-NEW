//
//  DateView.m
//  first
//
//  Created by HS on 16/7/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "DateView.h"

@implementation DateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        
        //计算保存按钮与dataView的位置
        
        CGFloat height = frame.size.height / 5 * 2;
        
        _save = [UIButton buttonWithType:UIButtonTypeCustom];
        _save.frame = CGRectMake(0, frame.size.height - height, frame.size.width, height /6);
        
        [self configSaveBtn];//触摸方法
        
        [self addSubview:_save];
        
        _dateView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, frame.size.height - height + height/6, frame.size.width, height / 6 * 5)];
        
        [self addSubview:_dateView];
        
        [self configDateView]; //设置选择日期界面
        
        [self transition:height];
    }
    return self;
}

- (void)transition:(CGFloat)height {
    
    //改变初始位置用于设置动画效果
    
    _save.transform = CGAffineTransformMakeTranslation(0, height);
    _dateView.transform = CGAffineTransformMakeTranslation(0, height);
}

//设置保存按钮
- (void)configSaveBtn {
    [_save setBackgroundColor:[UIColor brownColor]];
    [_save setTitle:@"保存" forState:UIControlStateNormal];
    [_save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_save addTarget:self action:@selector(saveDate) forControlEvents:UIControlEventTouchUpInside];
}

- (void)saveDate {
    
    NSDate *date = self.dateView.date;
    
    //将时间转换成字符串 保存进model.born属性
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    
    NSString *dateStr = [formatter stringFromDate:date];
    [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"bornStr"];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"reload" object:nil];
    
    [self close];
}

- (void)configDateView {
    
    //设置日期时间格式
    _dateView.backgroundColor = [UIColor whiteColor];
    _dateView.datePickerMode = UIDatePickerModeDate;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //触摸后关闭dataView的动画方法
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    if (point.x >= 0 && point.x <= self.frame.size.width && point.y >= 0 && point.y <= self.frame.size.height/ 5 * 3) {
        
        [self close];
    }
}

- (void)close {
    
    //向上拉的动画效果
    
    [UIView animateWithDuration:0.3 animations:^{
        [self transition:self.frame.size.height/ 5 * 2 ];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
