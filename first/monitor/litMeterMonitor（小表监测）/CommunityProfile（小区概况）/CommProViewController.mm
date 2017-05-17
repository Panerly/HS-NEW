//
//  CommProViewController.m
//  first
//
//  Created by HS on 16/8/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CommProViewController.h"
#import "LitMeterDetailViewController.h"

#import "LitMeterModel.h"
#import "LitMeterDetailModel.h"
#import "CommProTableViewCell.h"

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>


@interface CommProViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    BOOL map_type;
    UIView *paopaoBgView;
    NSURLSessionTask *task;
    NSString *titleStr;
    int bmkViewTag;
}

@property (nonatomic, strong) NSMutableArray *dataArray;//存小区名


@end

@implementation CommProViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"小表概览";
    map_type   = YES;
    
    //禁止全屏滑动返回
    [MLTransition invalidate];
    
    [self initMapView];
    [self requestCommunityData];
}
- (void)initTableView {
    
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 75, 290, 150)];
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(PanScreenWidth-295, 75, 290, 150)];
        _tableView.clipsToBounds = YES;
        _tableView.layer.cornerRadius = 8;
        _tableView.alpha = .8f;
        
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    _tableView.delegate   = self;
    
    _tableView.dataSource = self;
    
    [_tableView registerNib:[UINib nibWithNibName:@"CommProTableViewCell" bundle:nil] forCellReuseIdentifier:@"commProIdenty"];
    
//    [paopaoBgView addSubview:_tableView];
    [self.view addSubview:_tableView];
}

//初始化地图
- (void)initMapView {
    
    _mapView             = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _locService          = [[BMKLocationService alloc] init];
    
    _mapView.delegate    = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    //设置地图类型
    _mapView.mapType           = BMKMapTypeStandard;
    //罗盘模式
    _mapView.userTrackingMode  = BMKUserTrackingModeFollowWithHeading;
    //显示当前位置
    _mapView.showsUserLocation = YES;
    
    _mapView.showMapScaleBar   = YES;
    
    self.view                  = _mapView;
    
    [self initDirectionBtn];
    [self initlayerBtn];
}

//请求小区数据(小区)
- (void)requestCommunityData {
    
    [LSStatusBarHUD showLoading:@"请稍等..."];
    
    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval = 20;
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *communityURL                    = [NSString stringWithFormat:@"%@/Small_Meter_Reading/Small_NumberServlet",litMeterApi];
    __weak typeof(self) weekSelf              = self;
    NSDictionary *para = @{
                           @"xqbh":[[NSUserDefaults standardUserDefaults] objectForKey:@"xqbh"]
                           };
    
    task                                      = [manager POST:communityURL parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [LSStatusBarHUD hideLoading];
        if (!weekSelf.dataArray) {
            weekSelf.dataArray = [NSMutableArray array];
        }
        if (responseObject) {

            NSError *error = nil;
            for (NSDictionary *dic in responseObject) {
                LitMeterModel *litMeterModel = [[LitMeterModel alloc] initWithDictionary:dic error:&error];
                [weekSelf.dataArray addObject:litMeterModel];
            }
        }
        
        
        // 添加一个PointAnnotation
        for (int i = 0; i < _dataArray.count; i++) {
            
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude         = [((LitMeterModel *)_dataArray[i]).y floatValue];
            coor.longitude        = [((LitMeterModel *)_dataArray[i]).x floatValue];
            annotation.coordinate = coor;
            [_mapView addAnnotation:annotation];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [LSStatusBarHUD hideLoading];

        [SVProgressHUD showInfoWithStatus:@"小区列表加载失败" maskType:SVProgressHUDMaskTypeGradient];
        
        NSLog(@"小区列表数据请求失败：\n%@",error);
    }];
    
    [task resume];
}
#pragma mark - request household data
- (void)requestHouseholdData :(NSString *)village_name {
    
    [AnimationView showInView:self.view];
    
    AFHTTPSessionManager *manager        = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval = 60;
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *communityURL            = [NSString stringWithFormat:@"%@/Small_Meter_Reading/Small_New_DataServlet",litMeterApi];
    __weak typeof(self) weekSelf = self;
    
    NSDictionary *parameters = @{
                                 @"name":village_name
                                 };
    
    NSURLSessionTask *houseHoldTask = [manager POST:communityURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            NSError *error = nil;
            [AnimationView dismiss];
            
            self.houseHoldArray = [NSMutableArray array];
            [self.houseHoldArray removeAllObjects];
            
            for (NSDictionary *dic in responseObject) {
                LitMeterDetailModel *model = [[LitMeterDetailModel alloc] initWithDictionary:dic error:&error];
                [self.houseHoldArray addObject:model];
            }
            weekSelf.tableView.hidden = NO;
            [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [AnimationView dismiss];
        [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
        NSLog(@"户列表数据请求失败：\n%@",error);
    }];
    [houseHoldTask resume];
}


//切换视角
- (void)initDirectionBtn {
    
    UIButton *directionBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15 - 40, 40, 40)];
    
    [directionBtn setImage:[UIImage imageNamed:@"icon_direction@2x"] forState:UIControlStateNormal];
    
    directionBtn.backgroundColor    = [UIColor whiteColor];
    
    directionBtn.layer.cornerRadius = 5;
    
    directionBtn.alpha              = .8f;
    
    [directionBtn addTarget:self action:@selector(directionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mapView addSubview:directionBtn];
}
//设定定位模式
- (void)directionAction {
    
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    
    [_mapView updateFocusIfNeeded];
}

//切换地图类型（标准、卫星）
- (void)initlayerBtn {
    
    UIButton *layerBtn       = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15*2 - 40*2, 40, 40)];
    
    layerBtn.backgroundColor = [UIColor whiteColor];
    
    [layerBtn setImage:[UIImage imageNamed:@"icon_layer@2x"] forState:UIControlStateNormal]; 
    
    layerBtn.layer.cornerRadius = 5;
    
    layerBtn.alpha              = .8f;
    
    [layerBtn addTarget:self action:@selector(layerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:layerBtn];
}

- (void)layerAction :(BOOL)type{
    
    _mapView.mapType = map_type ? BMKMapTypeSatellite:BMKMapTypeStandard;
    
    map_type         = !map_type;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    bmkViewTag = 200;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

#pragma mark - BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}


// Override

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {

        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        
        newAnnotationView.image        = [UIImage imageNamed:@"icon_pin"];
        
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示

        newAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];

//        paopaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 240)];
        paopaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 80)];
        
        paopaoBgView.layer.cornerRadius = 10;

        paopaoBgView.backgroundColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];

        UIImageView *iconImgV           = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];

        iconImgV.image                  = [UIImage imageNamed:@"AppIcon60x60"];

        [paopaoBgView addSubview:iconImgV];

        UIView *v2         = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 290, 1)];

        v2.backgroundColor = [UIColor lightGrayColor];

        [paopaoBgView addSubview:v2];

        [self initTableView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, 215, 25)];

        if (bmkViewTag-200 >= _dataArray.count) {
            label.text = ((LitMeterModel *)_dataArray[_dataArray.count-1]).small_name;
        }else {
            
            label.text = ((LitMeterModel *)_dataArray[bmkViewTag - 200]).small_name;
        }
        [paopaoBgView addSubview:label];

        UIView *v1         = [[UIView alloc]initWithFrame:CGRectMake(75, 41, 210, 1)];

        v1.backgroundColor = [UIColor lightGrayColor];

        [paopaoBgView addSubview:v1];

        UITextView *addressLbl = [[UITextView alloc]initWithFrame:CGRectMake(75, 40, 215, 40)];
        addressLbl.font = [UIFont systemFontOfSize:12];
        if (bmkViewTag-200 >= _dataArray.count) {
            addressLbl.text = [NSString stringWithFormat:@"地址：%@",((LitMeterModel *)_dataArray[_dataArray.count-1]).small_name];
        }else {
            addressLbl.text = [NSString stringWithFormat:@"地址：%@",((LitMeterModel *)_dataArray[bmkViewTag - 200]).small_name];
            NSLog(@"bmkViewTag:%d, 地址信息：%@", bmkViewTag, ((LitMeterModel *)_dataArray[bmkViewTag - 200]).small_name);
        }
        addressLbl.backgroundColor        = [UIColor clearColor];
        addressLbl.textAlignment          = NSTextAlignmentLeft;
        addressLbl.userInteractionEnabled = NO;
        [paopaoBgView addSubview:addressLbl];

        BMKActionPaopaoView *paopaoView  = [[BMKActionPaopaoView alloc]initWithCustomView:paopaoBgView];

        newAnnotationView.paopaoView     = paopaoView;

        newAnnotationView.paopaoView.tag = bmkViewTag;
        bmkViewTag++;

        return newAnnotationView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {

    if (view.paopaoView.tag-200 >= _dataArray.count) {
        
        [self requestHouseholdData:((LitMeterDetailModel *)_dataArray[_dataArray.count-1]).small_name];
        titleStr = ((LitMeterDetailModel *)_dataArray[_dataArray.count-1]).small_name;
    }else {
        
        [self requestHouseholdData:((LitMeterDetailModel *)_dataArray[view.paopaoView.tag - 200]).small_name];
        titleStr = ((LitMeterDetailModel *)_dataArray[view.paopaoView.tag - 200]).small_name;
    }
}

- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState fromOldState:(BMKAnnotationViewDragState)oldState {
//    _tableView.hidden = YES;
//    BMKAnnotationViewDragStateNone = 0,      ///< 静止状态.
//    BMKAnnotationViewDragStateStarting,      ///< 开始拖动
//    BMKAnnotationViewDragStateDragging,      ///< 拖动中
//    BMKAnnotationViewDragStateCanceling,     ///< 取消拖动
//    BMKAnnotationViewDragStateEnding         ///< 拖动结束
    if (newState == BMKAnnotationViewDragStateStarting) {
        [UIView animateWithDuration:.5 animations:^{
            _tableView.alpha = 0;
        }];
    } else if (newState == BMKAnnotationViewDragStateDragging) {
        [UIView animateWithDuration:.5 animations:^{
            _tableView.alpha = 0;
                        }];
    } else if (newState == BMKAnnotationViewDragStateEnding) {
        [UIView animateWithDuration:.5 animations:^{
            _tableView.alpha = 1;
        }];
    }
}
- (void)mapStatusDidChanged:(BMKMapView *)mapView {
    _tableView.hidden = YES;
    [AnimationView dismiss];
    //检测地图的放大倍率
    if (mapView.getMapStatus.fLevel >13.0f) {
        
    }
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 25)];
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 20)];
//    title.text = titleStr;
//    [headerView addSubview:title];
//    return headerView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.houseHoldArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
//    cell.backgroundColor = [UIColor clearColor];
//    cell.textLabel.font = [UIFont systemFontOfSize:13];
//    cell.textLabel.numberOfLines = 0;
//    cell.textLabel.text = [NSString stringWithFormat:@"条码号：110110110\n抄收时间：216-8-18\n浙江省杭州市江干区XXX小区%ld号%ld单元",(long)indexPath.row,(long)indexPath.row];
    CommProTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commProIdenty" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CommProTableViewCell" owner:self options:nil] lastObject];
    }
    cell.litMeterDetailModel = self.houseHoldArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    LitMeterDetailViewController *householdDetail = [[LitMeterDetailViewController alloc] init];
//    
//    [self.navigationController showViewController:householdDetail sender:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LitMeterDetailViewController *detailVC = [[LitMeterDetailViewController alloc] init];
    
    detailVC.meter_ID              = ((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).user_Id;
    detailVC.user_addr_str         = [NSString stringWithFormat:@"地址:%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).user_addr];
    detailVC.user_name_str         = [NSString stringWithFormat:@"户号:%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).user_Id];
    detailVC.collect_id_str        = [NSString stringWithFormat:@"采集编号：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).collect_no];
    
    detailVC.location_str          = [NSString stringWithFormat:@"所属区域：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).collector_area];
    detailVC.meter_condition_str   = [NSString stringWithFormat:@"表况：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).collect_Status];
    detailVC.previous_reading_str  = [NSString stringWithFormat:@"上期读数：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).up_collect_num];
    detailVC.current_reading_str   = [NSString stringWithFormat:@"本期读数：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).collect_num];
    detailVC.usage_str             = [NSString stringWithFormat:@"用量：%@",((LitMeterDetailModel *)_houseHoldArray[indexPath.row]).collect_yl];
    
    detailVC.remark_str            = [NSString stringWithFormat:@"备注：暂无"];
    detailVC.water_type_str        = [NSString stringWithFormat:@"用水类型：居民用水"];
    detailVC.phone_num_str         = [NSString stringWithFormat:@"手机：暂无"];
    
    [SVProgressHUD dismiss];
    [self.navigationController showViewController:detailVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
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
