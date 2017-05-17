//
//  SettingTableViewCell.h
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingModel.h"

@interface SettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (nonatomic, strong) SettingModel *settingModel;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSUserDefaults *defaults;
@end
