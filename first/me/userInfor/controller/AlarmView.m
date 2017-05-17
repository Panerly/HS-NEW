//
//  AlarmView.m
//  first
//
//  Created by HS on 2016/10/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "AlarmView.h"

@implementation AlarmView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, PanScreenWidth/2, PanScreenHeight/2);
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
