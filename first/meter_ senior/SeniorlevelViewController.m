//
//  SeniorlevelViewController.m
//  first
//
//  Created by HS on 2016/12/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SeniorlevelViewController.h"
#import "JHPieChart.h"
#import "MapDataDetailViewController.h"
#import "BigMeterDetailCell.h"
#import "UIImageView+WebCache.h"

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>
//#import <BaiduMapAPI_Map/BMKCircle.h>
//#import <BaiduMapAPI_Map/BMKOverlayView.h>

@interface SeniorlevelViewController ()
<
BMKMapViewDelegate,
BMKLocationServiceDelegate,
UITableViewDelegate,
UITableViewDataSource
>

{
    BOOL map_type;
    BOOL isBigMeter;
    UIButton *selectedBtn;
    UIView *paopaoBgView;
    int bmkViewTag;
    UIImage *bmkImage;
    BOOL flag;
    NSTimer *timer;
    JHPieChart *pie;
    UIButton *closeBtn;
    UIButton *refreshBtn;
    UIButton *imageViewBtn;
}

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKMapView *bmkMapView;
@property (nonatomic, strong) NSMutableArray *annomationArray;

@end

@implementation SeniorlevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    map_type = YES;
    flag     = YES;
    
    [self _createDB];
    
    [self setNavColor];
    
    [self initMapView];
    
    [self initRightBarItem];
    
    [self initLeftBarItem];
    
    [self _requestMeterData];
    
    _infoDataArr        = [NSMutableArray array];
    _bigMeterDataArr    = [NSMutableArray array];
    _litMeterDataArr    = [NSMutableArray array];
    _annomationArray    = [NSMutableArray array];
    _bigMeterDetailArr  = [NSMutableArray array];
    
}

//创建本地信息库
- (void)_createDB {
    
    NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
    if ([db open]) {
        
        [db executeUpdate:@"delete from meter_info_senior"];

        BOOL result = [db executeUpdate:@"create table if not exists meter_info_senior (id integer PRIMARY KEY AUTOINCREMENT,area_id text null,area_name text null, bs text null, collect_dt text null,collect_img_name1 text null, collect_img_name2 text null, collect_num text null, x text null, y text null, install_addr text null, meter_id text null);"];
        
        if (result) {
            
            NSLog(@"创建抄收信息表成功");
        } else {
            
            NSLog(@"创建抄收信息表失败！");
            [SCToastView showInView:self.view text:@"创建抄收信息表失败" duration:1.5 autoHide:YES];
        }
        
    }
    [db close];

}

//大小饼图视图切换
- (void)initLeftBarItem {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame     = CGRectMake(0, 0, 30, 30);
    btn.showsTouchWhenHighlighted = YES;
    [btn setImage:[UIImage imageNamed:@"icon_pie"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setChartSwitch:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pieItem              = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = pieItem;
}
//大小表分享
- (void)initRightBarItem {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.showsTouchWhenHighlighted = YES;
    [btn addTarget:self action:@selector(setSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem               = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = addItem;
}


//分享item
- (void)initShareBtn {
    
    UIButton *rightButton       = [[UIButton alloc]initWithFrame:CGRectMake(0,0,57,45)];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [rightButton setImage:[UIImage imageNamed:@"share_icon.png"]forState:UIControlStateNormal];
    rightButton.tintColor       = [UIColor redColor];
    [rightButton addTarget:self action:@selector(selectRightAction:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem  = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)selectRightAction:(UIButton *)sender
{
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"抄表情况"
                                                image:[ShareSDK jpegImageWithImage:[self getSnapshotImage] quality:1]
                                                title:@"抄表情况截图"
                                                  url:@"http://www.hzsb.com"
                                          description:@"杭州水表"
                                            mediaType:SSPublishContentMediaTypeImage];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //  选择要添加的功能
    NSArray *shareList = [ShareSDK customShareListWithType:
                          SHARE_TYPE_NUMBER(ShareTypeCopy),
                          SHARE_TYPE_NUMBER(ShareTypeMail),
                          SHARE_TYPE_NUMBER(ShareTypeWeixiTimeline),
                          SHARE_TYPE_NUMBER(ShareTypeWeixiSession),
                          SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                          SHARE_TYPE_NUMBER(ShareTypeQQSpace),
                          SHARE_TYPE_NUMBER(ShareTypeQQ),
                          nil];
    __weak typeof(self) weakSelf = self;
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                    [SCToastView showInView:weakSelf.view text:@"分享成功" duration:1 autoHide:YES];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                    [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"分享失败,原因：%@",[error errorDescription]] duration:3.5 autoHide:YES];
                                }
                                else if (state == SSResponseStateCancel)
                                {
                                    [SCToastView showInView:weakSelf.view text:@"已取消分享" duration:2.5 autoHide:YES];
                                }
                            }];
    
    
    
}


//获取当前屏幕
- (UIImage *)getSnapshotImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 1);
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

//大小表饼图切换
- (void)setChartSwitch :(UIView *)sender{
    
    //大表已超
    int bigMeterCompleteNum   = 0;
    //大表未超
    int bigMeterUnCompleteNum = 0;
    //小表已超
    int litMeterCompleteNum   = 0;
    //小表未超
    int litMeterUnCompleteNum = 0;
    
    for (int i = 0; i < _bigMeterDataArr.count; i++) {
        
        if ([((MapDataModel *)_bigMeterDataArr[i]).bs isEqualToString:@"0"]) {//大表未抄
            bigMeterUnCompleteNum++;
        }else{//大表已抄
            bigMeterCompleteNum++;
        }
    }
    for (int i = 0; i < _litMeterDataArr.count; i++) {
        if ([((MapDataModel *)_litMeterDataArr[i]).bs isEqualToString:@"0"]) {//小表未抄
            litMeterUnCompleteNum++;
        }else{//小表已抄
            litMeterCompleteNum++;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    if (!pie) {
        
        pie        = [[JHPieChart alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth - 50, PanScreenHeight/2)];
        pie.center = CGPointMake(CGRectGetMaxX(self.view.frame)/2, CGRectGetMaxY(self.view.frame)/2);
        pie.backgroundColor    = [UIColor whiteColor];
        pie.clipsToBounds      = YES;
        pie.layer.cornerRadius = 8;
        /*    When touching a pie chart, the animation offset value     */
        pie.positionChangeLengthWhenClick = 15;
        
    }
    NSMutableArray *bigMeterNumArr = [NSMutableArray arrayWithCapacity:2];
    [bigMeterNumArr addObject:[NSString stringWithFormat:@"%d",bigMeterCompleteNum]];
    [bigMeterNumArr addObject:[NSString stringWithFormat:@"%d",bigMeterUnCompleteNum]];
    
    NSMutableArray *smallMeterNumArr = [NSMutableArray arrayWithCapacity:2];
    [smallMeterNumArr addObject:[NSString stringWithFormat:@"%d",litMeterCompleteNum]];
    [smallMeterNumArr addObject:[NSString stringWithFormat:@"%d",litMeterUnCompleteNum]];
    
    if (!closeBtn) {
        
        closeBtn = [[UIButton alloc] initWithFrame:CGRectMake((PanScreenWidth - 50)/2, PanScreenHeight - 49 - 50*2, 50, 50)];
        closeBtn.tintColor = [UIColor redColor];
        [closeBtn becomeFirstResponder];
        [closeBtn setImage:[UIImage imageNamed:@"close@2x"] forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"大表 pie",@"小表 pie"] imageArray:@[@"icon_bigMeter",@"icon_smallMeter"] doneBlock:^(NSInteger selectedIndex) {
        if (selectedIndex == 0) {
            
            [weakSelf.view addSubview:pie];
            /* Pie chart value, will automatically according to the percentage of numerical calculation */
            pie.valueArr = bigMeterNumArr;
            /* The description of each sector must be filled, and the number must be the same as the pie chart. */
            pie.descArr = @[@"大表已抄",@"大表未抄"];
            
            //Start animation
            [pie showAnimation];
            [weakSelf.view addSubview:closeBtn];
            
            if (bigMeterCompleteNum+bigMeterUnCompleteNum < 1) {
                [SCToastView showInView:self.view text:@"暂无数据，请更新\n温馨提示:左下角更新" duration:2 autoHide:YES];
            }
        }else if (selectedIndex == 1) {
            
            pie.valueArr = smallMeterNumArr;
            pie.descArr = @[@"小表已抄",@"小表未抄"];
            
            [weakSelf.view addSubview:pie];
            [pie showAnimation];
            [weakSelf.view addSubview:closeBtn];
            if (litMeterUnCompleteNum+litMeterUnCompleteNum < 1) {
                
                [SCToastView showInView:self.view text:@"暂无数据，请更新\n温馨提示:左下角更新" duration:2 autoHide:YES];
            }
        }

        
    } dismissBlock:^{
        NSLog(@"user canceled. do nothing.");
    }];
//    [FTPopOverMenu showForSender:sender
//                        withMenu:@[@"大表 pie",@"小表 pie"]
//                  imageNameArray:@[@"icon_bigMeter",@"icon_smallMeter"]
//                       doneBlock:^(NSInteger selectedIndex) {
//                           if (selectedIndex == 0) {
//                               
//                               [weakSelf.view addSubview:pie];
//                               /* Pie chart value, will automatically according to the percentage of numerical calculation */
//                               pie.valueArr = bigMeterNumArr;
//                               /* The description of each sector must be filled, and the number must be the same as the pie chart. */
//                               pie.descArr = @[@"大表已抄",@"大表未抄"];
//                               
//                               //Start animation
//                               [pie showAnimation];
//                               [weakSelf.view addSubview:closeBtn];
//                               
//                               if (bigMeterCompleteNum+bigMeterUnCompleteNum < 1) {
//                                   [SCToastView showInView:self.view text:@"暂无数据，请更新\n温馨提示:左下角更新" duration:2 autoHide:YES];
//                               }
//                           }else if (selectedIndex == 1) {
//                               
//                               pie.valueArr = smallMeterNumArr;
//                               pie.descArr = @[@"小表已抄",@"小表未抄"];
//                               
//                               [weakSelf.view addSubview:pie];
//                               [pie showAnimation];
//                               [weakSelf.view addSubview:closeBtn];
//                               if (litMeterUnCompleteNum+litMeterUnCompleteNum < 1) {
//                                   
//                                   [SCToastView showInView:self.view text:@"暂无数据，请更新\n温馨提示:左下角更新" duration:2 autoHide:YES];
//                               }
//                           }
//                           
//                       } dismissBlock:^{
//                           
//                           NSLog(@"user canceled. do nothing.");
//                           
//                       }];
    
}

//关闭饼状图
- (void)closeAction {
    if (pie) {
        
        [UIView animateWithDuration:.5 animations:^{
            pie.alpha = .3;
            pie.transform = CGAffineTransformMakeScale(.01, .01);
        } completion:^(BOOL finished) {
            [pie removeFromSuperview];
            pie = nil;
        }];
        
    }
    if (closeBtn) {
        [closeBtn removeFromSuperview];
    }
}

//切换按钮
- (void)setSelectBtn :(UIButton *)sender{
    
    __weak typeof (self) weakSelf = self;
    [FTPopOverMenu showForSender:sender
                        withMenu:@[@"大表",@"小表",@"分享"]
                  imageNameArray:@[@"icon_bigMeter",@"icon_smallMeter",@"share_icon.png"]
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           if (selectedIndex == 0) {
                               
                               if (weakSelf.tableView) {
                                   
                                   weakSelf.tableView.hidden = NO;
                               }
                               
                               [timer invalidate];
                               [weakSelf setTimer];
                               isBigMeter = YES;
                               bmkViewTag = 300;
                               [_bmkMapView removeAnnotations:_annomationArray];
                               
                               for (int i = 0; i < _bigMeterDataArr.count; i++) {
                                   
                                   BMKPointAnnotation* bigMeterAnnotation = [[BMKPointAnnotation alloc]init];
                                   CLLocationCoordinate2D coor;
                                   coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
                                   coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
                                   bigMeterAnnotation.coordinate = coor;
                                   [_bmkMapView addAnnotation:bigMeterAnnotation];
                                   [_annomationArray addObject:bigMeterAnnotation];
                                   bmkViewTag++;
                               }
                           }else if (selectedIndex == 1) {
                               
                               if (weakSelf.tableView) {
                                   
                                   weakSelf.tableView.hidden = YES;
                               }
                               
                               [timer invalidate];
                               [weakSelf setTimer];
                               isBigMeter = NO;
                               bmkViewTag = 300;
                               [_bmkMapView removeAnnotations:_annomationArray];
                               
                               for (int i = 0; i < _litMeterDataArr.count; i++) {
                                   
                                   BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                                   CLLocationCoordinate2D coor;
                                   coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
                                   coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
                                   annotation.coordinate = coor;
                                   [_bmkMapView addAnnotation:annotation];
                                   [_annomationArray addObject:annotation];
                                   bmkViewTag++;
                               }
                           }else if (selectedIndex == 2) {
                               
                               [weakSelf selectRightAction:sender];
                           }
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
    
    
}


//设置导航栏颜色
-(void)setNavColor{
    self.navigationController.navigationBar.barStyle     = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = COLORRGB(226, 107, 16);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


#pragma mark - requestData
//请求水表抄收数据
- (void)_requestMeterData {
    
    [LSStatusBarHUD showLoading:@"请稍等..."];
    if (refreshBtn) {
        
        [refreshBtn removeFromSuperview];
        refreshBtn = nil;
    }
    
    NSString *mapMeterDataUrl                 = [NSString stringWithFormat:@"%@/Meter_Reading/MapComplete_Servlet",litMeterApi];
    
    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    NSURLSessionTask *meterTask               = [manager GET:mapMeterDataUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [LSStatusBarHUD hideLoading];
        [LSStatusBarHUD showMessage:@"加载成功"];
        
        if (responseObject) {
            
            NSError *error;
            
            for (NSDictionary *responseDic in responseObject) {
                
                _mapDataModel = [[MapDataModel alloc] initWithDictionary:responseDic error:&error];
                
                
                [weakSelf.infoDataArr addObject:_mapDataModel];
            }
            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
            FMDatabase *db = [FMDatabase databaseWithPath:fileName];
            if ([db open]) {
                
                for (int i = 0; i < weakSelf.infoDataArr.count; i++) {
                    
                    [db executeUpdate:@"replace into meter_info_senior (area_id, area_name, bs, collect_dt, collect_img_name1, collect_img_name2, collect_num, x, y, install_addr, meter_id) values (?,?,?,?,?,?,?,?,?,?,?);",((MapDataModel *)weakSelf.infoDataArr[i]).area_id, ((MapDataModel *)weakSelf.infoDataArr[i]).area_name, ((MapDataModel *)weakSelf.infoDataArr[i]).bs,((MapDataModel *)weakSelf.infoDataArr[i]).collect_dt, ((MapDataModel *)weakSelf.infoDataArr[i]).collect_img_name1, ((MapDataModel *)weakSelf.infoDataArr[i]).collect_img_name2, ((MapDataModel *)weakSelf.infoDataArr[i]).collect_num, ((MapDataModel *)weakSelf.infoDataArr[i]).x, ((MapDataModel *)weakSelf.infoDataArr[i]).y,((MapDataModel *)weakSelf.infoDataArr[i]).install_addr, ((MapDataModel *)weakSelf.infoDataArr[i]).meter_id];
                }
            }else{
                [SCToastView showInView:self.view text:@"本地库更新失败" duration:2 autoHide:YES];
            }
            
            weakSelf.bigMeterDataArr = [weakSelf getInforFromDB :0];
            weakSelf.litMeterDataArr = [weakSelf getInforFromDB :1];
            
            if (isBigMeter) {
                
                
                for (int i = 0; i < weakSelf.bigMeterDataArr.count; i++) {
                    
                    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                    CLLocationCoordinate2D coor;
                    coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
                    coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
                    annotation.coordinate = coor;
                    [_bmkMapView addAnnotation:annotation];
                    [_annomationArray addObject:annotation];
                }
            } else {
                for (int i = 0; i < weakSelf.litMeterDataArr.count; i++) {
                    
                    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                    CLLocationCoordinate2D coor;
                    coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
                    coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
                    annotation.coordinate = coor;
                    [_bmkMapView addAnnotation:annotation];
                    [_annomationArray addObject:annotation];
                }
            }
            [weakSelf setTimer];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [LSStatusBarHUD hideLoading];
        if (error.code == -1004) {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"服务器连接失败"] duration:1.5 autoHide:YES];
        }else {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"数据加载失败！\n%@",[error description]] duration:1.5 autoHide:YES];
            
        }
        
        if (!refreshBtn) {
            
            refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, PanScreenHeight - 50 - 59, 50, 50)];
            [refreshBtn setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
            [refreshBtn addTarget:self action:@selector(_requestMeterData) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:refreshBtn];
        }
        
    }];
    
    [meterTask resume];
}

- (NSMutableArray *)getInforFromDB :(NSInteger)bs{
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if ([db open]) {
        FMResultSet *resultSet;
        if (bs == 0) {
            resultSet = [db executeQuery:@"select *from meter_info_senior where area_id = '00' order by id"];
        }else {
            resultSet = [db executeQuery:@"select *from meter_info_senior where area_id != '00' order by id"];
        }
        
        while ([resultSet next]) {
            
            NSString *area_id               = [resultSet stringForColumn:@"area_id"];
            NSString *area_name             = [resultSet stringForColumn:@"area_name"];
            NSString *bs                    = [resultSet stringForColumn:@"bs"];
            NSString *collect_dt            = [resultSet stringForColumn:@"collect_dt"];
            NSString *collect_img_name1     = [resultSet stringForColumn:@"collect_img_name1"];
            NSString *collect_img_name2     = [resultSet stringForColumn:@"collect_img_name2"];
            NSString *collect_num           = [resultSet stringForColumn:@"collect_num"];
            NSString *x                     = [resultSet stringForColumn:@"x"];
            NSString *y                     = [resultSet stringForColumn:@"y"];
            NSString *install_addr          = [resultSet stringForColumn:@"install_addr"];
            NSString *meter_id              = [resultSet stringForColumn:@"meter_id"];
            
            MapDataModel *model         = [[MapDataModel alloc] init];
            model.area_id               = [NSString stringWithFormat:@"%@",area_id];
            model.area_name             = [NSString stringWithFormat:@"%@",area_name];
            model.bs                    = [NSString stringWithFormat:@"%@",bs];
            model.collect_dt            = [NSString stringWithFormat:@"%@",collect_dt];
            model.collect_img_name1     = [NSString stringWithFormat:@"%@",collect_img_name1];
            model.collect_img_name2     =[NSString stringWithFormat:@"%@",collect_img_name2];
            model.collect_num           = [NSString stringWithFormat:@"%@",collect_num];
            model.x                     = [NSString stringWithFormat:@"%@",x];
            model.y                     = [NSString stringWithFormat:@"%@",y];
            model.install_addr          = [NSString stringWithFormat:@"%@",install_addr];
            model.meter_id              = [NSString stringWithFormat:@"%@",meter_id];
            [arr addObject:model];
        }
        
    }
    return arr;
}

//请求水表抄收数据
- (void)_requestBigMeterData :(NSString *)install_addr{
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    [_bigMeterDetailArr removeAllObjects];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select *from meter_info_senior where install_addr = '%@' order by id",install_addr]];

        while ([resultSet next]) {
            
            NSString *area_id               = [resultSet stringForColumn:@"area_id"];
            NSString *area_name             = [resultSet stringForColumn:@"area_name"];
            NSString *bs                    = [resultSet stringForColumn:@"bs"];
            NSString *collect_dt            = [resultSet stringForColumn:@"collect_dt"];
            NSString *collect_img_name1     = [resultSet stringForColumn:@"collect_img_name1"];
            NSString *collect_img_name2     = [resultSet stringForColumn:@"collect_img_name2"];
            NSString *collect_num           = [resultSet stringForColumn:@"collect_num"];
            NSString *x                     = [resultSet stringForColumn:@"x"];
            NSString *y                     = [resultSet stringForColumn:@"y"];
            NSString *install_addr          = [resultSet stringForColumn:@"install_addr"];
            NSString *meter_id              = [resultSet stringForColumn:@"meter_id"];
            
            MapDataModel *model         = [[MapDataModel alloc] init];
            model.area_id               = [NSString stringWithFormat:@"%@",area_id];
            model.area_name             = [NSString stringWithFormat:@"%@",area_name];
            model.bs                    = [NSString stringWithFormat:@"%@",bs];
            model.collect_dt            = [NSString stringWithFormat:@"%@",collect_dt];
            model.collect_img_name1     = [NSString stringWithFormat:@"%@",collect_img_name1];
            model.collect_img_name2     =[NSString stringWithFormat:@"%@",collect_img_name2];
            model.collect_num           = [NSString stringWithFormat:@"%@",collect_num];
            model.x                     = [NSString stringWithFormat:@"%@",x];
            model.y                     = [NSString stringWithFormat:@"%@",y];
            model.install_addr          = [NSString stringWithFormat:@"%@",install_addr];
            model.meter_id              = [NSString stringWithFormat:@"%@",meter_id];
            
            [self.bigMeterDetailArr addObject:model];
        }
        if (self.bigMeterDetailArr.count>0) {
            
            [self initTableView];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - initBaiDuMap...
//初始化地图
- (void)initMapView {
    
    _bmkMapView             = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _locService             = [[BMKLocationService alloc] init];
    
//    _bmkMapView.delegate    = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
//    _locService.delegate    = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    //设置地图类型
    _bmkMapView.mapType            = BMKMapTypeStandard;
    //罗盘模式
    _bmkMapView.userTrackingMode   = BMKUserTrackingModeFollowWithHeading;
    //显示当前位置
    _bmkMapView.showsUserLocation  = YES;
    // 设定是否显式比例尺
    _bmkMapView.showMapScaleBar    = YES;
    
//    self.view                      = _bmkMapView;
    [self.view addSubview:_bmkMapView];
    
    [self initDirectionBtn];
    [self initlayerBtn];
}

//切换视角btn
- (void)initDirectionBtn {
    
    UIButton *directionBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15 - 40 - 49, 40, 40)];
    
    [directionBtn setImage:[UIImage imageNamed:@"icon_direction@2x"] forState:UIControlStateNormal];
    
    directionBtn.backgroundColor    = [UIColor whiteColor];
    
    directionBtn.layer.cornerRadius = 5;
    
    directionBtn.alpha              = .8f;
    
    [directionBtn addTarget:self action:@selector(directionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_bmkMapView addSubview:directionBtn];
}

//设定定位模式
- (void)directionAction {
    
    _bmkMapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    
    [_bmkMapView updateFocusIfNeeded];
}
//切换地图类型（标准、卫星）
- (void)initlayerBtn {
    
    UIButton *layerBtn       = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15*2 - 40*2 - 49, 40, 40)];
    
    layerBtn.backgroundColor = [UIColor whiteColor];
    
    [layerBtn setImage:[UIImage imageNamed:@"icon_layer@2x"] forState:UIControlStateNormal];
    
    layerBtn.layer.cornerRadius = 5;
    
    layerBtn.alpha              = .8f;
    
    [layerBtn addTarget:self action:@selector(layerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:layerBtn];
}

//切换图层
- (void)layerAction :(BOOL)type{
    
    _bmkMapView.mapType = map_type ? BMKMapTypeSatellite:BMKMapTypeStandard;
    
    map_type            = !map_type;
}

//代理
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_bmkMapView viewWillAppear];
    
    _bmkMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    bmkViewTag           = 300;
}

//置空
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_bmkMapView viewWillDisappear];
    _bmkMapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    
    if (imageViewBtn) {
        
        [self removeImageBtn];
    }
}

#pragma mark - BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_bmkMapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_bmkMapView updateLocationData:userLocation];
}

#pragma mark - changeIcon
//设置定时器
- (void)setTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    [timer fire];
}

//不断更改图标以实现图表闪烁效果
- (void)changeImage {
    
    [_bmkMapView removeAnnotations:_annomationArray];
    UIImage *image1 = [UIImage imageNamed:@"icon_bigMeter_uncomplete"];
    UIImage *image2 = [UIImage imageNamed:@"icon_bigMeter"];
    UIImage *image3 = [UIImage imageNamed:@"icon_smallMeter_uncomplete"];
    UIImage *image4 = [UIImage imageNamed:@"icon_smallMeter"];
    if (isBigMeter) {
        bmkViewTag = 300;
        if (flag) {
            
            bmkImage = image1;
        }else {
            
            bmkImage = image2;
        }
        for (int i = 0; i < _bigMeterDataArr.count; i++) {
            
            BMKPointAnnotation* bigMeterAnnotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
            bigMeterAnnotation.coordinate = coor;
            [_bmkMapView addAnnotation:bigMeterAnnotation];
            [_annomationArray addObject:bigMeterAnnotation];
            bmkViewTag++;
        }
    }else {
        
        bmkViewTag = 300;
        if (flag) {
            bmkImage = image3;
        }else {
            
            bmkImage = image4;
        }
        for (int i = 0; i < _litMeterDataArr.count; i++) {
            
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
            annotation.coordinate = coor;
            [_bmkMapView addAnnotation:annotation];
            [_annomationArray addObject:annotation];
            bmkViewTag++;
        }
    }
    flag = !flag;
}

#pragma mark - BMKMapViewDelegate
// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {

        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        
        if (isBigMeter) {
            
            [newAnnotationView setImage:bmkImage];
        } else {
            
            [newAnnotationView setImage:bmkImage];
        }
        
//        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        newAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];
        
        paopaoBgView                    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 80)];
        
        paopaoBgView.layer.cornerRadius = 10;
        
        paopaoBgView.backgroundColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        
        UIImageView *iconImgV           = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        
        iconImgV.image                  = [UIImage imageNamed:@"AppIcon60x60"];
        
        [paopaoBgView addSubview:iconImgV];
        
        UIView *v2         = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 290, 1)];
        
        v2.backgroundColor = [UIColor lightGrayColor];
        
        [paopaoBgView addSubview:v2];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, 215, 25)];
        
        if (isBigMeter) {
            
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                
                label.text = [((MapDataModel *)_bigMeterDataArr[_bigMeterDataArr.count-1]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }else {
                
                label.text = [((MapDataModel *)_bigMeterDataArr[bmkViewTag - 300]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }
        }else {
            
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                
                label.text = [((MapDataModel *)_litMeterDataArr[_litMeterDataArr.count-1]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }else {
                
                label.text = [((MapDataModel *)_litMeterDataArr[bmkViewTag - 300]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }
        }
        [paopaoBgView addSubview:label];
        
        UIView *v1         = [[UIView alloc]initWithFrame:CGRectMake(75, 41, 210, 1)];
        
        v1.backgroundColor = [UIColor lightGrayColor];
        
        [paopaoBgView addSubview:v1];
        
        UITextView *addressLbl  = [[UITextView alloc]initWithFrame:CGRectMake(75, 40, 215, 40)];
        addressLbl.font         = [UIFont systemFontOfSize:12];
        
        //NSLog(@"大表数据个数：%ld  小表数据个数：%ld", _bigMeterDataArr.count, _litMeterDataArr.count);
        if (isBigMeter) {
            
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_bigMeterDataArr[_bigMeterDataArr.count-1]).install_addr];
            }else {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_bigMeterDataArr[bmkViewTag - 300]).install_addr];
            }
            
        } else {
            
            if (bmkViewTag-300 >= _litMeterDataArr.count) {
                
                addressLbl.text = [NSString stringWithFormat:@"所属区域：%@",((MapDataModel *)_litMeterDataArr[_litMeterDataArr.count-1]).area_id];
            }else {
                
                addressLbl.text = [NSString stringWithFormat:@"所属区域：%@",((MapDataModel *)_litMeterDataArr[bmkViewTag - 300]).area_id];
            }
        }
        addressLbl.backgroundColor        = [UIColor clearColor];
        addressLbl.textAlignment          = NSTextAlignmentLeft;
        addressLbl.userInteractionEnabled = NO;
        [paopaoBgView addSubview:addressLbl];
        
        BMKActionPaopaoView *paopaoView  = [[BMKActionPaopaoView alloc]initWithCustomView:paopaoBgView];
        
        newAnnotationView.paopaoView     = paopaoView;
        
        newAnnotationView.paopaoView.tag = bmkViewTag;
        
        
        return newAnnotationView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    
    [timer invalidate];
    if (!isBigMeter) {
        
        MapDataDetailViewController *mapDataVC = [[MapDataDetailViewController alloc] init];
        mapDataVC.hidesBottomBarWhenPushed = YES;
        
        if (view.paopaoView.tag-300 >= _litMeterDataArr.count) {
            
            mapDataVC.collect_area_bs = ((MapDataModel *)_litMeterDataArr[_litMeterDataArr.count - 1]).area_id;
            [self.navigationController showViewController:mapDataVC sender:nil];
        }else {
            
            mapDataVC.collect_area_bs = ((MapDataModel *)_litMeterDataArr[view.paopaoView.tag - 300]).area_id;
            [self.navigationController showViewController:mapDataVC sender:nil];
        }
    } else {
        if (view.paopaoView.tag - 300 > _bigMeterDataArr.count) {
            [self _requestBigMeterData:((MapDataModel *)_bigMeterDataArr[_bigMeterDataArr.count - 1]).install_addr];
        }else {
            
            [self _requestBigMeterData:((MapDataModel *)_bigMeterDataArr[view.paopaoView.tag - 300]).install_addr];
        }
    }
}

- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState fromOldState:(BMKAnnotationViewDragState)oldState {

    //    BMKAnnotationViewDragStateNone = 0,      ///< 静止状态.
    //    BMKAnnotationViewDragStateStarting,      ///< 开始拖动
    //    BMKAnnotationViewDragStateDragging,      ///< 拖动中
    //    BMKAnnotationViewDragStateCanceling,     ///< 取消拖动
    //    BMKAnnotationViewDragStateEnding         ///< 拖动结束
    if (oldState == BMKAnnotationViewDragStateStarting) {
        [timer invalidate];
    } else if (oldState == BMKAnnotationViewDragStateDragging) {
        [timer invalidate];
    } else if (oldState == BMKAnnotationViewDragStateEnding) {
        [timer fire];
    }
}
////委托
//- (BMKOverlayView*)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
//{
//    if([overlay isKindOfClass:[BMKCircle class]])
//    {
//        BMKCircle* circleView = [[BMKCircle alloc] initWithOverlay:overlay];
//        circleView.fillColor = [[UIColorcyanColor] colorWithAlphaComponent:0.5];
//        circleView.strokeColor = [[UIColorblueColor] colorWithAlphaComponent:0.5];
//        circleView.lineWidth = 10.0;
//        return circleView;
//    }
//    returnnil;
//    
//}
- (void)mapStatusDidChanged:(BMKMapView *)mapView {
    
    _tableView.hidden = YES;

    //检测地图的放大倍率
    if (mapView.getMapStatus.fLevel >13.0f) {
        
    }
}

#pragma mark - tableView

- (void)initTableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(PanScreenWidth-295, 75, 290, 150)];
        _tableView.clipsToBounds        = YES;
        _tableView.layer.cornerRadius   = 8;
        _tableView.alpha                = .8f;
        _tableView.backgroundColor      = [UIColor clearColor];
    }
    
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.hidden     = NO;
    
    [_tableView registerNib:[UINib nibWithNibName:@"BigMeterDetailCell" bundle:nil] forCellReuseIdentifier:@"bigMeterDetailCellID"];
    
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bigMeterDetailArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BigMeterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bigMeterDetailCellID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BigMeterDetailCell" owner:self options:nil] lastObject];
    }
    cell.mapDataModel = self.bigMeterDetailArr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (((MapDataModel *)self.bigMeterDetailArr[indexPath.row]).collect_img_name1) {
        
        if (!imageViewBtn) {

            imageViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64 - 49)];
            [[UIApplication sharedApplication].keyWindow addSubview:imageViewBtn];

            /*
            //1.获取一个全局串行队列
             dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //2.把任务添加到队列中执行
             dispatch_async(queue, ^{
                 
                 //3.从网络上下载图片
            
                 NSURL *urlstr   = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,((MapDataModel *)self.bigMeterDetailArr[indexPath.row]).collect_img_name1]];
           
                 NSData *data    = [NSData dataWithContentsOfURL:urlstr];
            
                 UIImage *image  = [UIImage imageWithData:data];
                 
                 [AnimationView dismiss];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [imageViewBtn setImage:image forState:UIControlStateNormal];
                 });
            });
             */
            NSURL *urlstr   = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,((MapDataModel *)self.bigMeterDetailArr[indexPath.row]).collect_img_name1]];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:urlstr options:SDWebImageRetryFailed  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
                [SVProgressHUD showProgress:receivedSize/expectedSize];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                [imageViewBtn setImage:image forState:UIControlStateNormal];
                [SVProgressHUD dismiss];
            }];
            
            
            [imageViewBtn addTarget:self action:@selector(removeImageBtn) forControlEvents:UIControlEventTouchUpInside];
        }
        imageViewBtn.transform = CGAffineTransformMakeScale(.01, .01);
        imageViewBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5];
        [UIView animateWithDuration:.5 animations:^{
            imageViewBtn.transform = CGAffineTransformIdentity;
        }];
    }
    
}

- (void)removeImageBtn {

    imageViewBtn.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:.5 animations:^{
        imageViewBtn.alpha = 0;
        imageViewBtn.transform = CGAffineTransformMakeScale(.01, .01);
    } completion:^(BOOL finished) {
        [imageViewBtn removeFromSuperview];
        imageViewBtn = nil;
    }];
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
