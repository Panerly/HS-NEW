//
//  CurrentReceiveTableViewCell.h
//  first
//
//  Created by HS on 16/6/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRModel.h"

@interface CurrentReceiveTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (nonatomic, strong) CRModel *CRModel;

- (IBAction)naviButton:(id)sender;
- (IBAction)scenePhotos:(id)sender;

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;
@property (nonatomic, strong) NSString *userNameStr;

@end
