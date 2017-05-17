//
//  NewHomeViewController.m
//  first
//
//  Created by HS on 15/03/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "NewHomeViewController.h"
#import "TLCityPickerController.h"
#import "UIImage+GIF.h"

//判定方向距离
#define touchDistance 100
//偏移
#define touchPy 10

#define widthPix PanScreenWidth/320
#define heightPix PanScreenHeight/568

@interface NewHomeViewController ()<CLLocationManagerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSDictionary *areaidDic;

@property (assign) CGPoint beginPoint;
@property (assign) CGPoint movePoint;


@property (nonatomic, strong) UIImageView  *backgroudView;
//多云动画
@property (nonatomic, strong) NSMutableArray *imageArr;//鸟图片数组
@property (nonatomic, strong) UIImageView *birdImage;//鸟本体
@property (nonatomic, strong) UIImageView *birdRefImage;//鸟倒影
@property (nonatomic, strong) UIImageView *cloudImageViewF;//云
@property (nonatomic, strong) UIImageView *cloudImageViewS;//云
//晴天动画
@property (nonatomic, strong) UIImageView *sunImage;//太阳
@property (nonatomic, strong) UIImageView *sunshineImage;//太阳光
@property (nonatomic, strong) UIImageView *sunCloudImage;//晴天云
//雨天动画
@property (nonatomic, strong) UIImageView *rainCloudImage;//乌云
@property (nonatomic, strong) NSArray *jsonArray;

@end

@implementation NewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitleLabel];
    
    [self setScroll];
    
//    [self setNavColor];//设置导航栏颜色
    
    [self _requestWeatherData:@"杭州"];
    
    //适配4寸
    if (PanScreenWidth == 320) {
        
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];
        
    }
    [self createBackgroundView];
    
    //检测升级
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue= dispatch_queue_create("checkVersion.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        [weakSelf checkVersion];
    });
    
    // 设置导航控制器的代理为self
    self.navigationController.delegate = self;
}

//创建背景视图
- (void)createBackgroundView {
    
    self.backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_bg"]];
    _backgroudView.frame = self.view.bounds;
    //[self.view addSubview:self.backgroudView];
    [self.view insertSubview:self.backgroudView atIndex:0];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

-(void)checkVersion
{
    NSString *newVersion;
    NSString *newVersionData;
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/cn/lookup?id=1193445551"];//这个URL地址是该app在iTunes connect里面的相关配置信息。其中id是该app在app store唯一的ID编号。
    NSString *jsonResponseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [jsonResponseString dataUsingEncoding:NSUTF8StringEncoding];
    
    //    解析json数据
    if (nil != data) {
        
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *array = json[@"results"];
        
        for (NSDictionary *dic in array) {
            
            newVersion = [dic valueForKey:@"version"];
            newVersionData = [dic valueForKey:@"releaseNotes"];
        }
        
        [self compareVesionWithServerVersion:newVersion newData:newVersionData];
    }
    
    
    
}

-(BOOL)compareVesionWithServerVersion:(NSString *)version newData:(NSString *)newData{
    
    NSArray *versionArray = [version componentsSeparatedByString:@"."];//服务器返回版
    //获取本地软件的版本号
    NSString *APP_VERSION = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *currentVesionArray = [APP_VERSION componentsSeparatedByString:@"."];//当前版本
    NSInteger a = (versionArray.count> currentVesionArray.count)?currentVesionArray.count : versionArray.count;
//    NSLog(@"当前版本：%@ ---appstoreVersion:%@",currentVesionArray, versionArray);
    
    for (int i = 0; i< a; i++) {
        int new = [[versionArray objectAtIndex:i] intValue];
        int now = [[currentVesionArray objectAtIndex:i] intValue];
        if (new > now) {//appstore版本大于当前版本，提示更新
            NSLog(@"有新版本 new%ld-----now%ld", (long)new, (long)now);
            NSString *msg = [NSString stringWithFormat:@"%@",newData];
            [[NSUserDefaults standardUserDefaults] setObject:msg forKey:@"versionData"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            UIView *subView1 = alert.view.subviews[0];
            UIView *subView2 = subView1.subviews[0];
            UIView *subView3 = subView2.subviews[0];
            UIView *subView4 = subView3.subviews[0];
            UIView *subView5 = subView4.subviews[0];
            //取title和message：
            UILabel *message = subView5.subviews[1];
            //然后设置message内容居左：
            message.textAlignment = NSTextAlignmentLeft;
            
            
            [alert addAction:[UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/hang-zhou-shui-biao/id1193445551?l=en&mt=8"]];//这里写的URL地址是该app在app store里面的下载链接地址，其中ID是该app在app store对应的唯一的ID编号。
                NSLog(@"点击现在升级按钮");
            }]];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [cancelAction setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            return YES;
        }else if (new < now){//appStore版本小于当前版本
            return YES;
        }
    }
    return NO;
}

- (void)modifyConstant {
    
    self.weatherTodayImageViewWidth.constant = 120;
    self.weatherTodayImageViewHeight.constant = 100;
}

- (void)setTitleLabel {
    
    UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [titleLabel setText:@"移动互联抄表系统"];
    self.navigationItem.titleView = titleLabel;
}

- (void)setScroll {
    
    self.scrollView.contentSize = CGSizeMake(500, 0);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
}

/**
 *  设置导航栏的颜色，返回按钮和标题为白色
 */
-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle        = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barTintColor    = COLORRGB(81, 174, 220);
//    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navi"]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self  = [[UIStoryboard storyboardWithName:@"NewHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NewHome"];
    }
    return self;
}
- (IBAction)selectCity:(id)sender {
    
    self.selectCityBtn.showsTouchWhenHighlighted = YES;
    __weak typeof(self)weakSelf = self;
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"选择城市",@"当前城市",@"刷新"] imageArray:@[@"icon_city",@"icon_loca",@"icon_refresh"] doneBlock:^(NSInteger selectedIndex) {
        
        if (selectedIndex == 0) {
            
            TLCityPickerController *cityPickerVC = [[TLCityPickerController alloc] init];
            
            [cityPickerVC setDelegate:(id)weakSelf];
            
            cityPickerVC.locationCityID  = [weakSelf transCityNameIntoCityCode:weakSelf.cityLabel.text];
            
//            cityPickerVC.commonCitys     = [[NSMutableArray alloc] initWithArray: @[@"1400010000", @"100010000"]];        // 最近访问城市，如果不设置，将自动管理
            cityPickerVC.hotCitys        = @[@"100010000", @"200010000", @"300210000", @"600010000", @"300110000",@"2000010000"];
            
            [weakSelf presentViewController:[[UINavigationController alloc] initWithRootViewController:cityPickerVC] animated:YES completion:^{
                
            }];
            
            
        }else if (selectedIndex == 1) {
            
            [weakSelf locationCurrentCity];
        }else if (selectedIndex == 2) {
            
            [weakSelf _requestWeatherData:weakSelf.cityLabel.text];
        }
        
    } dismissBlock:^{
        
    }];
}

//请求天气信息
- (void)_requestWeatherData:(NSString *)cityName
{
    self.cityLabel.text   = [NSString stringWithFormat:@"%@",cityName];
    
    [self loadingInfo];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSString *cityNameStr             = [self transform:cityName];
    
    NSString *replacedCityNameStr     = [cityNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpArg                 = [NSString stringWithFormat:@"city=%@",replacedCityNameStr];
    
    
    NSMutableURLRequest *requestHistory  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",weatherAPI,httpArg]]];
    requestHistory.HTTPMethod = @"GET";
    
    requestHistory.timeoutInterval       = 10;
    
    [requestHistory addValue:weatherAPIkey forHTTPHeaderField:@"apikey"];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes    = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf         = self;
    
    NSURLSessionTask *hisTask = [manager dataTaskWithRequest:requestHistory uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        if (error) {
            NSLog(@"错误信息：%@",error);
        }
        
        if (responseObject) {
            
            if ([responseObject objectForKey:@"HeWeather data service 3.0"] ) {
                
                [SVProgressHUD showInfoWithStatus:@"加载成功"];
                
                NSDictionary *responseDic = [responseObject objectForKey:@"HeWeather data service 3.0"];
                
                for (NSDictionary *arr in responseDic) {
                    
                    if ([[arr objectForKey:@"status"] isEqualToString:@"unknown city"]) {
                        [SVProgressHUD showErrorWithStatus:@"未知或错误城市"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"invalid key"]){
                        [SVProgressHUD showErrorWithStatus:@"错误的key"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"no more requests"]){
                        [SVProgressHUD showErrorWithStatus:@"超过访问次数"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"param invalid"]){
                        [SVProgressHUD showErrorWithStatus:@"参数错误"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"vip over"]){
                        [SVProgressHUD showErrorWithStatus:@"付费账号过期"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"anr"]){
                        [SVProgressHUD showErrorWithStatus:@"无响应或超时"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"permission denied"]){
                        [SVProgressHUD showErrorWithStatus:@"无访问权限"];
                        [weakSelf weatherLoadfailed];
                    }else if ([[arr objectForKey:@"status"] isEqualToString:@"ok"]){
                        
                        //风力
                        weakSelf.windDirLabel.text     = [NSString stringWithFormat:@"%@",[[[arr objectForKey:@"now"] objectForKey:@"wind"] objectForKey:@"dir"]];
                        //湿度
                        weakSelf.hunLabel.text = [NSString stringWithFormat:@"%@％",[[arr objectForKey:@"now"] objectForKey:@"hum"]];
                        //降水概率
                        weakSelf.popLabel.text = [NSString stringWithFormat:@"%@％", [[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"pop"]];
                        //现在温度
                        weakSelf.tmpLabel.text          = [NSString stringWithFormat:@"%@",[[arr objectForKey:@"now"] objectForKey:@"tmp"]];
                        //最高温度
                        weakSelf.maxTmpLabel.text = [NSString stringWithFormat:@"%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max" ]];
                        //最低温度
                        weakSelf.minTmpLabel.text = [NSString stringWithFormat:@"%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"]];
                        //更新时间
                        weakSelf.updateLabel.text              = [NSString stringWithFormat:@"%@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]];
                        //风力
                        weakSelf.windDirLabel.text    = [NSString stringWithFormat:@"%@级",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"wind"] objectForKey:@"sc"]];
                        //未来一周天气
                        weakSelf.day1TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day2TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day3TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day4TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day5TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day6TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day7TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        
                        //未来一周时间
                        weakSelf.day1Label.text  = [weakSelf GetTime:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]]];
                        
                        weakSelf.day2Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"date"]]];
                        
                        weakSelf.day3Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"date"]]];
                        
                        weakSelf.day4Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"date"]]];
                        
                        weakSelf.day5Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"date"]]];
                        
                        weakSelf.day6Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"date"]]];
                        
                        weakSelf.day7Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"date"]]];
                        
                        weakSelf.day1WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        
                        [weakSelf addAnimationWithType:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        
                        weakSelf.day2WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day3WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day4WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day5WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day6WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day7WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        
//                        weakSelf.weatherTodayImageView.image = [UIImage sd_animatedGIFNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];//动画天气图标
                        weakSelf.weatherTodayImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                    }
                }
                
                CATransition *transition = [[CATransition alloc] init];
                transition.type          = @"rippleEffect";
                transition.duration      = .5;
                [weakSelf.weatherTodayImageView.layer addAnimation:transition forKey:@"transition"];
                
                weakSelf.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, PanScreenWidth, 1);
                [UIView animateWithDuration:.5 animations:^{
                    weakSelf.scrollView.transform = CGAffineTransformIdentity;
                }];
            }
        }
        else{
            [weakSelf weatherLoadfailed];
        }
        
    }];
    
    [hisTask resume];
}

//根据时间字符串获得当前星期几
-(NSString *)GetTime :(NSString *)timeStr
{
    //根据字符串转换成一种时间格式 供下面解析
//    NSString* string = @"2017-03-18 13:21";
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* inputDate = [inputFormatter dateFromString:timeStr];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:inputDate];
    NSInteger week = [comps weekday];
    NSString *strWeek = [self getweek:week];
    return strWeek;
}
-(NSString *)GetTime2 :(NSString *)timeStr
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:timeStr];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:inputDate];
    NSInteger week = [comps weekday];
    NSString *strWeek = [self getweek:week];
    return strWeek;
}

-(NSString*)getweek:(NSInteger)week
{
    NSString *weekStr=nil;
    
    if(week==1){
        weekStr=@"星期天";
        
    }else if(week==2){
        weekStr=@"星期一";
        
    }else if(week==3){
        weekStr=@"星期二";
        
    }else if(week==4){
        weekStr=@"星期三";
        
    }else if(week==5){
        weekStr=@"星期四";
        
    }else if(week==6){
        weekStr=@"星期五";
        
    }else if(week==7){
        weekStr=@"星期六";
        
    }
    return weekStr;
}


//天气加载失败
- (void)weatherLoadfailed {
    
    NSString *loadFail  = @"N/A";
    
    self.tmpLabel.text    = loadFail;
    self.maxTmpLabel.text = loadFail;
    self.minTmpLabel.text = loadFail;
    self.updateLabel.text = loadFail;
    
    self.day1TmpLabel.text = loadFail;
    self.day2TmpLabel.text = loadFail;
    self.day3TmpLabel.text = loadFail;
    self.day4TmpLabel.text = loadFail;
    self.day5TmpLabel.text = loadFail;
    self.day6TmpLabel.text = loadFail;
    self.day7TmpLabel.text = loadFail;
    
    self.day1Label.text = loadFail;
    self.day2Label.text = loadFail;
    self.day3Label.text = loadFail;
    self.day4Label.text = loadFail;
    self.day5Label.text = loadFail;
    self.day6Label.text = loadFail;
    self.day7Label.text = loadFail;
}
/**
 *  天气加载期间
 */
- (void)loadingInfo
{
    NSString *loadingStr = @"loading";
    self.tmpLabel.text      = [NSString stringWithFormat:@"🚫"];
    self.maxTmpLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    self.minTmpLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    self.updateLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    
    self.day1Label.text = loadingStr;
    self.day2Label.text = loadingStr;
    self.day3Label.text = loadingStr;
    self.day4Label.text = loadingStr;
    self.day5Label.text = loadingStr;
    self.day6Label.text = loadingStr;
    self.day7Label.text = loadingStr;
}

//将汉字转换成拼音
- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}
//将城市名转换成城市代码
- (NSString *)transCityNameIntoCityCode:(NSString *)cityNameString {
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CityData" ofType:@"plist"]];
    for (NSDictionary *groupDic in array) {
        TLCityGroup *group = [[TLCityGroup alloc] init];
        group.groupName    = [groupDic objectForKey:@"initial"];
        for (NSDictionary *dic in [groupDic objectForKey:@"citys"]) {
            if (cityNameString == [dic objectForKey:@"city_name"]) {
                return [dic objectForKey:@"city_key"];
            }
        }
    }
    return @"600010000";
}

/**
 *  定位当前城市🏙
 */
- (void)locationCurrentCity
{
    //检测定位功能是否开启
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        [SVProgressHUD showWithStatus:@"定位中"];
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [self.locationManager setDistanceFilter:5];
        //开始定位
        [self.locationManager startUpdatingLocation];
        //设置开始识别方向
        [self.locationManager startUpdatingHeading];
    }else{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
}

/**
 *  超时操作
 */
static int timesOut = 0;
- (void)locatStatue {
    
    timesOut ++;
    if (timesOut >= 10 && _locationManager) {
        
        [_locationManager stopUpdatingLocation];
        
        _locationManager = nil;
        
        [self timesOut];
        
        timesOut = 0;
    }
    [self animationWithView:self.selectCityBtn duration:.5];
}

#pragma mark - TLCityPickerDelegate
- (void) cityPickerController:(TLCityPickerController *)cityPickerViewController didSelectCity:(TLCity *)city
{
    //去除“市” 百度天气不允许带市、自治区等后缀
    if ([city.cityName rangeOfString:@"市"].location != NSNotFound) {
        NSInteger index = [city.cityName rangeOfString:@"市"].location;
        city.cityName = [city.cityName substringToIndex:index];
    }
    if ([city.cityName rangeOfString:@"县"].location != NSNotFound) {
        NSInteger index = [city.cityName rangeOfString:@"县"].location;
        city.cityName = [city.cityName substringToIndex:index];
    }
    [self _requestWeatherData:city.cityName];
    
    [cityPickerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) cityPickerControllerDidCancel:(TLCityPickerController *)cityPickerViewController
{
    [cityPickerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 *  缩放动画
 *
 *  @param view     button
 *  @param duration 0.5s
 */
- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation                     = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration            = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode            = kCAFillModeForwards;
    
    NSMutableArray *values        = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(.5, .5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(.9, .9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [view.layer addAnimation:animation forKey:nil];
}

/**
 *  定位超时
 */
- (void)timesOut{
    
    [SVProgressHUD showErrorWithStatus:@"定位超时！"];
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManangerDelegate
//定位成功以后调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self.locationManager stopUpdatingLocation];
    CLLocation* location = locations.lastObject;
    [self reverseGeocoder:location];
    
}
//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    
    if (_locationManager) {
        
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
    }
    [SVProgressHUD showErrorWithStatus:@"定位失败!"];
}

#pragma mark Geocoder
//反地理编码
- (void)reverseGeocoder:(CLLocation *)currentLocation {
    
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error || placemarks.count == 0){
            [SVProgressHUD showErrorWithStatus:@"定位失败"];
        }else {
            
            [SVProgressHUD showInfoWithStatus:@"定位成功"];
            
            CLPlacemark* placemark = placemarks.firstObject;
            
            NSLog(@"当前城市:%@",[[placemark addressDictionary] objectForKey:@"City"]);
            
            self.cityLabel.text = [NSString stringWithFormat:@"城市:  %@",[[placemark addressDictionary] objectForKey:@"City"]];
            
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"当前城市：%@",[[placemark addressDictionary] objectForKey:@"City"]]];
            
            NSString *cityName = [[placemark addressDictionary] objectForKey:@"City"];
            
            //去除“市” 百度天气不允许带市、自治区等后缀
            if ([cityName rangeOfString:@"市"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"市"].location;
                cityName = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"自治区"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"自治区"].location;
                cityName  = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"自治洲"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"自治洲"].location;
                cityName  = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"县"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"县"].location;
                cityName  = [cityName substringToIndex:index];
            }
            [self _requestWeatherData:cityName];
            
        }
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch=[touches anyObject];
    
    self.beginPoint=[touch locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSInteger touchCount = [touches count];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)touchCount]);
    
    UITouch *touch = [touches anyObject];
    
    self.movePoint = [touch locationInView:self.view];
    // 计算偏移值，取绝对值
    
    int deltaX = fabs(self.movePoint.x - self.beginPoint.x);
    
    int deltaY = fabs(self.movePoint.y - self.beginPoint.y);
    
    if (deltaX > touchDistance && deltaY <= touchPy)    {
        
        NSLog(@"横扫");
    }
    
    if (deltaY > touchDistance && deltaX <= touchPy)
        
    {
        NSLog(@"竖扫");
    }
    int changeX = self.movePoint.x - self.beginPoint.x;
    
    if (changeX > 0) {
        
        NSLog(@"右划");
        
        if (deltaX > touchDistance && deltaY <= touchPy)
            
        {
            NSLog(@"右划横扫");
        }
        
    }else
        
    {
        NSLog(@"左划");
        
        if (deltaX > touchDistance && deltaY<=touchPy)
            
        {
            NSLog(@"左划横扫");
            
        }}
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}











#pragma mark - weather bg & animation

//添加动画
- (void)addAnimationWithType:(NSString *)weatherType{
    NSLog(@"今日天气%@",weatherType);
    //先将所有的动画移除
    [self removeAnimationView];
    
    if ([weatherType isEqualToString:@"晴"]) { //晴天
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        [self sun];//动画
    }
    else if ([weatherType containsString:@"多云"]) { //多云
        [self changeImageAnimated:[UIImage imageNamed:@"bg_normal.jpg"]];
        [self wind];//动画
    }
    else if ([weatherType containsString:@"阴"]) { //阴
        [self changeImageAnimated:[UIImage imageNamed:@"bg_normal.jpg"]];
        [self wind];//动画
    }
    else if ([weatherType containsString:@"雨"]) { //雨
        [self changeImageAnimated:[UIImage imageNamed:@"bg_rain_day.jpg"]];
        [self rain];
    }
    else if ([weatherType containsString:@"雪"]) { //雪
        [self changeImageAnimated:[UIImage imageNamed:@"bg_snow_night.jpg"]];
        
    }
    else if ([weatherType containsString:@"尘"]) { //沙尘暴
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if ([weatherType containsString:@"雾"]||[weatherType containsString:@"霾"]) { //雾霾
        [self changeImageAnimated:[UIImage imageNamed:@"bg_haze.jpg"]];
        
    }
    else if ([weatherType containsString:@"风"]) { //风
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if ([weatherType containsString:@"雷"]) { //雷
        [self changeImageAnimated:[UIImage imageNamed:@"bg_night_rain.jpg"]];
        
    }
    else if ([weatherType containsString:@"热"]) { //热
        [self changeImageAnimated:[UIImage imageNamed:@"bg_sunny_day.jpg"]];
        
    }
    else if ([weatherType containsString:@"未知"]) { //未知
        
        
    }
    
    //[self.view bringSubviewToFront:self.weatherV];
}

- (void)changeImageAnimated:(UIImage *)image {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.backgroudView.layer addAnimation:transition forKey:@"a"];
    [self.backgroudView setImage:image];
}

- (void)removeAnimationView {
    //先将所有的动画移除
    [self.birdImage removeFromSuperview];
    [self.birdRefImage removeFromSuperview];
    [self.cloudImageViewF removeFromSuperview];
    [self.cloudImageViewS removeFromSuperview];
    [self.sunImage removeFromSuperview];
    [self.sunshineImage removeFromSuperview];
    [self.sunCloudImage removeFromSuperview];
    
    [self.rainCloudImage removeFromSuperview];
    
    for (NSInteger i = 0; i < _jsonArray.count; i++) {
        UIImageView *rainLineView = (UIImageView *)[self.view viewWithTag:100+i];
        [rainLineView removeFromSuperview];
    }
    
}


//晴天动画
- (void)sun {
    //太阳
    _sunImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnySun"]];
    CGRect frameSun = _sunImage.frame;
    frameSun.size   = CGSizeMake(200, 200*579/612.0);
    _sunImage.frame = frameSun;
    _sunImage.center = CGPointMake(PanScreenHeight * 0.1, PanScreenHeight * 0.1);
    [self.view addSubview:_sunImage];
    [_sunImage.layer addAnimation:[self sunshineAnimationWithDuration:40] forKey:nil];
    
    //太阳光
    _sunshineImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnySunshine"]];
    CGRect _sunImageFrame = _sunshineImage.frame;
    _sunImageFrame.size = CGSizeMake(400, 400);
    _sunshineImage.frame = _sunImageFrame;
    _sunshineImage.center = CGPointMake(PanScreenHeight * 0.1, PanScreenHeight * 0.1);
    [self.view addSubview:_sunshineImage];
    [_sunshineImage.layer addAnimation:[self sunshineAnimationWithDuration:40] forKey:nil];
    
    
    //晴天云
    _sunCloudImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud2"]];
    CGRect frame = _sunCloudImage.frame;
    frame.size = CGSizeMake(PanScreenHeight *0.7, PanScreenWidth*0.5);
    _sunCloudImage.frame = frame;
    _sunCloudImage.center = CGPointMake(PanScreenWidth * 0.25, PanScreenHeight*0.5);
    [_sunCloudImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:50] forKey:nil];
    [self.view addSubview:_sunCloudImage];
    
    
}

//多云动画
- (void)wind {
    
    //鸟 本体
    _birdImage = [[UIImageView alloc]initWithFrame:CGRectMake(-30, PanScreenHeight * 0.2, 70, 50)];
    [_birdImage setAnimationImages:self.imageArr];
    _birdImage.animationRepeatCount = 0;
    _birdImage.animationDuration = 1;
    [_birdImage startAnimating];
    [self.view addSubview:_birdImage];
    [_birdImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:10  ] forKey:nil];
    
    //鸟 倒影
    _birdRefImage = [[UIImageView alloc]initWithFrame:CGRectMake(-30, PanScreenHeight * 0.8, 70, 50)];
    //[self.backgroudView addSubview:self.birdRefImage];
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.birdRefImage.image];
    [_birdRefImage setAnimationImages:self.imageArr];
    _birdRefImage.animationRepeatCount = 0;
    _birdRefImage.animationDuration = 1;
    _birdRefImage.alpha = 0.4;
    [_birdRefImage startAnimating];
    
    [_birdRefImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:10] forKey:nil];
    
    
    //云朵效果
    _cloudImageViewF = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud2"]];
    CGRect frame = _cloudImageViewF.frame;
    frame.size = CGSizeMake(PanScreenHeight *0.7, PanScreenWidth*0.5);
    _cloudImageViewF.frame = frame;
    _cloudImageViewF.center = CGPointMake(PanScreenWidth * 0.25, PanScreenHeight*0.7);
    [_cloudImageViewF.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:70] forKey:nil];
    [self.view addSubview:_cloudImageViewF];
    
    
    _cloudImageViewS = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ele_sunnyCloud1"]];
    _cloudImageViewS.frame = self.cloudImageViewF.frame;
    _cloudImageViewS.center = CGPointMake(PanScreenWidth * 0.05, PanScreenHeight*0.7);
    [_cloudImageViewS.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:70] forKey:nil];
    [self.view addSubview:_cloudImageViewS];
    
}

//雨天动画
- (void)rain {
    
    //加载JSON文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainData.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    //将JSON数据转为NSArray或NSDictionary
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    _jsonArray = dict[@"weather"][@"image"];
    
    for (NSInteger i = 0; i < _jsonArray.count; i++) {
        
        NSDictionary *dic = [_jsonArray objectAtIndex:i];
        UIImageView *rainLineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:dic[@"-imageName"]]];
        rainLineView.tag = 100+i;
        NSArray *sizeArr = [dic[@"-size"] componentsSeparatedByString:@","];
        NSArray *originArr = [dic[@"-origin"] componentsSeparatedByString:@","];
        rainLineView.frame = CGRectMake([originArr[0] integerValue]*widthPix , [originArr[1] integerValue], [sizeArr[0] integerValue], [sizeArr[1] integerValue]);
        [self.view addSubview:rainLineView];
        [rainLineView.layer addAnimation:[self rainAnimationWithDuration:2+i%5] forKey:nil];
        [rainLineView.layer addAnimation:[self rainAlphaWithDuration:2+i%5] forKey:nil];
    }
    
    
    
    //乌云
    _rainCloudImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"night_rain_cloud"]];
    CGRect frame = _rainCloudImage.frame;
    frame.size = CGSizeMake(768/371.0* PanScreenWidth*0.5, PanScreenWidth*0.5);
    _rainCloudImage.frame = frame;
    _rainCloudImage.center = CGPointMake(PanScreenWidth * 0.25, PanScreenHeight*0.1);
    [_rainCloudImage.layer addAnimation:[self birdFlyAnimationWithToValue:@(PanScreenWidth+30) duration:50] forKey:nil];
    [self.view addSubview:_rainCloudImage];
    
}




//动画横向移动方法
- (CABasicAnimation *)birdFlyAnimationWithToValue:(NSNumber *)toValue duration:(NSInteger)duration{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue       = toValue;
    animation.duration      = duration;
    animation.removedOnCompletion = NO;
    animation.repeatCount   = MAXFLOAT;
    animation.fillMode      = kCAFillModeForwards;
    return animation;
}

//动画旋转方法
- (CABasicAnimation *)sunshineAnimationWithDuration:(NSInteger)duration{
    //旋转动画
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration      = duration;
    rotationAnimation.repeatCount   = MAXFLOAT;//你可以设置到最大的整数值
    rotationAnimation.cumulative    = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode      = kCAFillModeForwards;
    return rotationAnimation;
}

//下雨动画方法
- (CABasicAnimation *)rainAnimationWithDuration:(NSInteger)duration{
    
    CABasicAnimation* caBaseTransform = [CABasicAnimation animation];
    caBaseTransform.duration    = duration;
    caBaseTransform.keyPath     = @"transform";
    caBaseTransform.repeatCount = MAXFLOAT;
    caBaseTransform.removedOnCompletion = NO;
    caBaseTransform.fillMode    = kCAFillModeForwards;
    caBaseTransform.fromValue   = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-170, -620, 0)];
    caBaseTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(PanScreenHeight/2.0*34/124.0, PanScreenHeight/2, 0)];
    
    return caBaseTransform;
    
}
//透明度动画
- (CABasicAnimation *)rainAlphaWithDuration:(NSInteger)duration {
    
    CABasicAnimation *showViewAnn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showViewAnn.fromValue   = [NSNumber numberWithFloat:1.0];
    showViewAnn.toValue     = [NSNumber numberWithFloat:0.1];
    showViewAnn.duration    = duration;
    showViewAnn.repeatCount = MAXFLOAT;
    showViewAnn.fillMode    = kCAFillModeForwards;
    showViewAnn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    showViewAnn.removedOnCompletion = NO;
    
    return showViewAnn;
}


//--getter----------------------------------------------------
-(NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            NSString *fileName = [NSString stringWithFormat:@"ele_sunnyBird%d.png",i];
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [_imageArr addObject:image];
        }
        
    }
    return _imageArr;
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
