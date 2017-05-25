//
//  SettingViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "UserInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "RepairHisVC.h"


@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *identy;
    NSString *userIdenty;
    NSUInteger fileSize;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    [bgView setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
//    [self.view addSubview:bgView];
//
//    UIVisualEffectView *effectView;
//    if (!effectView) {
//        effectView = [[UIVisualEffectView alloc] initWithFrame:self.view.frame];
//    }
//    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    [self.view addSubview:effectView];
    
    self.view.backgroundColor = COLORRGB(238, 238, 238);
    
    [self _createTableView];
    
    [self _createVersion];
    
    [self setLogOutBtn];
}

-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle        = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barTintColor    = COLORRGB(226, 107, 16);
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)_createVersion {
    
    UIButton *versionBtn = [[UIButton alloc] initWithFrame:CGRectMake((PanScreenWidth-200)/2, PanScreenHeight - 49 -50, 200, 40)];
    [versionBtn setTitle:@"版本：V1.2.3" forState:UIControlStateNormal];
    [versionBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [versionBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [versionBtn addTarget:self action:@selector(versionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:versionBtn];
}

//版本更新内容
- (void)versionAction {
    
    NSString *versionData = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"versionData"]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本提示" message:versionData preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)setLogOutBtn {
    
    UIButton *logOutBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, PanScreenHeight - 49 - 50 - 40, PanScreenWidth - 20 * 2, 40)];
    [logOutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    [logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    logOutBtn.clipsToBounds         = YES;
    logOutBtn.layer.cornerRadius    = 20;
    logOutBtn.backgroundColor       = [UIColor redColor];
    logOutBtn.titleLabel.textColor  = [UIColor blackColor];
    [self.view addSubview:logOutBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    fileSize = [[SDImageCache sharedImageCache] getDiskCount];
    
    [_tableView reloadData];
    
    [self setNavColor];
}

- (void)_createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStyleGrouped];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    
    userIdenty  = @"userIdenty";
    identy      = @"logoutIdenty";
    
    _tableView.scrollEnabled    = NO;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:_tableView];
}


#pragma UITableView DataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
    }else {
        
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 2) {
//        return PanScreenWidth/3;
//    }
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"账户设置";
    }
    else if (section == 1) {
        return @"缓存";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:userIdenty];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (!userCell) {
            
            userCell = [[[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:self options:nil] lastObject];
            
//            UIVisualEffectView *effectView;
//            if (!effectView) {
//                effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, userCell.frame.size.height)];
//            }
//            effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            
            userCell.backgroundColor = [UIColor whiteColor];
//            [userCell insertSubview:effectView belowSubview:userCell.contentView];
        }
        return userCell;
    }

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        UIImageView *cleanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreClear"]];
        
        cleanImageView.frame = CGRectMake(10, (50-30)/2, 28, 28);
        
        [cell addSubview:cleanImageView];
        
        UILabel *cleanLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, (50-30)/2, 100, 30)];
        
        cleanLabel.text = @"清理缓存";
        
        cleanLabel.textColor = [UIColor blackColor];
        
        cleanLabel.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:cleanLabel];
        
        return cell;
    }
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"find_purview"] isEqualToString:@"00"]){//管理员查看维修记录
//        
//    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        UITableViewCell *repairsHisCell = [[UITableViewCell alloc] init];
        
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        UIImageView *repairImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_repairHis@2x"]];
        
        repairImageView.frame = CGRectMake(10, (50-30)/2, 28, 28);
        
        [repairsHisCell addSubview:repairImageView];
        
        UILabel *repairLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, (50-30)/2, 100, 30)];
        
        repairLabel.text = @"维修历史";
        
        repairLabel.textColor = [UIColor blackColor];
        
        repairLabel.textAlignment = NSTextAlignmentLeft;
        
        [repairsHisCell addSubview:repairLabel];
        
        return repairsHisCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        
        userInfoVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController showViewController:userInfoVC sender:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (fileSize/1024.0/1024.0 > 0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清理缓存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[SDImageCache sharedImageCache] cleanDisk];
                
                fileSize = [[SDImageCache sharedImageCache] getDiskCount];
                
                [self.tableView reloadData];
                
                [SCToastView showInView:self.view text:@"已清理" duration:.5f autoHide:YES];
            }];
            
            [alert addAction:cancel];
            [alert addAction:confirm];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        } else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无缓存可清除！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
           
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];

        }
        
        
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        RepairHisVC *repairHisVC = [[RepairHisVC alloc] init];
        
        repairHisVC.title = @"维修记录";
        
        repairHisVC.view.backgroundColor = [UIColor whiteColor];
        
        repairHisVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController showViewController:repairHisVC sender:nil];
    }
//    if (indexPath.section == 1 && indexPath.row == 1){
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本提示" message:@"1. 修正历史抄见用量提示，修正流量单位\n2.延长统计显示时长\n3.优化体验\n4.修正小表数据\n5.BUG反馈群：QQ群:511584754" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//        
//        [alert addAction:cancel];
//        
//        [self presentViewController:alert animated:YES completion:^{
//            
//        }];
//        
//    }
//    if (indexPath.section == 1 && indexPath.row == 3) {
//        /**
//         *  退出登出
//         *
//         *  @param logOut 登出
//         *
//         *  @return 退回至登录界面
//         */
//        [self performSelector:@selector(logOut) withObject:nil afterDelay:0.01];
//        
//    }
}
- (void)logOut {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"no" forKey:@"status"];
    
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
@end
