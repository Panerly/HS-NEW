//
//  RepairHisVC.m
//  first
//
//  Created by panerly on 16/05/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "RepairHisVC.h"
#import "UIImage+GIF.h"

@interface RepairHisVC ()

@property (nonatomic, strong) UILabel *nomoreLabel;

@end

@implementation RepairHisVC

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [imgView setImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    [self.view addSubview:imgView];
    
    _nomoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 80)];
    
    _nomoreLabel.text       = @"暂无维修记录";
    
    _nomoreLabel.textColor  = [UIColor whiteColor];
    
    _nomoreLabel.textAlignment = NSTextAlignmentCenter;
    
    _nomoreLabel.alpha      = 0.5f;
    
    _nomoreLabel.center     = self.view.center;
    
    [self.view addSubview:_nomoreLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
