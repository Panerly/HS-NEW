//
//  CompleteTableViewCell.h
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompleteModel.h"

@interface CompleteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *user_id;

@property (weak, nonatomic) IBOutlet UILabel *meter_id;

@property (weak, nonatomic) IBOutlet UILabel *collect_time;


@property (weak, nonatomic) IBOutlet UIImageView *compImage;

@property (nonatomic, strong) CompleteModel *completeModel;

//- (IBAction)upload:(id)sender;

@property (nonatomic, strong) NSString *click;

@end
