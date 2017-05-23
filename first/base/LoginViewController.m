//
//  LoginViewController.m
//  first
//
//  Created by HS on 16/5/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LoginViewController.h"
#import "HSTabBarController.h"
#import "AFHTTPSessionManager.h"
#import "HyTransitions.h"
#import "HyLoglnButton.h"
#import "ConfigViewController.h"
//#import "KeychainItemWrapper.h"
#import "ListSelectView.h"

@interface LoginViewController ()<UIViewControllerTransitioningDelegate,UITextFieldDelegate>
{
    HyLoglnButton *logInButton;
    UIImageView *_hsLogoView;
    NSString *device;
//    KeychainItemWrapper *wrapper;
    NSString *notiUserName;
    NSString *notiPassWord;
    NSUserDefaults *defaults;
    ListSelectView *select_view;
}
@property (nonatomic, strong) NSMutableArray *selectTitles;
@property (nonatomic, strong) NSMutableArray *selectAreas;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImageView.image = [UIImage imageNamed:@"bg_weater2.jpg"];
    [self.view addSubview:bgImageView];
    
    _flag = 1;
    
    //    [self configKeyChainItemWrapper];
    
    //判断机型
    if (PanScreenHeight == 736) {//5.5
        device = @"6p";
    }
    else if (PanScreenHeight == 667) {//4.7
        device = @"6";
    }
    else if (PanScreenHeight == 568) {
        device = @"5";
    }
    else {
        device = @"4";
    }
    
    //创建杭水logo
    [self _createLogoImage];
    
    //监听键盘弹出的方式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    
    //创建登录btn
    [self _createLogBtn];
    
    if (!_selectAreas) {
        
        _selectAreas  = [NSMutableArray array];
        _selectTitles = [NSMutableArray array];
    }
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] isEqualToString:@"ok"]) {
        //成功进入
        [self performSelector:@selector(comeIn) withObject:self afterDelay:.1];
    }
}

- (void)comeIn {
    
    HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
    
    [self presentViewController:tabBarCtrl animated:YES completion:^{
        tabBarCtrl.modalPresentationStyle = UIModalPresentationPageSheet;
    }];
}
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.userName) {
        
        if ([textField.text isEqualToString:@"hzsb"]) {
            [UIView animateWithDuration:.5 animations:^{
                
                self.configBtn.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {

            }];
        }else{
            [UIView animateWithDuration:.5 animations:^{
                
                self.configBtn.transform = CGAffineTransformMakeScale(.01, .01);
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)_getCode
{
    self.passWord.text = [defaults objectForKey:@"passWord"];
    self.userName.text = [defaults objectForKey:@"userName"];
    NSLog(@"%@",[defaults objectForKey:@"ip"]?[defaults objectForKey:@"ip"]:@"123");
    self.ipLabel = [defaults objectForKey:@"ip"] == nil ? @"60.191.39.206:8000" : [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"] == nil ? @"bigmeter_water" : [defaults objectForKey:@"db"];
}

//- (void)configKeyChainItemWrapper
//{
//    wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"PassWordNumber" accessGroup:@"hzsb.com.hzsbcop.pan"];
//    
//    //取出密码
//    self.passWord.text = [wrapper objectForKey:(id)kSecValueData];
//    
//    //取出账号
//    self.userName.text = [wrapper objectForKey:(id)kSecAttrAccount];
//    
//    //清空设置
//    //    [wrapper resetKeychainItem];
//}

- (void)_createLogoImage
{
    _hsLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    if ([device isEqualToString:@"4"]) {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 30);
        
    }else if([device isEqualToString:@"6p"])
    {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 30);
    }
    else if ([device isEqualToString:@"6"])
    {
    _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
    _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 50);
    }
    else if ([device isEqualToString:@"5"])
    {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 50);
    }
    [self.view addSubview:_hsLogoView];
}

//int flag = 1;
- (void)popKeyBoard:(NSNotification *)notification
{
    //获取键盘的高度
    NSValue *value  = notification.userInfo[@"UIKeyboardBoundsUserInfoKey"];
    CGRect rect     = [value CGRectValue];
    CGFloat height  = rect.size.height;
    
    
    if (_flag == 1) {
        
        _flag+=2;

            if ([device isEqualToString:@"4"]) {
                _hsLogoView.transform = CGAffineTransformScale(_hsLogoView.transform, .5, .5);
                _hsLogoView.transform = CGAffineTransformTranslate(_hsLogoView.transform, 1, -50);

            }else
            {
                _hsLogoView.transform = CGAffineTransformScale(_hsLogoView.transform, .7, .7);
            }
    }
    // 调整View的高度
    [UIView animateWithDuration:0.25 animations:^{

        //调整布局
        _userBaseView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height/4-height+40);

        if ([device isEqualToString:@"4"]) {
            
        }
        if ([device isEqualToString:@"5"]) {
            
            logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - height - 70, PanScreenWidth - 40, 40);
            
        }else
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - height - 50, PanScreenWidth - 40, 40);
        
    }];
    
}

//创建登录按钮
- (void)_createLogBtn
{
    logInButton= [[HyLoglnButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    
    [logInButton setBackgroundColor:[UIColor colorWithRed:0 green:119/255.0f blue:204.0f/255.0f alpha:1]];
    
    [logInButton setTitle:@"登录" forState:UIControlStateNormal];
    
    [logInButton addTarget:self action:@selector(LoginBtn) forControlEvents:UIControlEventTouchUpInside];
    
    logInButton.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:logInButton];
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginVC"];
    }
    return self;
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    if (self.view.window == nil && [self isViewLoaded]) {
//        self.view = nil;
//    }
//}


//登录
- (IBAction)LoginBtn {
    
    
//#warning 测试用直接进入首页
//    __weak typeof(self) weakSelf = self;
//    HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
//    
//    tabBarCtrl.transitioningDelegate = self;
//    
//    [weakSelf presentViewController:tabBarCtrl animated:YES completion:^{
//        
//    }];
   
//    //保存账号
//    [wrapper setObject:self.passWord.text forKey:(id)kSecAttrAccount];
//    
//    //保存密码
//    [wrapper setObject:self.userName.text forKey:(id)kSecValueData];
    
    [UIView animateWithDuration:.25 animations:^{
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        
        _hsLogoView.transform   = CGAffineTransformIdentity;
        _userName.transform     = CGAffineTransformIdentity;
        _passWord.transform     = CGAffineTransformIdentity;
        _userBaseView.transform = CGAffineTransformIdentity;
        
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
        
    }];

    
    if (![self.userName.text isEqualToString:@""] && ![self.passWord.text isEqualToString:@""]) {//用户名密码不为空
        if ([self.userName.text isEqualToString:@"hzsb"] && [self.passWord.text isEqualToString:@"hzsb"]) {//检测室否是超级管理员
            if (self.ipLabel == nil || self.dbLabel == nil) {//管理员 但未配置
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"检测到管理员，请点击右上角配置按钮\n进行数据库和IP的配置" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:^{
                    
                }];
                [logInButton ErrorRevertAnimationCompletion:^{
                    
                }];
            }else{//管理员 、配置完成
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"db"] isEqualToString:@"bigmeter_chizhou"]) {//池州分区域
                    
                    [self requestArea];
                } else {
                    
                    [self logIn];
                }
            }
            
        }else{//非管理员
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"db"] isEqualToString:@"bigmeter_chizhou"]) {//池州分区域
                
                [self requestArea];
            } else {
                
                [self logIn];
            }
        }
        
    
    }else {//密码为空
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码为空！" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
        [logInButton ErrorRevertAnimationCompletion:^{
            
        }];
        
    }

}
//池州获取分区数据
- (void)requestArea {
    
    NSString *areaUrl = [NSString stringWithFormat:@"http://%@/waterweb/SelectareaServlet",self.ipLabel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{@"username":self.userName.text,
                                 @"password":self.passWord.text,
                                 @"db":self.dbLabel,
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    [self.selectTitles removeAllObjects];
    [self.selectAreas removeAllObjects];
    
    NSURLSessionTask *task = [manager POST:areaUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"列表：%@",responseObject);
        
        [weakSelf.selectTitles addObject:@"全部"];
        [weakSelf.selectAreas addObject:@"all"];
        
        for (NSDictionary *dic in responseObject) {
            
            if (![[dic objectForKey:@"flg"] isEqualToString:@"00"]) {
                
                [weakSelf.selectAreas addObject:[dic objectForKey:@"flg"]];
                [weakSelf.selectTitles addObject:[dic objectForKey:@"collector_area"]];
            }
            [weakSelf showListView:weakSelf.selectTitles];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"获取列表失败，失败信息：%@",error);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"列表获取失败" message:[NSString stringWithFormat:@"错误代码：%ld",error.code] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *retry = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf requestArea];
        }];
        
        [alert addAction:cancel];
        [alert addAction:retry];
        
    }];
    [task resume];
}

- (void)showListView:(NSMutableArray *)arr {
    
    if (!select_view) {
        
        select_view = [[ListSelectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    }
    
    select_view.choose_type     = MORECHOOSETITLETYPE;
    select_view.isShowCancelBtn = YES;
    select_view.isShowSureBtn   = NO;
    select_view.isShowTitle     = YES;
    
    
    __weak typeof(self) weakSelf = self;
    [select_view addTitleArray:arr andTitleString:@"请选择区域" animated:YES completionHandler:^(NSString * _Nullable string, NSInteger index) {
        
        [[NSUserDefaults standardUserDefaults] setObject:weakSelf.selectAreas[index] forKey:@"flg"];
        
        [weakSelf logIn];
    } withSureButtonBlock:^{
        
    }];
    [self.view addSubview:select_view];
}
//登录
- (void)logIn {
    
    if (select_view) {
        
        [select_view removeFromSuperview];
        select_view = nil;
    }
    
    //登录API 需传入的参数：用户名、密码、数据库名、IP地址
    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/Meter_Reading/S_Login_InfoServlet2",self.ipLabel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{@"username":self.userName.text,
                                 @"password":self.passWord.text,
                                 @"db":self.dbLabel,
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //用户名或密码错误
        if ([[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"test"] objectForKey:@"type"]] isEqualToString:@"0"]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:cancel];
            [weakSelf presentViewController:alert animated:YES completion:^{
                
            }];
            [logInButton ErrorRevertAnimationCompletion:^{
                
            }];
        }else if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"type"]] isEqualToString:@"302"]){//数据库配置错误
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据库配置错误！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
            
            [logInButton ErrorRevertAnimationCompletion:^{
                
            }];
            
        }else {//成功进入首页
            
            //保存用户名和密码
            
            [defaults setObject:weakSelf.userName.text forKey:@"userName"];
            
            [defaults setObject:weakSelf.passWord.text forKey:@"passWord"];
            
            [defaults setObject:@"ok" forKey:@"status"];
            
            [defaults setObject:[[responseObject objectForKey:@"test"] objectForKey:@"type"] forKey:@"type"];
            
            [defaults setObject:[[responseObject objectForKey:@"test"] objectForKey:@"collector_area"] forKey:@"collector_area"];
            
            [defaults setObject:[[responseObject objectForKey:@"test"] objectForKey:@"xqbh"] forKey:@"xqbh"];
            
            [defaults setObject:[[responseObject objectForKey:@"test"] objectForKey:@"find_purview"] forKey:@"find_purview"];
            
            
            [defaults setObject:[[responseObject objectForKey:@"sing"] objectForKey:@"area_list"] forKey:@"area_list"];
            
            [defaults setObject:[[responseObject objectForKey:@"sing"] objectForKey:@"meter_cali_list"] forKey:@"meter_cali_list"];
            
            [defaults setObject:[[responseObject objectForKey:@"sing"] objectForKey:@"meter_name_list"] forKey:@"meter_name_list"];
            
            [defaults setObject:[[responseObject objectForKey:@"sing"] objectForKey:@"sb_type_list"] forKey:@"sb_type_list"];
            
            [defaults setObject:[[responseObject objectForKey:@"sing"] objectForKey:@"type_list"] forKey:@"type_list"];
            
            [defaults synchronize];
            
            //成功进入
            [logInButton ExitAnimationCompletion:^{
                
                HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
                
                tabBarCtrl.transitioningDelegate = self;
                
                [weakSelf presentViewController:tabBarCtrl animated:YES completion:^{
                    tabBarCtrl.modalPresentationStyle = UIModalPresentationPageSheet;
                }];
                
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1001) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登陆失败" message:@"请求超时" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:cancel];
            [weakSelf presentViewController:alert animated:YES completion:^{
                
            }];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登陆失败" message:[NSString stringWithFormat:@"%@",error] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [weakSelf presentViewController:alert animated:YES completion:^{
            
        }];
        [logInButton ErrorRevertAnimationCompletion:^{
            
        }];
    }];
    
    
    [task resume];
    
}


////登录大表
//- (void)logBigMeter {
//    
//    //登录API 需传入的参数：用户名、密码、数据库名、IP地址
//    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/LoginServlet",self.ipLabel];
//    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
//    manager.requestSerializer.timeoutInterval = 10;
//    
//    NSDictionary *parameters = @{@"username":self.userName.text,
//                                 @"password":self.passWord.text,
//                                 @"db":self.dbLabel,
//                                 };
//    
//    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
//    
//    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    
//    __weak typeof(self) weakSelf = self;
//    
//    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        //用户名或密码错误
//        if ([[responseObject objectForKey:@"type"] isEqualToString:@"0"]) {
//            
//            [self logLitMeter];
//            
//            //数据库配置错误
//        }else if ([[responseObject objectForKey:@"type"] isEqualToString:@"404"]) {
//            
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据库配置错误！" preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
//            
//            [logInButton ErrorRevertAnimationCompletion:^{
//                
//            }];
//        }
//        
//        //成功进入首页
//        else {
//            
//            //保存用户名和密码
//            
//            [defaults setObject:weakSelf.userName.text forKey:@"userName"];
//            
//            [defaults setObject:weakSelf.passWord.text forKey:@"passWord"];
//            
//            [defaults setObject:[responseObject objectForKey:@"type"] forKey:@"type"];
//            
//            [defaults setObject:[responseObject objectForKey:@"area_list"] forKey:@"area_list"];
//            
//            [defaults setObject:[responseObject objectForKey:@"meter_cali_list"] forKey:@"meter_cali_list"];
//            
//            [defaults setObject:[responseObject objectForKey:@"meter_name_list"] forKey:@"meter_name_list"];
//            
//            [defaults setObject:[responseObject objectForKey:@"sb_type_list"] forKey:@"sb_type_list"];
//            
//            [defaults setObject:[responseObject objectForKey:@"type_list"] forKey:@"type_list"];
//            
//            [defaults synchronize];
//            
//            [self logLitMeter];
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
////        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
////            
////        }];
////        if (error.code == -1004) {
////            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"未能连接到服务器!" preferredStyle:UIAlertControllerStyleAlert];
////            
////            [alertVC addAction:action];
////            [self presentViewController:alertVC animated:YES completion:^{
////                
////            }];
////        }
////        if (error.code == -1001) {
////            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录超时!" preferredStyle:UIAlertControllerStyleAlert];
////            
////            [alertVC addAction:action];
////            [self presentViewController:alertVC animated:YES completion:^{
////                
////            }];
////        } else if (error.code == 3840){
////            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"配置错误!" preferredStyle:UIAlertControllerStyleAlert];
////            
////            [alertVC addAction:action];
////            [self presentViewController:alertVC animated:YES completion:^{
////                
////            }];
////            
////        }else {
////            
////            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败!" preferredStyle:UIAlertControllerStyleAlert];
////            
////            [alertVC addAction:action];
////            [self presentViewController:alertVC animated:YES completion:^{
////                
////            }];
////        }
//        
////        [logInButton ErrorRevertAnimationCompletion:^{
////            
////        }];
//        [self logLitMeter];
//    }];
//    
//    [task resume];
//
//}
//
//#pragma mark - login litmeter 大表登录检测后登录小表
//- (void)logLitMeter {
//    /*
//    // 1.初始化
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    // 2.设置证书模式
//    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"AddTrust External CA Root" ofType:@"cer"];
//    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
//    NSLog(@"%@",cerPath);
//    
//    if (cerPath) {
//     
//        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone withPinnedCertificates:[[NSSet alloc] initWithObjects:cerData, nil]];
//        // 客户端是否信任非法证书
//        manager.securityPolicy.allowInvalidCertificates = YES;
//        // 是否在证书域字段中验证域名
//        [manager.securityPolicy setValidatesDomainName:NO];
//    }
//    
//    [manager POST:@"http://www.hzsbgs.com:8888/scinf/gyd2?time=2016_11_24_14_49_27" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//     
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//     
//        NSLog(@"%@",responseObject);
//     
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//     
//        NSLog(@"%@",error);
//     
//    }];*/
//    
//    //登录API 需传入的参数：用户名、密码、数据库名、IP地址
//    NSString *logInUrl                  = [NSString stringWithFormat:@"%@/Meter_Reading/S_Login_InfoServlet",litMeterApi];
//    
//    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
//    
//    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
//    manager.requestSerializer.timeoutInterval = 10;
//    
//    NSDictionary *parameters = @{@"name":self.userName.text,
//                                 @"pwd":self.passWord.text,
//                                 };
//    
//    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
//    
//    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    
//    __weak typeof(self) weakSelf = self;
//    
//    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
////        NSLog(@"登录返回字段：%@",responseObject);
//        if ([responseObject objectForKey:@"type"]) {
//            
//            if ([[responseObject objectForKey:@"type"] isEqualToString:@"0"]) {
//                
//                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码错误！" preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }];
//                
//                [alertVC addAction:action];
//                [self presentViewController:alertVC animated:YES completion:^{
//                    
//                }];
//                
//                [logInButton ErrorRevertAnimationCompletion:^{
//                    
//                }];
//            }
//            else {//小表登录成功
//                //保存用户名和密码
//                
//                [defaults setObject:weakSelf.userName.text forKey:@"userName"];
//                
//                [defaults setObject:weakSelf.passWord.text forKey:@"passWord"];
//                
//                [defaults setObject:[responseObject objectForKey:@"find_purview"] forKey:@"find_purview"];
//                
//                [defaults setObject:[responseObject objectForKey:@"xqbh"] forKey:@"xqbh"];
//                
//                [defaults synchronize];
//                
//                //成功进入
//                [logInButton ExitAnimationCompletion:^{
//                    
//                    HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
//                    
//                    tabBarCtrl.transitioningDelegate = self;
//                    
//                    [weakSelf presentViewController:tabBarCtrl animated:YES completion:^{
//                        tabBarCtrl.modalPresentationStyle = UIModalPresentationPageSheet;
//                    }];
//                    
//                }];
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        if (error.code == -1004) {
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"未能连接到服务器!" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
//        }
//        if (error.code == -1001) {
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录超时!" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
//        }else {
//            
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败!" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
//        }
//        
//        [logInButton ErrorRevertAnimationCompletion:^{
//            
//        }];
//    }];
//    [task resume];
//}

//touch返回原态
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _flag = 1;
    [UIView animateWithDuration:.25 animations:^{
        
        _hsLogoView.transform   = CGAffineTransformIdentity;
        _userName.transform     = CGAffineTransformIdentity;
        _passWord.transform     = CGAffineTransformIdentity;
        _userBaseView.transform = CGAffineTransformIdentity;
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
    }];
}

//视图出现前准备好密码、布局还原
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    //判断是否登录了
//    NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
//    
//    if ([[defaults1 objectForKey:@"login_status"] isEqualToString:@"ok"]) {
//        
//        HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
//        
//        tabBarCtrl.transitioningDelegate = self;
//        
//        [self presentViewController:tabBarCtrl animated:YES completion:^{
//            
//            tabBarCtrl.modalPresentationStyle = UIModalPresentationPageSheet;
//        }];
//    }
    if (!self.userBaseView) {
        self.userBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 150)];
        [self.view addSubview:self.userBaseView];
        [self.userBaseView addSubview:self.userName];
        [self.userBaseView addSubview:self.userImage];
        [self.userBaseView addSubview:self.passWord];
        [self.userBaseView addSubview:self.passWordImage];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self _getCode];
    
    _userName.delegate = self;
    _passWord.delegate = self;
    _userName.returnKeyType = UIReturnKeyNext;
    _passWord.returnKeyType = UIReturnKeyDone;
    
    _flag = 1;
    [UIView animateWithDuration:.25 animations:^{
        
        _hsLogoView.transform       = CGAffineTransformIdentity;
        _userName.transform         = CGAffineTransformIdentity;
        _passWord.transform         = CGAffineTransformIdentity;
        _userBaseView.transform     = CGAffineTransformIdentity;
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
    }];
    if ([self.userName.text isEqualToString:@"hzsb"]) {
        [UIView animateWithDuration:.5 animations:^{
            
            self.configBtn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:.5 animations:^{
            
            self.configBtn.transform = CGAffineTransformMakeScale(.01, .01);
        } completion:^(BOOL finished) {
            
        }];
    }
    //监听输入内容，判断是否显示配置选项
    [self.userName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.5f isBOOL:true];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.8f isBOOL:false];
}
- (IBAction)configBtn:(id)sender {
    
    ConfigViewController *configVC = [[ConfigViewController alloc] init];
    [self presentViewController:[[ConfigViewController alloc] init] animated:YES completion:^{
        [configVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    }];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_userName resignFirstResponder];
        [_passWord becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        //用户结束输入
        [textField resignFirstResponder];
        _flag = 1;
        [UIView animateWithDuration:.25 animations:^{
            
            _hsLogoView.transform   = CGAffineTransformIdentity;
            _userName.transform     = CGAffineTransformIdentity;
            _passWord.transform     = CGAffineTransformIdentity;
            _userBaseView.transform = CGAffineTransformIdentity;
            
            logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
            [_passWord resignFirstResponder];
            [_userName resignFirstResponder];
        }];
    }
    
    return YES;
}



@end
