//
//  LitMeterDetailViewController.m
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailViewController.h"
#import "LitMeterDetailDataModel.h"
#import "WYLineChartView.h"
#import "WYLineChartPoint.h"

@interface LitMeterDetailViewController ()
<
WYLineChartViewDelegate,
WYLineChartViewDatasource
>
{
    UIView *lightDarkView;
    NSMutableArray *dataArr;
    NSMutableArray *_points;
    NSMutableArray *chartDataArr;
    CGFloat max;
    CGFloat gap;
    NSURLSessionTask *_task;
}

@property (nonatomic, strong) WYLineChartView *chartView;
@property (nonatomic, strong) UILabel *touchLabel;

@end

@implementation LitMeterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"小表户表信息";
    self.view.backgroundColor = [UIColor colorWithRed:44/255.0f green:147/255.0f blue:209/255.0f alpha:1];

    [self initShareBtn];
    
//    UIButton *saveBtn             = [[UIButton alloc] initWithFrame:CGRectMake(20, PanScreenHeight - 49 - 20, 100, 35)];
//    saveBtn.backgroundColor       = [UIColor colorWithRed:121/255.0f green:180/255.0f blue:76/255.0f alpha:1];
//    saveBtn.layer.cornerRadius    = 10;
//    saveBtn.layer.shadowOffset    = CGSizeMake(1, 1);
//    saveBtn.layer.shadowColor     = [[UIColor blackColor]CGColor];
//    saveBtn.layer.shadowOpacity   = .80f;
//    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
//    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.view addSubview:saveBtn];
//    
//    UIButton *nextBtn             = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 100 - 20, PanScreenHeight - 49 - 20, 100, 35)];
//    nextBtn.backgroundColor       = [UIColor colorWithRed:121/255.0f green:180/255.0f blue:76/255.0f alpha:1];
//    nextBtn.layer.cornerRadius    = 10;
//    nextBtn.layer.shadowOffset    = CGSizeMake(1, 1);
//    nextBtn.layer.shadowColor     = [[UIColor blackColor]CGColor];
//    nextBtn.layer.shadowOpacity   = .80f;
//    [nextBtn setTitle:@"重置" forState:UIControlStateNormal];
//    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.view addSubview:nextBtn];
    
    
    if (self.meter_ID) {
        [self requestData:self.meter_ID];
        [self getValue];
    } else {
        [SVProgressHUD showInfoWithStatus:@"用户名为空！" maskType:SVProgressHUDMaskTypeGradient];
        [self queryFail];
    }
    
}

//分享item
- (void)initShareBtn {
    
    UIButton *rightButton       = [[UIButton alloc]initWithFrame:CGRectMake(0,0,57,45)];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    rightButton.tintColor       = [UIColor redColor];
    
    [rightButton setImage:[UIImage imageNamed:@"icon_share@3x"]forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(selectRightAction:)forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem  = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)selectRightAction:(UIButton *)sender
{
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"小表户表信息"
                                                image:[ShareSDK jpegImageWithImage:[self getSnapshotImage] quality:1]
                                                title:@"小表户表信息截图"
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    if (_task) {
        [_task cancel];
    }
}

- (void)initChatView {
    
    _chartView                          = [[WYLineChartView alloc] initWithFrame:CGRectMake(0, 260, PanScreenWidth, 230)];
    _chartView.delegate                 = self;
    _chartView.datasource               = self;
    _chartView.gradientColors           = @[[UIColor colorWithWhite:1.0 alpha:0.9],
                                  [UIColor colorWithWhite:1.0 alpha:0.0]];
    _chartView.gradientColorsLocation   = @[@(0.0), @(0.95)];
    _chartView.drawGradient             = YES;
    _chartView.scrollable               = YES;
    _chartView.pinchable                = YES;
    _chartView.lineStyle                = kWYLineChartMainBezierWaveLine;
    _chartView.yAxisHeaderPrefix        = @"数据";
    _chartView.yAxisHeaderSuffix        = @"日期";
    _chartView.touchPointColor          = [UIColor redColor];
    gap = 100.f;
    
    _touchLabel                     = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _touchLabel.backgroundColor     = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    _touchLabel.textColor           = [UIColor blackColor];
    _touchLabel.layer.cornerRadius  = 5;
    _touchLabel.layer.masksToBounds = YES;
    _touchLabel.textAlignment       = NSTextAlignmentCenter;
    _touchLabel.font                = [UIFont systemFontOfSize:13.f];
    _chartView.touchView            = _touchLabel;
    
    
}

- (void)getValue {
    self.user_addr.text         = _user_addr_str;
    self.user_name.text         = _user_name_str;
    self.collect_id.text        = _collect_id_str;
    self.water_type.text        = _water_type_str;
    self.phone_num.text         = _phone_num_str;
    self.location.text          = _location_str;
    self.meter_condition.text   = _meter_condition_str;
    self.previous_reading.text  = _previous_reading_str;
    self.current_reading.text   = _current_reading_str;
    self.usage.text             = _usage_str;
    self.remark.text            = _remark_str;
}
- (void)queryFail {
    self.user_name.text         = [NSString stringWithFormat:@"户号：无法获取"];
    self.collect_id.text        = [NSString stringWithFormat:@"采集编号：无法获取"];
    self.water_type.text        = [NSString stringWithFormat:@"用水类型：无法获取"];
    self.phone_num.text         = [NSString stringWithFormat:@"手机：无法获取"];
    self.location.text          = [NSString stringWithFormat:@"位置：无法获取"];
    self.meter_condition.text   = [NSString stringWithFormat:@"表况：无法获取"];
    self.previous_reading.text  =[NSString stringWithFormat:@"上期读数：无法获取"];
    self.current_reading.text   = [NSString stringWithFormat:@"本期读数：无法获取"];
    self.usage.text             = [NSString stringWithFormat:@"本期用量：无法获取"];
    self.remark.text            = [NSString stringWithFormat:@"备注：无法获取"];
    self.user_addr.text         = @"地址：无";
}

- (void)startLoading {
    
    //刷新控件
    lightDarkView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    [self.view addSubview:lightDarkView];
    
    UIImageView *loadingView    = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loadingView.center          = lightDarkView.center;
    UIImage *image              = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loadingView setImage:image];
    [lightDarkView addSubview:loadingView];
    
}

- (void)requestData :(NSString *)meterID {
    
    [self startLoading];

    NSURLSessionConfiguration *config           = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager               = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFHTTPResponseSerializer *serializer        = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval   = 60;
    serializer.acceptableContentTypes           = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *litMeterDetailURL                 = [NSString stringWithFormat:@"%@/Small_Meter_Reading/HisSmall_DataServlet",litMeterApi];
    
    NSDictionary *parameters = @{
                                 @"user_id" : meterID
                                 };
    
    __weak typeof(self) weakSelf = self;
    
    _task = [manager POST:litMeterDetailURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            dataArr = [NSMutableArray array];
            [dataArr removeAllObjects];
            
            for (NSDictionary *dic in responseObject) {

                LitMeterDetailDataModel *litMeterModel = [[LitMeterDetailDataModel alloc] initWithDictionary:dic error:nil];
                [dataArr addObject:litMeterModel];
            }
            
            //按时间从小到大排
            NSMutableArray *arr = [NSMutableArray array];
            if (dataArr.count != 0) {
                
                for (int i = (int)dataArr.count-1 ; i>=0; i--) {
                    [arr addObject:dataArr[i]];
                }
                [dataArr removeAllObjects];
                for (int i = 0 ; i<=arr.count-1; i++) {
                    [dataArr addObject:arr[i]];
                }
            }
            
            if (dataArr.count == 6) {
                
                //添加图表数值
                _points = [NSMutableArray array];
                for (int i = 0; i < dataArr.count; i++) {
                    WYLineChartPoint *point = [[WYLineChartPoint alloc] init];
                    point.index = i;
                    [_points addObject:point];
                }
                
                
                chartDataArr = [NSMutableArray array];
                for (int i = 0; i < dataArr.count; i++) {
                    WYLineChartPoint *point = _points[i];
                    point.value             = [((LitMeterDetailDataModel *)dataArr[i]).collect_num integerValue];
                    [chartDataArr addObject:@(point.value)];
                }
                NSInteger maxValue  = [[chartDataArr valueForKeyPath:@"@max.intValue"] integerValue];
                max                 = maxValue;
                
                NSInteger num       = 0;
                for (int i = 0; i < dataArr.count; i++) {
                    num = num + [((LitMeterDetailDataModel*)dataArr[i]).collect_num integerValue];
                }
                if (num != 0) {
                    
                    [self initChatView];
                    _chartView.points = [NSArray arrayWithArray:_points];
                    NSLog(@"points:%@   _dataArr:%@", _points, chartDataArr);
                    [_chartView updateGraph];
                }else {
                    if (lightDarkView) {
                        [lightDarkView removeFromSuperview];
                    }
                    [SVProgressHUD showInfoWithStatus:@"暂无数据" maskType:SVProgressHUDMaskTypeGradient];
                }
            }else{
                [SVProgressHUD showInfoWithStatus:@"暂无数据" maskType:SVProgressHUDMaskTypeGradient];
            }
            
            //去除加载动画
            if (lightDarkView) {
                
                [UIView animateWithDuration:.35 animations:^{
                    
                    lightDarkView.transform = CGAffineTransformMakeScale(.01, .01);
                    
                } completion:^(BOOL finished) {
                    
                    [lightDarkView removeFromSuperview];
                    [weakSelf.view addSubview:_chartView];
                    _chartView.transform = CGAffineTransformMakeScale(.01, .01);
                    [UIView animateWithDuration:.35 animations:^{
                        _chartView.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (lightDarkView) {
            [lightDarkView removeFromSuperview];
        }
        [weakSelf queryFail];
        [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
        NSLog(@"小区户表信息页请求数据失败：\n%@",error);
    }];
    [_task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

//#pragma mark - XSChartDataSource,XSChartDelegate
//-(NSInteger)numberForChart:(XSChart *)chart
//{
//    return dataArr.count;
//}
//-(NSInteger)chart:(XSChart *)chart valueAtIndex:(NSInteger)index
//{
//    return [((LitMeterDetailDataModel *)dataArr[index]).collect_num floatValue];
//}
//-(BOOL)showDataAtPointForChart:(XSChart *)chart
//{
//    return YES;
//}
//-(NSString *)chart:(XSChart *)chart titleForXLabelAtIndex:(NSInteger)index
//{
//    NSString *xStr = [NSString stringWithFormat:@"%@",((LitMeterDetailDataModel *)dataArr[index]).collect_dt];
//    xStr = [xStr substringWithRange:NSMakeRange(5, 6)];
//    return xStr;
//}
//-(NSString *)titleForChart:(XSChart *)chart
//{
//    return @"周用量走势";
//}
//-(NSString *)titleForXAtChart:(XSChart *)chart
//{
//    return @"日期";
//}
//-(NSString *)titleForYAtChart:(XSChart *)chart
//{
//    return @"用量/吨";
//}
//-(void)chart:(XSChart *)view didClickPointAtIndex:(NSInteger)index
//{
//    [SCToastView showInView:self.view text:[NSString stringWithFormat:@"%@吨\n抄收时间：%@",((LitMeterDetailDataModel *)dataArr[index]).collect_num, ((LitMeterDetailDataModel *)dataArr[index]).collect_dt] duration:1.5 autoHide:YES];
//    NSLog(@"click at index:%ld",(long)index);
//}

#pragma mark - WYLineChartViewDelegate
- (NSInteger)numberOfLabelOnXAxisInLineChartView:(WYLineChartView *)chartView {
    return dataArr.count;
}

- (NSInteger)numberOfLabelOnYAxisInLineChartView:(WYLineChartView *)chartView {
    return dataArr.count;
}

- (CGFloat)gapBetweenPointsHorizontalInLineChartView:(WYLineChartView *)chartView {
    return gap;
}

//最大值里最顶端距离
- (CGFloat)maxValueForPointsInLineChartView:(WYLineChartView *)chartView {
    
    return max*6/5;
}

- (CGFloat)minValueForPointsInLineChartView:(WYLineChartView *)chartView {
    return max/3;
}
//左侧水表数据显示的个数(横线个数)
- (NSInteger)numberOfReferenceLineHorizontalInLineChartView:(WYLineChartView *)chartView {
    return 3;
}
//竖线的条数
- (NSInteger)numberOfReferenceLineVerticalInLineChartView:(WYLineChartView *)chartView {
    return _points.count;
}

#pragma mark - WYLineChartViewDatasource

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForXAxisLabelAtIndex:(NSInteger)index {
    NSMutableArray *tontextArr = [NSMutableArray array];
    [tontextArr removeAllObjects];
    for (int i = 0; i < dataArr.count; i++) {
        NSString *str = ((LitMeterDetailDataModel *)dataArr[i]).collect_dt;
        if (gap<130) {
            NSString *collectStr = [str substringWithRange:NSMakeRange(5, 5)];
            [tontextArr addObject:collectStr];
            
        }else {
            NSString *collectStr = [str substringWithRange:NSMakeRange(0, 10)];
            [tontextArr addObject:collectStr];
        }
    }
    return tontextArr[index];
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToXAxisLabelAtIndex:(NSInteger)index {
    return _points[index];
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToVerticalReferenceLineAtIndex:(NSInteger)index {
    
    return _points[index];
}
- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToHorizontalReferenceLineAtIndex:(NSInteger)index {
    CGFloat value;
    switch (index) {
        case 0:
            value = max;
            break;
        case 1:
            value = max/2;
            break;
        case 2:
            value = max/6;
            break;
        default:
            break;
    }
    return 0;
}


- (void)lineChartView:(WYLineChartView *)lineView didBeganTouchAtSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
    //    NSLog(@"began move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didMovedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
    //    NSLog(@"changed move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didEndedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
    //    NSLog(@"ended move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didBeganPinchWithScale:(CGFloat)scale {
    
    //    NSLog(@"begin pinch, scale : %f", scale);
}

- (void)lineChartView:(WYLineChartView *)lineView didChangedPinchWithScale:(CGFloat)scale {
    
    //    NSLog(@"change pinch, scale : %f", scale);
}
//当缩放结束后更新数据
- (void)lineChartView:(WYLineChartView *)lineView didEndedPinchGraphWithOption:(WYLineChartViewScaleOption)option scale:(CGFloat)scale {
        NSLog(@"change pinch, scale : %f", scale);
    if (gap*scale>10) {
        gap = gap*scale;
    }
}

@end
