//
//  QueryViewController.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "QueryViewController.h"
#import "QueryTableViewCell.h"
#import "SCViewController.h"
#import "QueryModel.h"
#import "KSDatePicker.h"

@interface QueryViewController ()<UITableViewDelegate,UITableViewDataSource,SCChartDataSource>

{
    NSString *identy;
    NSUserDefaults *defaults;
    SCChart *chartView;
    //流量读数y轴数据
    NSMutableArray *yFlowArr;
    //用于判断是显示流量or水表读数
    NSUInteger _flag;
    NSInteger selectedIndex;
    UIPinchGestureRecognizer *pinch;
    UIScrollView *scrollView;
    
    UIButton *dateBtn;
    UIButton *curveBtn;
    UIButton *moreBtn;
    
    //用于判断上下的时间段
    int nextPlus;
    int previousPlus;
    int nextMonth;
    int previousMonth;
}
@end

@implementation QueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"大表数据查询";
    self.switchBtn.selectedSegmentIndex = 0;

    [MLTransition invalidate];
    
    //设置时流量统计为默认值
    _flag = 0;
    
    [self _getSysTime];
    
    [self _setValue];
    
    [self _setTableView];
    
    [self _createCurveView];
    
    [self initShareBtn];
    
    [self requestDayData:_dayDateTime :_dayDateTime];
    
    self.dataArr    = [NSMutableArray array];
    self.xArr       = [NSMutableArray array];
    self.yArr       = [NSMutableArray array];
    yFlowArr        = [NSMutableArray array];
    
    [self initMoreBtn];
    
    nextPlus     = 0;
    previousPlus = 0;
    nextMonth    = 0;
    previousMonth= 0;
}

//更多btn
- (void)initMoreBtn {
    
    moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 10 - 50, PanScreenHeight - 10 - 50 - 49, 50, 50)];
    [moreBtn setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    curveBtn.hidden = YES;
    
    curveBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 10 - 50, PanScreenHeight - 10 * 2 - 50 * 2 - 49, 50, 50)];
    [curveBtn setImage:[UIImage imageNamed:@"icon_curve"] forState:UIControlStateNormal];
    [self.view insertSubview:curveBtn belowSubview:moreBtn];
    [curveBtn addTarget:self action:@selector(curveAction) forControlEvents:UIControlEventTouchUpInside];
    curveBtn.hidden = YES;
    
    dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 10 - 50, PanScreenHeight - 10 * 3 - 50 * 3 - 49, 50, 50)];
    [dateBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.view insertSubview:dateBtn belowSubview:curveBtn];
    [dateBtn addTarget:self action:@selector(dateAction) forControlEvents:UIControlEventTouchUpInside];
    dateBtn.hidden = YES;
}

//分享item
- (void)initShareBtn {
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,57,45)];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [rightButton setImage:[UIImage imageNamed:@"icon_share@3x"]forState:UIControlStateNormal];
    rightButton.tintColor = [UIColor redColor];
    [rightButton addTarget:self action:@selector(selectRightAction:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)selectRightAction:(UIButton *)sender
{
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"大表数据查询"
                                                image:[ShareSDK jpegImageWithImage:[self getSnapshotImage] quality:1]
                                                title:@"大表数据查询截图"
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

//获取系统时间
- (void)_getSysTime
{
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    _dayDateTime = [formatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *formatter_hour = [[NSDateFormatter alloc] init];
    [formatter_hour setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    _hourDateTime = [formatter_hour stringFromDate:[NSDate date]];
    
    NSDate* date1 = [[NSDate alloc] init];
    date1 = [date1 dateByAddingTimeInterval:-30*3600*24];
    _monthDateTime = [formatter stringFromDate:date1];
}

//设值
- (void)_setValue
{
    defaults      = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];
    
    self.manageMeterNum.text    = [NSString stringWithFormat:@"表编号: %@",self.meter_id];
    self.meterType.text         = [NSString stringWithFormat:@"表类型: %@",self.meterTypeValue];
    self.communicationType.text = [NSString stringWithFormat:@"口径: %@",self.communicationTypeValue];
    self.installAddr.text       = [NSString stringWithFormat:@"安装地址: %@",self.installAddrValue];
}

//设置代理
- (void)_setTableView
{
    identy = @"queryIdenty";
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

//创建曲线图&手势
- (void)_createCurveView
{
    if (nil == scrollView) {
        
        scrollView = [[UIScrollView alloc] init];
    }
    scrollView.scrollEnabled = YES;
    scrollView.zoomScale = 2;
    
    //添加缩放手势
    if (nil == pinch) {
        
        pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleAction:)];
    }
    [scrollView addGestureRecognizer:pinch];

    scrollView.contentSize = CGSizeMake(PanScreenWidth*2, 150);
    [_curveView addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_curveView.mas_left).with.offset(10);
        make.top.equalTo(_curveView.mas_top);
        make.right.equalTo(_curveView.right);
        make.bottom.equalTo(_curveView.bottom);
    }];
    
    if (self.dataArr.count > 10) {
        
        chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(self.view.frame.origin.x, 0,  PanScreenWidth*2.5, 150) withSource:self withStyle:SCChartLineStyle];
    }else {
        
        chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(self.view.frame.origin.x, 0,  PanScreenWidth*2.5, 150) withSource:self withStyle:SCChartLineStyle];
    }
    [chartView showInView:scrollView];
}

static CGFloat i = 1.0;

//缩放frame实现缩放表格
- (void)scaleAction:(UIPinchGestureRecognizer*)pinchs
{
    if (i == 0) {
        
        i = 1.0f;
    } else {
     
        if (pinchs.velocity < 0.0f) {
            
            i = i - 0.2*(pinchs.scale+1);
            if (i == 0) {
                i = 1.0;
            }
            if (i<=1) {
                i = 1.0;
            }
        }else
        {
            i = i + 0.2*pinchs.scale;
            if (i >= 50) {
                i = 50.0;
            }
        }
    }
    NSLog(@"缩放倍率：%f",i);
    
    scrollView.contentSize = CGSizeMake(PanScreenWidth*i, 150);
    
    [chartView removeFromSuperview];
    
    chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(0, 0,  PanScreenWidth*i, 150) withSource:self withStyle:SCChartLineStyle];
    
    [chartView showInView:scrollView];
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)SCChart_xLableArray:(SCChart *)chart {

    if (i < 2.1) {
        //空间太小 所以在4倍内显示数字
        NSMutableArray *array = [NSMutableArray array];
        [array removeAllObjects];
        for (int j = 0; j < _xArr.count; j++) {
            [array addObject:[NSString stringWithFormat:@"%d",j]];
        }
        return array;
    }
    //缩放至4到8倍时显示抄收小时数据
    else if (i >= 2.1 && i < 4) {
        NSMutableArray *array = [NSMutableArray array];
        [array removeAllObjects];
        for (int j = 0; j < _xArr.count; j++) {
            [array addObject:[_xArr[j] substringWithRange:NSMakeRange(10, 10)]];
        }
        return array;
    }
    //4倍以上有足够的空间 所以显示详细的时间
    NSMutableArray *array = [NSMutableArray array];
    [array removeAllObjects];
    for (int j = 0; j < _xArr.count; j++) {
        [array addObject:[_xArr[j] substringWithRange:NSMakeRange(2, 17)]];
    }
    return array;
}

//数值多重数组 Y轴值数组
- (NSArray *)SCChart_yValueArray:(SCChart *)chart {
    NSMutableArray *ary = [NSMutableArray array];
    NSString *unit;
    switch (self.switchBtn.selectedSegmentIndex) {
        case 0:
            unit = @"m³/h";
        break;
        case 1:
            unit = @"吨";
        break;
        case 2:
            unit = @"吨";
        default:
            break;
    }
    for (int i = 0; i <_yArr.count; i++) {
        NSString *num = _yArr[i];
        NSString *str = [NSString stringWithFormat:@"%@%@",num,unit];
        [ary addObject:str];
    }
    return @[ary];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)SCChart_ColorArray:(SCChart *)chart {
    return @[SCGreen,SCRed,SCBrown];
}

//判断显示横线条
- (BOOL)SCChart:(SCChart *)chart ShowHorizonLineAtIndex:(NSInteger)index {
    return YES;
}

static bool isClicked;
//详情视图
- (void)moreAction {
    
    if (isClicked == NO && selectedIndex == 0) {
        
        dateBtn.hidden  = NO;
        curveBtn.hidden = NO;
        
        dateBtn.transform = CGAffineTransformMakeScale(.01, .01);
        dateBtn.transform = CGAffineTransformMakeTranslation(0, 10 * 2 + 50 + 49);
        curveBtn.transform = CGAffineTransformMakeScale(.01, .01);
        curveBtn.transform = CGAffineTransformMakeTranslation(0, 10 + 49);
        
        //后添加
        [UIView animateWithDuration:.5 animations:^{
            
            dateBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:.3 animations:^{
            
            curveBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:.3 animations:^{
            dateBtn.transform = CGAffineTransformIdentity;
        }];
        [UIView animateWithDuration:.5 animations:^{
            curveBtn.transform = CGAffineTransformIdentity;
        }];
        
        
    }else {
        
        [self hideBtn];
    }
    isClicked = !isClicked;
    
}

//打开曲线图
- (void)curveAction {
    
        SCViewController *curveVC = [[SCViewController alloc] init];
    
        curveVC.xArr= _xArr;
    
        if (selectedIndex == 0) {
            curveVC.yArr = yFlowArr;
        }
        else if (selectedIndex == 1) {
            curveVC.xArr = _xArr;
            curveVC.yArr = _yArr;
        }
        else if (selectedIndex == 2) {
    
            curveVC.yArr = _yArr;
        }
        [self.navigationController showViewController:curveVC sender:nil];
}

//选取时间段进行检索
- (void)dateAction {
    
    KSDatePicker* picker = [[KSDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 300)];
    
    picker.appearance.radius = 5;
    
    //设置回调
    picker.appearance.resultCallBack = ^void(KSDatePicker* datePicker,NSDate* currentDate,KSDatePickerButtonType buttonType){
        
        if (buttonType == KSDatePickerButtonCommit) {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [self requestDayData:[formatter stringFromDate:currentDate] :[formatter stringFromDate:currentDate]];
        }
    };
    // 显示
    [picker show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

#pragma mark - chose Time
//前一天时间或者上个月的数据
- (IBAction)previousData:(UIButton *)sender {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    NSDateComponents *adcomps2 = [[NSDateComponents alloc] init];
    switch (selectedIndex) {
        case 0:
            
            previousPlus--;
            [adcomps setYear:0];
            [adcomps setMonth:0];
            [adcomps setDay:previousPlus + nextPlus];
            break;
        case 1:
            previousPlus--;
            [adcomps setYear:0];
            [adcomps setMonth:0];
            [adcomps setDay:previousPlus + nextPlus];
            break;
        case 2:
            previousMonth--;
            [adcomps setYear:0];
            [adcomps setMonth:previousMonth + nextMonth];
            [adcomps2 setMonth:previousMonth + nextMonth + 1];
            [adcomps setDay:0];
            break;
            
        default:
            break;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    NSString *newdateStr = [formatter stringFromDate:newdate];
    NSDate *newdate2 = [calendar dateByAddingComponents:adcomps2 toDate:[NSDate date] options:0];
    NSString *newdateStr2 = [formatter stringFromDate:newdate2];
    switch (selectedIndex) {
        case 0:
            [self requestDayData:newdateStr :newdateStr];
            break;
        case 1:
            [self requestHourData:newdateStr];
            break;
        case 2:
            [self requestData:newdateStr :newdateStr2];
            break;
            
        default:
            break;
    }
}
//后一天的数据或者下个月的数据
- (IBAction)nextData:(UIButton *)sender {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    NSDateComponents *adcomps2 = [[NSDateComponents alloc] init];
    switch (selectedIndex) {
        case 0:
            
            nextPlus++;
            [adcomps setYear:0];
            [adcomps setMonth:0];
            [adcomps setDay:previousPlus + nextPlus];
            break;
        case 1:
            
            nextPlus++;
            [adcomps setYear:0];
            [adcomps setMonth:0];
            [adcomps setDay:previousPlus + nextPlus];
            break;
        case 2:
            
            nextMonth++;
            [adcomps setYear:0];
            [adcomps setMonth:nextMonth + previousMonth];
            [adcomps2 setMonth:nextMonth + previousMonth + 1];
            [adcomps setDay:0];
            break;
            
        default:
            break;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    NSString *newdateStr = [formatter stringFromDate:newdate];
    
    NSDate *newdate2 = [calendar dateByAddingComponents:adcomps2 toDate:[NSDate date] options:0];
    NSString *newdateStr2 = [formatter stringFromDate:newdate2];
    switch (selectedIndex) {
        case 0:
            [self requestDayData:newdateStr :newdateStr];
            break;
        case 1:
            [self requestHourData:newdateStr];
            break;
        case 2:
            [self requestData:newdateStr :newdateStr2];
            break;
            
        default:
            break;
    }
}

//选择日用量或月用量的数据
- (IBAction)flowStatistics:(UISegmentedControl *)sender {
    
    selectedIndex = sender.selectedSegmentIndex;
    
    switch (sender.selectedSegmentIndex) {
            
        case 0://时流量查询（每十五分钟）
            self.previousLabel.text = @"前一天";
            self.nextLabel.text = @"后一天";
            curveBtn.hidden = YES;
            dateBtn.hidden = YES;
            [moreBtn setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
            [moreBtn removeTarget:self action:@selector(curveAction) forControlEvents:UIControlEventTouchUpInside];
            [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
            [self requestDayData:_dayDateTime :_dayDateTime];
            break;
            
        case 1://日流量查询(每小时流量)
            self.previousLabel.text = @"前一天";
            self.nextLabel.text = @"后一天";
            if (curveBtn.hidden == NO) {
                
                [self hideBtn];
            }else {
                dateBtn.hidden = YES;
                curveBtn.hidden = YES;
            }
            [moreBtn setImage:[UIImage imageNamed:@"icon_curve"] forState:UIControlStateNormal];
            [moreBtn removeTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
            [moreBtn addTarget:self action:@selector(curveAction) forControlEvents:UIControlEventTouchUpInside];
            [self requestHourData:_dayDateTime];
            
            break;
        case 2://月流量查询（每天）
            self.previousLabel.text = @"上个月";
            self.nextLabel.text = @"下个月";
            if (curveBtn.hidden == NO) {
                
                [self hideBtn];
            }else {
                dateBtn.hidden = YES;
                curveBtn.hidden = YES;
            }
            [moreBtn setImage:[UIImage imageNamed:@"icon_curve"] forState:UIControlStateNormal];
            [moreBtn removeTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
            [moreBtn addTarget:self action:@selector(curveAction) forControlEvents:UIControlEventTouchUpInside];
            [moreBtn setImage:[UIImage imageNamed:@"icon_curve"] forState:UIControlStateNormal];
            [self requestData:_monthDateTime :_dayDateTime];
        default:
            break;
    }
    
}
- (void)hideBtn {
    
    [UIView animateWithDuration:.5 animations:^{
        
        dateBtn.transform = CGAffineTransformMakeScale(.5, .5);
        dateBtn.transform = CGAffineTransformMakeTranslation(0, 10 * 2 + 50 + 49);
    } completion:^(BOOL finished) {
        
        dateBtn.hidden = YES;
        
    }];
    [UIView animateWithDuration:.3 animations:^{
        
        curveBtn.transform = CGAffineTransformMakeScale(.5, .5);
        curveBtn.transform = CGAffineTransformMakeTranslation(0, 10 + 49);
    } completion:^(BOOL finished) {
        
        curveBtn.hidden = YES;
    }];
}

#pragma mark - requestData
//请求一天每小时水表抄收数据
- (void)requestHourData:(NSString *)date {

    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/DateServlet",self.ip];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date":date,
                                 @"db":self.db
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {

            [SVProgressHUD showInfoWithStatus:@"加载成功" maskType:SVProgressHUDMaskTypeGradient];
            
            [_dataArr removeAllObjects];
            [_xArr removeAllObjects];
            [_yArr removeAllObjects];
            
            NSError *error = nil;
            
            CGFloat submit = 0;
            for (NSDictionary *dataDic in responseObject) {
                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dataDic error:&error];
                [self.dataArr addObject:queryModel];
                [_yArr addObject:queryModel.collect_num];
                [_xArr addObject:queryModel.collect_dt];
                submit = submit + [queryModel.collect_num floatValue];
            }
            
            if (submit == 0) {
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：暂无数据"];
            }else{
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：%0.2f",submit];
            }
            
            NSMutableArray *array = [NSMutableArray array];
            [array removeAllObjects];
            for (int i = 0; i < _xArr.count; i++) {
                if ( i < 10) {
                    [array addObject:[NSString stringWithFormat:@"%@ 0%d:00:00.0",[_xArr[i] substringWithRange:NSMakeRange(0, 10)],i]];
                }else{
                [array addObject:[NSString stringWithFormat:@"%@.0",_xArr[i]]];
                }
            }
            _xArr = array;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error] maskType:SVProgressHUDMaskTypeGradient];
    }];
    
    [task resume];
}

//查询月流量
- (void)requestData:(NSString *)fromDate :(NSString *)toDate
{

    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/DosServlet",self.ip];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date1":fromDate,
                                 @"date2":toDate,
                                 @"username":self.userName,
                                 @"db":self.db,
                                 @"password":self.passWord
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"count"]];
            if ([count isEqualToString:@"0"]) {
                [SVProgressHUD showInfoWithStatus:@"暂无数据"];
            }
            NSDictionary *meter1Dic = [responseObject objectForKey:@"meters"];

            NSError *error = nil;
            
            [self.dataArr removeAllObjects];
            [_xArr removeAllObjects];
            [_yArr removeAllObjects];
            
            CGFloat submit = 0;

            for (NSDictionary *dic in meter1Dic) {
                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dic error:&error];
                [self.dataArr addObject:queryModel];
                [_yArr addObject:queryModel.collect_num];
                [_xArr addObject:queryModel.collect_dt];
                submit = submit + [queryModel.collect_num floatValue];
            }
            
            if (submit == 0) {
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：暂无数据"];
            }else{
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：%0.2f",submit];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error]];
    }];
    
    [task resume];
}


//查询时流量
- (void)requestDayData:(NSString *)fromDate :(NSString *)toDate
{
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeGradient];
    defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];

    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/His5Servlet",self.ip];

    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date1":fromDate,
                                 @"date2":toDate,
                                 @"username":self.userName,
                                 @"db":self.db,
                                 @"password":self.passWord
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:@"加载成功" maskType:SVProgressHUDMaskTypeGradient];
            
            [yFlowArr removeAllObjects];
            [_yArr removeAllObjects];
            
            NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"count"]];
            if ([count isEqualToString:@"0"]) {
                [SVProgressHUD showInfoWithStatus:@"暂无数据" maskType:SVProgressHUDMaskTypeGradient];
            }
            
            NSDictionary *meter1Dic = [responseObject objectForKey:@"meters"];
            
            NSError *error = nil;
            
            [self.dataArr removeAllObjects];
            
            [_xArr removeAllObjects];
            
            for (NSDictionary *dic in meter1Dic) {

                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dic error:&error];
                [self.dataArr addObject:queryModel];
                [self.yArr addObject:queryModel.collect_avg];
                [yFlowArr addObject:queryModel.collect_num];
                [_xArr addObject:[dic objectForKey:@"collect_dt"]];
            }
            CGFloat submit = 0;
            submit = [yFlowArr.lastObject floatValue] - [yFlowArr.firstObject floatValue];
            
            if (submit == 0) {
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：暂无数据"];
            }else{
                
                weakSelf.flowStatisticsLabel.text = [NSString stringWithFormat:@"流量统计：%0.2f",submit];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error] maskType:SVProgressHUDMaskTypeGradient];
        
    }];
    
    [task resume];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QueryTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.queryModel = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n水表流量: %@m³/h\n\n水表读数: %@吨\n\n抄收时间: %@",((QueryModel *)self.dataArr[indexPath.row]).collect_avg, ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertController *alertDay = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n日用量: %@吨\n\n抄收时间: %@", ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *alertHour = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n时用量: %@吨\n\n抄收时间: %@", ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    
    switch (_switchBtn.selectedSegmentIndex) {
        case 0:
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            break;
        case 1:
            [alertHour addAction:action];
            [self presentViewController:alertHour animated:YES completion:^{
                
            }];
        break;
        case 2:
            [alertDay addAction:action];
            [self presentViewController:alertDay animated:YES completion:^{
                
            }];
            break;
        default:
            break;
    }
    
}

@end
