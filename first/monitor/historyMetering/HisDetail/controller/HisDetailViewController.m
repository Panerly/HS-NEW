//
//  HisDetailViewController.m
//  first
//
//  Created by HS on 16/6/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "HisDetailViewController.h"
#import "HisDetailTableViewCell.h"
#import "SCViewController.h"
#import "HisDetailModel.h"
#import "KSDatePicker.h"

@interface HisDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *hisDetailID;
    NSUserDefaults *defaults;
    UIImageView *loading;
    NSInteger dataCount;
    UILabel *loadingLabel;
}
@end

static CGFloat i = 0;

@implementation HisDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"历史抄见·户表信息";
    self.dataArr = [NSMutableArray array];
    
    [self _getUserInfo];
    
    [self _getValue];
    
    [self _setTableView];
    
    self.xArr = [NSMutableArray array];
    self.yArr = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    _formDate.text = time;
    _toDate.text = time;
    _flowStatistics.alpha = 0;
}

- (void)_getUserInfo
{
    defaults = [NSUserDefaults standardUserDefaults];
    self.userNameLabel = [defaults objectForKey:@"userName"];
    self.passWordLabel = [defaults objectForKey:@"passWord"];
    self.ipLabel = [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"];
}


//请求时间段水表抄收数据
- (void)_requestData:(NSString *)fromTime :(NSString *)toTime
{
    
    //刷新控件
    loading             = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loading.center      = self.view.center;
    loadingLabel        = [[UILabel alloc] initWithFrame:CGRectMake(PanScreenWidth/2 - 60, PanScreenHeight/2 + 25, 150, 30)];
    loadingLabel.text   = @"正在拼命加载中...";
    
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新1"];
    [loading setImage:image];
    [self.view addSubview:loading];
    [self.view addSubview:loadingLabel];
    
    NSString *historyUrl                = [NSString stringWithFormat:@"http://%@/waterweb/His5Servlet",self.ipLabel];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSDictionary *parameters  = @{@"meter_id":self.hisDetailModel.meter_id,
                                 @"date1":fromTime,
                                 @"date2":toTime,
                                 @"username":self.userNameLabel,
                                 @"db":self.dbLabel,
                                 @"password":self.passWordLabel
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:historyUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            NSDictionary *meter1Dic = [responseObject objectForKey:@"meters"];
            dataCount               = [[responseObject objectForKey:@"count"] integerValue];
            NSError *error          = nil;
            
            [weakSelf.dataArr removeAllObjects];
            
            
            for (NSDictionary *dic in meter1Dic) {
                
                HisDetailModel *hisDetailModel = [[HisDetailModel alloc] initWithDictionary:dic error:&error];
                
                [weakSelf.dataArr addObject:hisDetailModel];
                
                [_yArr addObject:hisDetailModel.collect_avg];
                i = [hisDetailModel.collect_num floatValue] + i;
            }
            
            CGFloat flowCount = 0;
            flowCount = [((HisDetailModel*)weakSelf.dataArr.lastObject).collect_num floatValue] - [((HisDetailModel*)weakSelf.dataArr.firstObject).collect_num floatValue];
            weakSelf.flowStatistics.alpha = 1;
            weakSelf.flowStatistics.text = [NSString stringWithFormat:@"用量统计：%.2f 吨",flowCount];
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [loading removeFromSuperview];
            [loadingLabel removeFromSuperview];
            _xArr = _dataArr;
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [loading removeFromSuperview];
        [loadingLabel removeFromSuperview];
    }];
    
    [task resume];
}
- (void)_getValue
{
    self.meter_id.text      = [NSString stringWithFormat:@"用户号: %@",self.hisDetailModel.meter_id];
    self.meter_name.text    = [NSString stringWithFormat:@"用户名: %@",self.hisDetailModel.meter_name];
    self.meter_name2.text   = [NSString stringWithFormat:@"表类型: %@",self.hisDetailModel.meter_name2];
    self.meter_cali.text    = [NSString stringWithFormat:@"表口径: %@",self.hisDetailModel.meter_cali];
}

- (void)_setTableView
{
    hisDetailID = @"HisDetailIdenty";
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.formDate resignFirstResponder];
    [self.toDate resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.formDate resignFirstResponder];
    [self.toDate resignFirstResponder];

}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HisDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hisDetailID];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HisDetailTableViewCell" owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.serialNum.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
    cell.hisDetailModel = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat avg = i / _dataArr.count - [((HisDetailModel *)self.dataArr.firstObject).collect_num floatValue];
    float m     =  [((HisDetailModel *)self.dataArr[indexPath.row]).collect_num floatValue] - [((HisDetailModel *)self.dataArr.firstObject).collect_num floatValue];

    UIAlertController *alert1   = [UIAlertController alertControllerWithTitle:@"平均用量值" message:[NSString stringWithFormat:@"\n本期用量值：%.2f m³\n\n平均用量值：%.2f m³\n\n高于平均用水量：%.2f m³",m,avg,m-avg] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *alert2   = [UIAlertController alertControllerWithTitle:@"平均用量值" message:[NSString stringWithFormat:@"\n本期用量值：%.2f m³\n\n平均用量值：%.2f m³\n\n低于平均用水量：%.2f m³",m,avg,avg-m] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert1 addAction:action];
    [alert2 addAction:action];
    [SCToastView showInView:self.view text:@"加载中" duration:.5 autoHide:YES];
    
    if ((m-avg) >= 0) {
        
        [self presentViewController:alert1 animated:YES completion:nil];
    } else {
        [self presentViewController:alert2 animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

//确定搜索区间段内数据
- (IBAction)confirmBtn:(id)sender {
    
    [self.formDate resignFirstResponder];
    [self.toDate resignFirstResponder];
    
    [self _requestData:_formDate.text :_toDate.text];
}

- (IBAction)chartBtn:(id)sender {
    SCViewController *curveVC   = [[SCViewController alloc] init];
    curveVC.xArr                = _xArr;
    curveVC.yArr                = _yArr;
    curveVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController showViewController:curveVC sender:nil];
}
- (IBAction)dateBtn:(UIButton *)sender {
    [_formDate resignFirstResponder];
    [_toDate resignFirstResponder];
    
    KSDatePicker* picker = [[KSDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 300)];
    
    picker.appearance.radius = 5;
    
    //设置回调
    picker.appearance.resultCallBack = ^void(KSDatePicker* datePicker,NSDate* currentDate,KSDatePickerButtonType buttonType){
        
        if (buttonType == KSDatePickerButtonCommit) {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if (sender.tag == 100) {
                
                _formDate.text = [formatter stringFromDate:currentDate];
            }else {
                _toDate.text = [formatter stringFromDate:currentDate];
            }
        }
    };
    // 显示
    [picker show];

}
@end
