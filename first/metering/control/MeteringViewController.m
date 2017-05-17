//
//  MeteringViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringViewController.h"
#import "MeteringSingleViewController.h"
#import "SingleViewController.h"

#import "MeterInfoModel.h"
#import "MeterInfoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
//自定义tableview
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"

#import "LocaDBViewController.h"
#import "CompleteViewController.h"
#import "FTPopOverMenu.h"

#import "ScanImageViewController.h"
#import "SJViewController.h"


//static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
static NSString *const menuCellIdentifier = @"rotationCell";

@interface MeteringViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
AVCaptureMetadataOutputObjectsDelegate,
YALContextMenuTableViewDelegate,
UISearchResultsUpdating,
UISearchBarDelegate
>

{
    //判断是大表还是小表
    BOOL isBitMeter;
    UIImageView *loading;
    NSString *cellID;
    //扫描确认btn
    UIButton *scanBtn;
    //弹窗用的tableview，与界面重复，避免加载数据源混乱用BOOL区分
    BOOL isTap;
    NSURLSessionTask *task;
    AFNetworkReachabilityStatus netStatus;
    UISegmentedControl *segmentedCtl;
}
@property (nonatomic, assign) NSInteger num;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@property (nonatomic, strong) FMDatabase *db;


//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果


@end

//判断手电开启
static BOOL flashIsOn;

@implementation MeteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavColor];
    
    flashIsOn   = YES;
    isBitMeter  = YES;
    isTap       = NO;
    _num        = 5;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button addTarget:self action:@selector(QRcode) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_qrcode@3x"] forState:UIControlStateNormal];
    UIBarButtonItem *scan                   = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem   = scan;

    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(presentMenuButtonTapped)];
    self.navigationItem.rightBarButtonItem = more;
    
    [self initiateMenuOptions];
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    [self _createTableView];
    
    [self loadInterNetData];
    
    [self setSegmentedCtl];
}
/**
 *  设置导航栏的颜色，返回按钮和标题为白色
 */
-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = COLORRGB(226, 107, 16);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

//大小表控制
- (void)setSegmentedCtl {
    segmentedCtl            = [[UISegmentedControl alloc] initWithItems:@[@"小表抄收",@"大表抄收"]];
    segmentedCtl.frame      = CGRectMake(0, 0, PanScreenWidth/3, 30);
    segmentedCtl.tintColor  = [UIColor whiteColor];
    segmentedCtl.selectedSegmentIndex = 0;
    [segmentedCtl addTarget:self action:@selector(meterTypecOntrol:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedCtl;
    segmentedCtl.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isBitMeter) {
        [self loadBigMeterLocalData];
    }
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:@"select * from litMeter_info"];
        int litMeterCountNum = 0;
        int bigMeterCountNum = 0;
        while ([restultSet next]) {
            if (![[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                litMeterCountNum++;
            }
            if ([[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                bigMeterCountNum++;
            }
        }
        if (litMeterCountNum + bigMeterCountNum > 0) {
            
//            self.tabBarItem.badgeColor = [UIColor redColor];
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCountNum+bigMeterCountNum];
        }else{
            
            self.tabBarItem.badgeValue = nil;
        }
    }
    [db close];
}

/**
 *  监测网络连接请求任务
 */
- (void)loadInterNetData {
    
    __weak typeof(self) weakSelf = self;
    //检测网络
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        netStatus = status;
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [SVProgressHUD showInfoWithStatus:@"似乎已断开与互联网的连接" maskType:SVProgressHUDMaskTypeGradient];
            [self createDB];
            if ([self.db open]) {
                FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Meter_area where id = '1' order by id"];
                if (_dataArr) {
                    [_dataArr removeAllObjects];
                }else {
                    _dataArr = [NSMutableArray array];
                    [_dataArr removeAllObjects];
                }
                
                while ([restultSet next]) {
                    NSString *install_addr         = [restultSet stringForColumn:@"area_Name"];
                    NSString *area_id              = [restultSet stringForColumn:@"id"];
                    MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
                    meterinfoModel.install_Addr    = install_addr;
                    meterinfoModel.area_Id         = area_id;
                    [_dataArr addObject:meterinfoModel];
                }
                
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            [weakSelf.db close];
            [weakSelf.tableView.mj_header endRefreshing];
            
        } else {
            
            [weakSelf _requestData];
            [weakSelf loadLitMeterData];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

//加载大表本地数据
- (void)loadBigMeterLocalData {
    
    [self createDB];
    if ([self.db open]) {
        
        FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM litMeter_info where collector_area = '00' order by id"];
        if (_dataArr) {
            
            [_dataArr removeAllObjects];
        }else {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
        }
        
        while ([restultSet next]) {
            
            NSString *install_addr         = [restultSet stringForColumn:@"install_addr"];
            MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
            meterinfoModel.install_Addr    = install_addr;
            [_dataArr addObject:meterinfoModel];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.db close];
    [self.tableView.mj_header endRefreshing];

}
/**
 *  加载小表列表数据
 */
- (void)loadLitMeterData {
    
    //刷新控件
    if (!loading) {
        loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        loading.center = self.view.center;
        UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
        [loading setImage:image];
        [self.view addSubview:loading];
    }
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }
    
    NSString *litMeterDataUrl                 = [NSString stringWithFormat:@"%@/Meter_Reading/Meter_areaServlet",litMeterApi];
    
    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    NSURLSessionTask *litMeterTask = [manager POST:litMeterDataUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        NSError *error;
        
        if (responseObject) {
            
            [loading removeFromSuperview];
            
            for (NSDictionary *dic in responseObject) {
                if (![[dic objectForKey:@"area_Id"] isEqualToString:@"00"]) {
                    
                    MeterInfoModel *meterInfoModel = [[MeterInfoModel alloc] initWithDictionary:dic error:&error];
                    [_dataArr addObject:meterInfoModel];
                }
                
                if ([weakSelf.db open]) {
                    
                    [weakSelf.db executeUpdate:@"create table if not exists Meter_area (id integer primary key autoincrement,  area_Name text null);"];
                    [weakSelf.db executeUpdate:@"replace into Meter_area (id, area_Name) values (?,?)",[dic objectForKey:@"area_Id"], [dic objectForKey:@"area_Name"]];
                    
                }
                [weakSelf.db close];
            }
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
        if (!isBitMeter) {
            [self loadBigMeterLocalData];
        }
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
        if ([db open]) {
            
            FMResultSet *restultSet = [db executeQuery:@"select * from litMeter_info"];
            int litMeterCountNum    = 0;
            int bigMeterCountNum    = 0;
            while ([restultSet next]) {
                if (![[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                    litMeterCountNum++;
                }
                if ([[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                    bigMeterCountNum++;
                }
            }
            if (litMeterCountNum + bigMeterCountNum > 0) {
                
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCountNum+bigMeterCountNum];
            }else{
                
                self.tabBarItem.badgeValue = nil;
            }
        }
        [db close];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"小表数据查询失败：%@",error);
        [loading removeFromSuperview];
    }];
    [litMeterTask resume];
}



/**
 *  视图消失停止请求任务
 *
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (task.state == MJRefreshStateRefreshing) {
        [task cancel];
    }
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}


//- (void)share{
//    UIImage *image = [UIImage imageNamed:@"bg_server.jpg"];
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
//    id<ISSCAttachment> localAttachment = [ShareSDKCoreService attachmentWithPath:encodedImageStr];
//    //1.2、以下参数分别对应：内容、默认内容、图片、标题、链接、描述、分享类型
//    id<ISSContent> publishContent = [ShareSDK content:@"分享测试"
//                                       defaultContent:nil
//                                                image:localAttachment
//                                                title:@"测试标题"
//                                                  url:@"http://www.hzsb.com"
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeImage];
//
//    
//    //1+、创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:nil
//                            arrowDirect:UIPopoverArrowDirectionUp];
//    //2、展现分享菜单
//    [ShareSDK showShareActionSheet:container
//                         shareList:nil
//                           content:publishContent
//                     statusBarTips:NO
//                       authOptions:nil
//                      shareOptions:nil
//                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                
//                                NSLog(@"=== response state :%zi ",state);
//                                
//                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                                //可以根据回调提示用户。
//                                if (state == SSResponseStateSuccess)
//                                {
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"分享成功!" preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                    
//                                }
//                                else if (state == SSResponseStateFail) {
//                                    
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:[NSString stringWithFormat:@"Error Description：%@",[error errorDescription]] preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                }
//                            }];
//    
//    
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_createTableView
{
    cellID = @"meterInfoID";
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor      = [UIColor clearColor];
        self.tableView.delegate         = self;
        self.tableView.dataSource       = self;
        self.tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor  = [UIColor clearColor];
        _tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeOnDrag;
        
        [_tableView registerNib:[UINib nibWithNibName:@"MeterInfoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
        
        [_tableView setExclusiveTouch:YES];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadInterNetData)];
        _tableView.mj_header.automaticallyChangeAlpha = YES;
        
        //调用初始化searchController
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
        self.searchController.dimsBackgroundDuringPresentation      = NO;
        self.searchController.hidesNavigationBarDuringPresentation  = NO;
        self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
        self.searchController.searchBar.placeholder                 = @"搜索";
        
        self.searchController.searchBar.delegate    = self;
        self.searchController.searchResultsUpdater  = self;
        //搜索栏表头视图
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.searchController.searchBar sizeToFit];
    }
    
    if (!self.contextMenuTableView) {
        
        self.contextMenuTableView                   = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.scrollEnabled     = NO;
        self.contextMenuTableView.animationDuration = 0.1;
        self.contextMenuTableView.yalDelegate       = self;
        self.contextMenuTableView.menuItemsSide     = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        [self.contextMenuTableView registerNib:[UINib nibWithNibName:@"ContextMenuCell" bundle:nil] forCellReuseIdentifier:menuCellIdentifier];
        
    }
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [[UIStoryboard storyboardWithName:@"Metering" bundle:nil] instantiateViewControllerWithIdentifier:@"Metering"];
    }
    return self;
}


/**
 *  大小表切换
 *
 */
- (IBAction)meterTypecOntrol:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0://小表
            isBitMeter = YES;
            [self.dataArr removeAllObjects];
            if (netStatus == AFNetworkReachabilityStatusNotReachable) {
                [self loadLitMeterLocalData];
            } else {
                [self loadLitMeterData];
            }
            break;
        case 1://大表
            isBitMeter = NO;
            [self.dataArr removeAllObjects];
            [self loadBigMeterLocalData];
        default:
            break;
    }
    
}

- (void)loadLitMeterLocalData {
    [self createDB];
    if ([self.db open]) {
        
        FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Meter_area where id = 1 order by id"];
        if (_dataArr) {
            
            [_dataArr removeAllObjects];
        }else {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
        }
        
        while ([restultSet next]) {
            
            NSString *install_addr          = [restultSet stringForColumn:@"install_addr"];
            NSString *meter_id              = [restultSet stringForColumn:@"id"];
            MeterInfoModel *meterinfoModel  = [[MeterInfoModel alloc] init];
            meterinfoModel.install_Addr     = install_addr;
            meterinfoModel.area_Id          = meter_id;
            [_dataArr addObject:meterinfoModel];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.db close];
    [self.tableView.mj_header endRefreshing];
}


//请求列表信息
- (void)_requestData {
    //刷新控件
    if (!loading) {
        
        loading         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        loading.center  = self.view.center;
        UIImage *image  = [UIImage sd_animatedGIFNamed:@"刷新5"];
        [loading setImage:image];
        [self.view addSubview:loading];
    }
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }
    
    NSString *logInUrl                   = [NSString stringWithFormat:@"%@/Meter_Reading/Meter_info_1Servlet",litMeterApi];
    
    NSURLSessionConfiguration *config    = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager        = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    task =[manager POST:logInUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            [weakSelf createDB];
            
            UIAlertAction *conformBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                int litMeterCount = 0;
                int bigMeterCount = 0;
                for (NSDictionary *dic in responseObject) {
                    
                    if ([[dic objectForKey:@"collector_Area"] isEqualToString:@"00"]) {
                        litMeterCount++;
                    }
                    if (![[dic objectForKey:@"collector_Area"] isEqualToString:@"00"]) {
                        bigMeterCount++;
                    }
                    
                    if ([weakSelf.db open]) {
                        [weakSelf.db executeUpdate:@"replace into litMeter_info (collect_Img_Name1, collect_Img_Name2, collect_Img_Name3, collector_Area, comm_Id, id, install_Addr, install_Time, meter_Cali, meter_Id, meter_Name, meter_Txm, meter_Wid, remark, user_Id, water_Kind, x, y, collector_num) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[dic objectForKey:@"collect_Img_Name1"], [dic objectForKey:@"collect_Img_Name2"], [dic objectForKey:@"collect_Img_Name3"], [dic objectForKey:@"collector_Area"], [dic objectForKey:@"comm_Id"], [dic objectForKey:@"id"], [dic objectForKey:@"install_Addr"], [dic objectForKey:@"install_Time"], [dic objectForKey:@"meter_Cali"], [dic objectForKey:@"meter_Id"], [dic objectForKey:@"meter_Name"], [dic objectForKey:@"meter_Txm"], [dic objectForKey:@"meter_Wid"], [dic objectForKey:@"remark"], [dic objectForKey:@"user_Id"], [dic objectForKey:@"water_Kind"], [dic objectForKey:@"x"], [dic objectForKey:@"y"], [dic objectForKey:@"collector_num"]];
                    }
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%d",litMeterCount] forKey:@"litMeterCount"];
                [defaults setObject:[NSString stringWithFormat:@"%d",bigMeterCount] forKey:@"bigMeterCount"];
                [defaults synchronize];
                if (litMeterCount + bigMeterCount > 0) {
                    
                    weakSelf.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCount+bigMeterCount];
                }else{
                    
                    weakSelf.tabBarItem.badgeValue = nil;
                }
                
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.db close];
                
                [loading removeFromSuperview];
            }];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [loading removeFromSuperview];
            }];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否网络覆盖本地数据？" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:cancelBtn];
            [alertVC addAction:conformBtn];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        [loading removeFromSuperview];
        
        NSLog(@"错误信息：%@",error);
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];

}

#pragma mark - openQrcode
//开启扫描
- (void)QRcode {

    SJViewController *viewController = [[SJViewController alloc] init];
    __weak typeof(self)weakSelf = self;
    /** 扫描成功返回来的数据 */
    viewController.successBlock = ^(NSString *successString) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"successBlock=%@",successString);
        
        SingleViewController *singleVC      = [[SingleViewController alloc] init];
        singleVC.meter_id_string            = [weakSelf getInfo:successString];
        singleVC.hidesBottomBarWhenPushed   = YES;
        if ([weakSelf getInfo:successString] == nil) {
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本地库中不存在此户信息！\n请更新本地库或检查条码信息！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }else{
            
            [weakSelf.navigationController showViewController:singleVC sender:nil];
        }
    };
    
    [self presentViewController:viewController animated:YES completion:nil];
    /*
     [SVProgressHUD show];
    
    if (!_scanView) {
        _scanView                   = [[UIView alloc] initWithFrame:self.view.bounds];
        _scanView.center            = self.view.center;
        _scanView.backgroundColor   = [UIColor blackColor];
        _scanView.alpha             = .8;
        [self.navigationController.view addSubview:_scanView];
    }

    if (!scanBtn) {

        scanBtn = [[UIButton alloc] init];
    }
    [scanBtn setTitle:@"关闭" forState:UIControlStateNormal];
    scanBtn.backgroundColor     = [UIColor redColor];
    scanBtn.clipsToBounds       = YES;
    scanBtn.layer.cornerRadius  = 5;
    [scanBtn addTarget:self action:@selector(conformBtn) forControlEvents:UIControlEventTouchUpInside];
    [_scanView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(80, 30));
        make.centerX.equalTo(_scanView.centerX);
        make.bottom.equalTo(_scanView.bottom).with.offset(-120);
    }];
    
    [self startReading];
     */

}

/*
//关闭窗口
- (void)conformBtn
{
    [SVProgressHUD dismiss];
    
    [UIView animateWithDuration:.5 animations:^{
        
        _scanView.transform          = CGAffineTransformMakeScale(.001, .001);
        _videoPreviewLayer.transform = CATransform3DMakeScale(.001, .001, .001);
        
    } completion:^(BOOL finished) {
        
        [_scanView removeFromSuperview];
        [_videoPreviewLayer removeFromSuperlayer];
        
        _videoPreviewLayer  = nil;
        _scanView           = nil;

    }];
}

//开始读取
- (BOOL)startReading
{
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input     = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"警告！" message:@"设备不支持！请检查" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self conformBtn];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return NO;
    }
    
    //先上锁 设置完属性再解锁
    if ([captureDevice lockForConfiguration:nil]) {
        
        //自动闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [captureDevice unlockForConfiguration];
    }
    
    
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];

    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];

    // 创建输出对象
    if (!_videoPreviewLayer) {
        
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _videoPreviewLayer.cornerRadius = 10;
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:CGRectMake(20, _scanView.center.y-PanScreenHeight/4, PanScreenWidth - 40, PanScreenHeight/3)];
        [self.navigationController.view.layer addSublayer:_videoPreviewLayer];
        // 开始会话
        [_captureSession startRunning];
    }
    [SVProgressHUD dismiss];

    return YES;
}

//停止读取
- (void)stopReading
{
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
}

//获取捕获数据
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObj.stringValue;
//        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            result = metadataObj.stringValue;
//        } else {
//            NSLog(@"不是二维码");
//        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
//处理结果
- (void)reportScanResult:(NSString *)result {
    
    [self stopReading];
    NSLog(@"扫描结果：%@",result);
    
    UILabel *resultLabel        = [[UILabel alloc] init];
    resultLabel.text            = result;
    resultLabel.textColor       = [UIColor whiteColor];
    resultLabel.textAlignment   = NSTextAlignmentCenter;
    [_scanView addSubview:resultLabel];
    
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(200, 25));
        make.centerX.equalTo(_scanView.centerX);
        make.top.equalTo(_scanView.mas_top).with.offset(84);
    }];

    [self conformBtn];
    
    SingleViewController *singleVC      = [[SingleViewController alloc] init];
    singleVC.meter_id_string            = [self getInfo:result];
    singleVC.hidesBottomBarWhenPushed   = YES;
    if ([self getInfo:result] == nil) {
        GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"确定" message:@"本地库中不存在此户信息！\n请更新本地库或检查条码信息！" buttonTitle:@"确定" buttonTouchedAction:^{
            
        } dismissAction:^{
            
        }];
        [alertView show];
    }else{
        
        [self.navigationController showViewController:singleVC sender:nil];
    }
    
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;

    UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"条形码扫描" message:result preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action       = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:^{

    }];

    // 以下处理了结果，继续下次扫描
    _lastResult = YES;
}
*/

//查找本地库信息是否存在此扫描结果数据
- (NSString*)getInfo :(NSString *)meter_id {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  条码号(meter_id)：%@", fileName, meter_id);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from litMeter_info where meter_txm = '%@'",meter_id]];
        NSString *install_addr;
        while ([restultSet next]) {
            install_addr = [restultSet stringForColumn:@"meter_id"];
        }
        if (install_addr) {
            
            return install_addr;
        }else{
            
            
            return nil;
        }
    }
    return nil;
}

#pragma mark - Local methods

- (void)initiateMenuOptions {
    
    self.menuTitles = @[
                        @"",
                        @"开  启  手  电  筒",
                        @"查看本地数据库",
                        @"已完成抄收列表"
                        ];
    
    self.menuIcons = @[
                       [UIImage imageNamed:@"icon_close@3x"],
                       [UIImage imageNamed:@"light@3x"],
                       [UIImage imageNamed:@"icon_db@3x"],
                       [UIImage imageNamed:@"icon_complete@2x"]
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Menu dismissed with indexpath.row = %ld", (long)indexPath.row);
    isTap = !isTap;
    if (!isTap) {
        [self.view addSubview:_tableView];
        [self.view insertSubview:_tableView belowSubview:_ctrlBtn];
    }
    if (indexPath.row == 1) {
        [self systemLightSwitch:flashIsOn];
    }
    if (indexPath.row == 2) {
        LocaDBViewController *locaDB = [[LocaDBViewController alloc] init];
        [self.navigationController showViewController:locaDB sender:nil];
    }
    if (indexPath.row == 3) {
        CompleteViewController *completeVC = [[CompleteViewController alloc] init];
        [self.navigationController showViewController:completeVC sender:nil];
    }
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isTap) {
        [tableView dismisWithIndexPath:indexPath];
        
    }else {
        if (isBitMeter) {
            
            MeteringSingleViewController *meteringVC = [[MeteringSingleViewController alloc] init];
            if (self.searchController.active) {
                
                meteringVC.area_id = [((MeterInfoModel *)_searchResults[indexPath.row]).area_Id isEqualToString:@"1"]?@"01":((MeterInfoModel *)_searchResults[indexPath.row]).area_Id;
            }else {
                
                meteringVC.area_id = [((MeterInfoModel *)_dataArr[indexPath.row]).area_Id isEqualToString:@"1"]?@"01":((MeterInfoModel *)_dataArr[indexPath.row]).area_Id;
            }
            meteringVC.hidesBottomBarWhenPushed = YES;
            meteringVC.title = @"任务详情";
            [self.navigationController showViewController:meteringVC sender:nil];
        }
        else
        {
            SingleViewController *singleVC      = [[SingleViewController alloc] init];
            singleVC.meter_id_string            = self.searchController.active?((MeterInfoModel *)_searchResults[indexPath.row]).install_Addr:((MeterInfoModel *)_dataArr[indexPath.row]).install_Addr;
            singleVC.hidesBottomBarWhenPushed   = YES;
            singleVC.isBigMeter                 = YES;
            [self.navigationController showViewController:singleVC sender:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isTap) {
        
        return 50;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isTap) {
        
        return self.menuTitles.count;
    }
    return  self.searchController.active?_searchResults.count:_dataArr.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isTap) {
        
        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            
            cell.backgroundColor     = [UIColor clearColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
            return cell;
        }
    }
    MeterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.backgroundColor         = [UIColor clearColor];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= self.searchController.active?_searchResults[indexPath.row]:_dataArr[indexPath.row];
    return cell;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    if (isTap) {
        
        [self.contextMenuTableView reloadData];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (isTap) {
        
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        
        [self.contextMenuTableView updateAlongsideRotation];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (isTap) {
        
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        
        
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            //should be called after rotation animation completed
            [self.contextMenuTableView reloadData];
        }];
        [self.contextMenuTableView updateAlongsideRotation];
    }
    
}
/**
 *  隐藏状态栏
 *
 */
- (BOOL)prefersStatusBarHidden {
    return NO;
}

/**
 *  当点击更多时隐藏本页tableview（防止两个tableview冲突）
 */
- (void)presentMenuButtonTapped {
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
    isTap = !isTap;
    if (isTap) {
        [self.tableView removeFromSuperview];
    } else {
        
        [self _createTableView];
    }
    
}

#pragma mark - 打开手电筒
//打开闪光灯
- (void)systemLightSwitch:(BOOL)open {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
            flashIsOn = !flashIsOn;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            flashIsOn = !flashIsOn;
        }
        [device unlockForConfiguration];
    }
}
#pragma mark - 创建数据库
- (void)createDB {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"数据库路径(创建时)：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        BOOL createLitMeter = [db executeUpdate:@"create table if not exists litMeter_info (id integer PRIMARY key AUTOINCREMENT, meter_id text not null, user_id text null, meter_txm nvarchar(20) null, meter_wid nvarchar(20) null, collector_area nvarchar(2) null, install_time datetime null, install_addr nvarchar(50) null, comm_id nvarchar(20) null, water_kind nvarchar(20) null, meter_cali int null, meter_name varchar(50) null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, bs nvarchar(2) null, Collect_img_name1 nvarchar(50) null, Collect_img_name2 nvarchar(50) null, Collect_img_name3 nvarchar(50) null, collector_num navrchar(50) null);"];
        
        if (createLitMeter) {
            NSLog(@"创建小表成功");
        } else {
            NSLog(@"创建小表失败！");
            [SCToastView showInView:_tableView text:@"创建小表失败" duration:.5 autoHide:YES];
        }
        
        BOOL createLitMeterHisAll = [db executeUpdate:@"create table if not exists litMeter_reading (id integer primary key autoincrement, meter_id text not null, collect_num text not null, collect_dt text not null, collect_avg text not null, collect_status text not null, collect_img_name1 nvarchar(50) null, collect_img_name2 nvarchar null)"];
        if (createLitMeterHisAll) {
            NSLog(@"创建小表上期情况成功");
        }else {
            NSLog(@"创建小表上期情况失败");
            [SCToastView showInView:_tableView text:@"创建小表失败" duration:.5 autoHide:YES];
        }
        
        
    }
    
    self.db = db;
    
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    if (self.view.window == nil && [self isViewLoaded]) {
//        self.view = nil;
//    }
//}

#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults = [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr     = [NSMutableArray array];
    NSMutableArray *arr2    = [NSMutableArray array];
    [arr2 removeAllObjects];
    if (isBitMeter) {
        
        for (MeterInfoModel *model in self.dataArr) {
            [arr addObject:model.area_Name];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (MeterInfoModel *model in self.dataArr) {
            if ([arr2 containsObject:model.area_Name]) {
                [self.searchResults addObject:model];
            }
        }
    } else {
        for (MeterInfoModel *model in self.dataArr) {
            [arr addObject:model.install_Addr];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (MeterInfoModel *model in self.dataArr) {
            if ([arr2 containsObject:model.install_Addr]) {
                [self.searchResults addObject:model];
            }
        }
    }
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn = [searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}


@end
