//
//  FlowLayout.m
//  first
//
//  Created by HS on 16/7/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "FlowLayout.h"

@implementation FlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(PanScreenWidth, PanScreenHeight);
        self.minimumLineSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
    }
    return self;
}
@end
