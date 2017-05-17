//
//  LoginViewController.h
//  first
//
//  Created by HS on 16/5/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *userBaseView;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *passWordImage;
@property (strong, nonatomic) IBOutlet UIView *underlineView;
@property (weak, nonatomic) IBOutlet UIView *underlineView2;

@property (nonatomic, strong) UINavigationController *navi;

@property (nonatomic, strong) NSString *ipLabel;
@property (nonatomic, strong) NSString *dbLabel;

@property (nonatomic, assign) int flag;

- (IBAction)configBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *configBtn;

@end
