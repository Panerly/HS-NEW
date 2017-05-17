//
//  SettingTableViewCell.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _defaults = [NSUserDefaults standardUserDefaults];
    
    self.userImage.clipsToBounds = YES;
    self.userImage.layer.cornerRadius = 25;
    
    _imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    
    if (_imageData != nil) {
        _userImage.image = [NSKeyedUnarchiver unarchiveObjectWithData:_imageData];
    }
    if ([_defaults objectForKey:@"userNameValue"] != nil) {
        _userName.text = [_defaults objectForKey:@"userNameValue"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
