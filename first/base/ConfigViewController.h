//
//  ConfigViewController.h
//  first
//
//  Created by HS on 16/5/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConfigViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *IPConfigLabel;
@property (weak, nonatomic) IBOutlet UILabel *DBCofigLabel;

//- (IBAction)ConpleteBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *IPConfig;
@property (weak, nonatomic) IBOutlet UITextField *DBConfig;
- (IBAction)saveBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;
- (IBAction)userCountBtn:(id)sender;
@property (nonatomic, strong) UIPickerView *pickerView;

@end
