//
//  DetailViewController.m
//  first
//
//  Created by HS on 16/6/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "DetailViewController.h"
#import "QueryViewController.h"
#import "DetailModel.h"
#import "AMWaveTransition.h"
#import "TZPopInputView.h"

@interface DetailViewController ()<UINavigationControllerDelegate>
{
    NSString *userNameLabel;
    NSString *passWordLabel;
    NSString *userName2;
    NSString *ipLabel;
    NSString *dbLabel;
}
@property (strong, nonatomic) AMWaveTransition *interactive;
@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框

@end

@implementation DetailViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTransition invalidate];
    
    self.reportBtn.hidden = YES;
    self.reportBtn.clipsToBounds = YES;
    self.reportBtn.layer.cornerRadius = 5;
    
    [self _requestData];
    
    [self _setValue];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    _interactive = [[AMWaveTransition alloc] init];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"返回";
    backItem.tintColor = [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
    
    if (!_inputView) {
        
        self.inputView = [[TZPopInputView alloc] init];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.interactive detachInteractiveGesture];
}

- (void)_setValue
{
    self.title = self.titleName;
//    self.netNum.text = [NSString stringWithFormat:@"网络编号:   %@", self.crModel.meter_name2];
    self.userNum.text = [NSString stringWithFormat:@"用户号:   %@", self.crModel.meter_id];
    
    self.userName.text = [NSString stringWithFormat:@"用户名:   %@", self.crModel.meter_name];
    self.userAddr.text = [NSString stringWithFormat:@"用户地址:   %@", self.crModel.meter_user_addr];
    self.caliber.text = [NSString stringWithFormat:@"口径:   %@", self.crModel.meter_cali];
    self.meterPhenoType.text = [NSString stringWithFormat:@"表类型:   %@",self.crModel.meter_name2];
    self.readingTime.text = [NSString stringWithFormat:@"抄表时间:   %@",self.crModel.collect_dt];
    self.degrees.text = [NSString stringWithFormat:@"抄见度数:   %@吨", self.crModel.collect_num];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _userNum.transform = CGAffineTransformMakeScale(.1, .1);
    _meterNum.transform = CGAffineTransformMakeScale(.1, .1);
    _userName.transform = CGAffineTransformMakeScale(.1, .1);
    _userAddr.transform = CGAffineTransformMakeScale(.1, .1);
    _caliber.transform = CGAffineTransformMakeScale(.1, .1);
    _meterPhenoType.transform = CGAffineTransformMakeScale(.1, .1);
    _readingTime.transform = CGAffineTransformMakeScale(.1, .1);
    _degrees.transform = CGAffineTransformMakeScale(.1, .1);
    _netNum.transform = CGAffineTransformMakeScale(.1, .1);
    _alarm.transform = CGAffineTransformMakeScale(.1, .1);
    
    [UIView animateWithDuration:.5 animations:^{
        _userAddr.transform = CGAffineTransformIdentity;
        _userName.transform = CGAffineTransformIdentity;
        _userNum.transform = CGAffineTransformIdentity;
        _meterNum.transform = CGAffineTransformIdentity;
        _caliber.transform = CGAffineTransformIdentity;
        _meterPhenoType.transform = CGAffineTransformIdentity;
        _readingTime.transform = CGAffineTransformIdentity;
        _degrees.transform = CGAffineTransformIdentity;
        _netNum.transform = CGAffineTransformIdentity;
        _alarm.transform = CGAffineTransformIdentity;
    }];
}

- (void)_requestData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    userNameLabel = [defaults objectForKey:@"userName"];
    passWordLabel = [defaults objectForKey:@"passWord"];
    ipLabel = [defaults objectForKey:@"ip"];
    dbLabel = [defaults objectForKey:@"db"];
    userName2 = self.crModel.meter_id;
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/servlet/JsonServlet",ipLabel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSDictionary *parameters = @{
                                 @"username":userName2,
                                 @"password":passWordLabel,
                                 @"db":dbLabel,
                                 @"username2":userNameLabel
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            NSDictionary *dic = [responseObject objectForKey:@"meter1"];
            
            if ([dic objectForKey:@"comm_id"]) {
                
                weakSelf.netNum.text = [NSString stringWithFormat:@"网络编号:   %@", [dic objectForKey:@"comm_id"]];
            }else{
                
                weakSelf.netNum.text = [NSString stringWithFormat:@"网络编号:   N/A"];
            }
            if ([dic objectForKey:@"alarm"]) {
                
                weakSelf.alarm.text = [NSString stringWithFormat:@"警报:   %@", [dic objectForKey:@"alarm"]];
                
                if (![[dic objectForKey:@"alarm"] isEqualToString:@"无"]) {
                    
                    weakSelf.reportBtn.hidden = NO;
                }
            }else{
                
                weakSelf.alarm.text = [NSString stringWithFormat:@"警报:   N/A"];
            }
            if ([responseObject objectForKey:@"user_id"]) {
                
                NSString *specialID = [[NSUserDefaults standardUserDefaults] objectForKey:@"collector_area"];
                if ([specialID isEqualToString:@"32"]) {//长春水务令改
                    
                    weakSelf.meterNum.text = [NSString stringWithFormat:@"长水号:   %@", [responseObject objectForKey:@"user_id"]];
                }else{
                    
                    weakSelf.meterNum.text = [NSString stringWithFormat:@"水表号:   %@", [responseObject objectForKey:@"user_id"]];
                }
            }else{
                
                weakSelf.meterNum.text = [NSString stringWithFormat:@"水表号:   N/A"];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        
    }];
    
    [task resume];
}

- (IBAction)showDetailData:(UISwipeGestureRecognizer *)sender {
    
    QueryViewController *queryVC = [[QueryViewController alloc] init];
    queryVC.meter_id             = self.crModel.meter_id;
    
    queryVC.manageMeterNumValue = self.crModel.meter_id;
    queryVC.meterTypeValue      = self.crModel.meter_name2;
    
    //此处将通讯方式修改为口径
    queryVC.communicationTypeValue = self.crModel.meter_cali;
    queryVC.installAddrValue       = self.crModel.meter_user_addr;

    [self.navigationController showViewController:queryVC sender:nil];
    
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        return [AMWaveTransition transitionWithOperation:operation];
    }
    return nil;
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
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

- (IBAction)reportAction:(id)sender {
    
    
    self.inputView.titleLable.text = @"报修信息";
    [self.inputView setItems:@[@"报修原因",@"联系方式"]];
    
    [self.inputView show];
    
    self.inputView.textFiled1.placeholder = @"请输入";
    self.inputView.textFiled2.placeholder = @"请输入";
    
    __weak typeof(self) weakSelf = self;
    
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        [weakSelf.inputView hide];
        
    };
}
@end
