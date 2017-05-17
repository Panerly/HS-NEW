//
//  PayViewController.h
//  first
//
//  Created by HS on 16/8/2.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *money;
- (IBAction)payBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *moneyNum;
@property (weak, nonatomic) IBOutlet UILabel *createTime;

@end
