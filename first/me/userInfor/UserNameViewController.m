//
//  UserNameViewController.m
//  单读
//
//  Created by Macx on 16/2/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "UserNameViewController.h"

@interface UserNameViewController () {
    UITextView *text;
    NSUserDefaults *defaults;
}

@end

@implementation UserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改昵称";
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];

    self.navigationItem.rightBarButtonItem = saveBtn;
    
    //让顶部不留空白
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    text = [[UITextView alloc] initWithFrame:CGRectMake(10, 84, PanScreenWidth - 20, 150)];
    text.layer.cornerRadius = 8;
    text.font = [UIFont systemFontOfSize:20];
    text.layer.shadowColor = [[UIColor redColor] CGColor];
    text.layer.borderWidth = 2;
    text.layer.masksToBounds = YES;
    text.tag = 100;
    
    [self.view addSubview:text];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save {
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:text.text forKey:@"userNameValue"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
