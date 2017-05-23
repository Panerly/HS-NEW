//
//  AppDelegate.m
//  first
//
//  Created by HS on 16/5/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "AppDelegate.h"
#import "HSTabBarController.h"
#import "LoginViewController.h"
#import "SingleViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MLTransition.h"

//ShareSDK头文件
#import <ShareSDK/ShareSDK.h>

//＝＝＝＝＝＝＝＝＝＝以下是各个平台SDK的头文件，根据需要集成的平台添加＝＝＝
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//以下是腾讯SDK的依赖库：
//libsqlite3.dylib

//微信SDK头文件
#import "WXApi.h"
//以下是微信SDK的依赖库：
//libsqlite3.dylib

//Pinterest SDK头文件
//#import <Pinterest/Pinterest.h>
#import <UserNotifications/UserNotifications.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
BMKMapManager* _mapManager;


@interface AppDelegate ()<JPUSHRegisterDelegate>
{
    NSUserDefaults *defaults;
    LoginViewController *loginVC;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    
//    //条件编译  // 条件编译指令：根据判断条件，编译不同区块的代码
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
//    
//    //1 配置远程推送收到消息后的状态:有脚标 有声音 有弹框
//    UIUserNotificationSettings *set = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
//    
//    //2 将配置添加进远程托送的设置中
//    [[UIApplication sharedApplication] registerUserNotificationSettings:set];
//    
//    //3 注册远程推送
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    
//#else
//    
//    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
//    
//#endif
    
    
    
    
    //c侧滑返回
    [MLTransition validatePanBackWithMLTransitionGestureRecognizerType:(MLTransitionGestureRecognizerTypePan)];
    
    defaults    = [NSUserDefaults standardUserDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //检测网络
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 一共有四种状态
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"AFNetworkReachability Not Reachable");
                
                [SVProgressHUD showInfoWithStatus:@"似乎已断开与互联网的连接" maskType:SVProgressHUDMaskTypeGradient];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"AFNetworkReachability Reachable via WWAN");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"AFNetworkReachability Reachable via WiFi");
                break;
            case AFNetworkReachabilityStatusUnknown:
            default:
                NSLog(@"AFNetworkReachability Unknown");
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret    = [_mapManager start:@"UBQFxfj8qazWAtt1gkYZLdKGG2AAb83G"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"mapManager start failed!");
    }
    
    
    loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;
    
    
    //多个控件接受事件时的排他性
    [[UIButton appearance] setExclusiveTouch:YES];
    
    [ShareSDK registerApp:@"158556148371e"];
    
    //初始化社交平台
    [self initializePlat];
    
    //待抄数据
    //[self getPushMessage];
    
    return YES;
}
//从苹果APNS获取Token成功
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"远程推送能力注册成功，deviceToken:%@",deviceToken);
}

//注册失败（获取Token）的话会执行的方法（设备不具备推送能力）
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"远程推送注册失败 原因是：%@",error);
}

//- (void)application:(UIApplication *)application
//didReceiveRemoteNotification:(NSDictionary *)userInfo
//fetchCompletionHandler:
//(void (^)(UIBackgroundFetchResult))completionHandler {
//    
//    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
//    completionHandler(UIBackgroundFetchResultNewData);
//}
//
//- (NSString*)logDic:(NSDictionary*)info {
//    
//    NSLog(@"%@",info);
//    return @"";
//}


/**
 *  添加通知
 */
- (void)locationNotification :(NSInteger )alertNum{
    
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        
        if (notification!=nil) {
            
            NSDate *now = [NSDate date];
            //从现在开始，0秒以后通知
            notification.fireDate    = [now dateByAddingTimeInterval:5];
            //使用本地时区
            notification.timeZone    = [NSTimeZone defaultTimeZone];
            notification.alertBody   = [NSString stringWithFormat:@"小表待抄  %ld  小区", (long)alertNum];
            //通知提示音 使用默认的
            notification.soundName   = UILocalNotificationDefaultSoundName;
            notification.alertAction = NSLocalizedString(@"滑动屏幕进行抄收", nil);
            //这个通知到时间时，你的应用程序右上角显示的数字。
            notification.applicationIconBadgeNumber = alertNum;
            //add key  给这个通知增加key 便于半路取消。nfkey这个key是随便起的。
            // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)alertNum],@"nfkey",nil];
            [notification setUserInfo:dict];
            //启动这个通知
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    } else {
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    
}


/**
 *  点击通知做出反应
 */

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    [self showMeteringVC];
    
}

- (void)showMeteringVC {
    
    
    [[[LoginViewController alloc] init] showDetailViewController:[[SingleViewController alloc] init] sender:nil];
    HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
        
        [loginVC presentViewController:tabBarCtrl animated:YES completion:^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            tabBarCtrl.modalPresentationStyle = UIModalPresentationPageSheet;
        }];
    } else {
        GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"提示" message:@"请输入账户、密码" buttonTitle:@"确定" buttonTouchedAction:^{
            
        } dismissAction:^{
            
        }];
        [alertView show];
    }
}

- (void)initializePlat
{
    
    [ShareSDK connectWeChatWithAppId:@"wx947dfa7241a19ca0" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatWithAppId:@"wx947dfa7241a19ca0"
                           appSecret:@"bb3324d49d0466557eabf44cf3c7714f"
                           wechatCls:[WXApi class]];
    

    [ShareSDK connectQQWithAppId:@"1105823619" qqApiCls:[QQApiInterface class]];
    
    [ShareSDK connectQQWithQZoneAppKey:@"1105823619" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectQZoneWithAppKey:@"1105823619" appSecret:@"Wj88YV79vMTWCPCO" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    //连接邮件
    [ShareSDK connectMail];
    
    //连接打印
    [ShareSDK connectAirPrint];
    
    //连接拷贝
    [ShareSDK connectCopy];
    
    
}

#pragma mark - 如果使用SSO（可以简单理解成跳客户端授权），以下方法是必要的

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -获取推送消息
- (void)getPushMessage {
    
    NSString *pushUrl                 = [NSString stringWithFormat:@"%@/Meter_Reading/Meter_areaServlet",litMeterApi];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf      = self;
    
    NSURLSessionTask *task            = [manager POST:pushUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *dataArr = [NSMutableArray array];
        
        if (responseObject) {
            for (NSDictionary *dic in responseObject) {
                
                [dataArr addObject:[dic objectForKey:@"area_Name"]];
            }
        }
        if (dataArr.count > 0) {
            [weakSelf locationNotification:dataArr.count];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    [task resume];
}


#pragma mark- JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
@end
