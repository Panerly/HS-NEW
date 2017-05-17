//
//  TableViewCell.h
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModel.h"

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *meter_id;

@property (weak, nonatomic) IBOutlet UILabel *user_id;

@property (nonatomic, strong) DBModel *DBModel;
@end
