//
//  MeterDataViewController.m
//  first
//
//  Created by HS on 16/6/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterDataViewController.h"
#import "MeterDataTableViewCell.h"
#import "MeterDataModel.h"
#import "KSDatePicker.h"

@interface MeterDataViewController ()

<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate
>
{
    NSString *cellID;
    NSUserDefaults *defaults;
    NSURLSessionTask *bigMeterTask;
    NSURLSessionTask *litMeterTask;
}
@end

@implementation MeterDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isBigMeter) {
        self.title                  = @"水表数据查询";
        _callerName.text            = @"主叫方：";
        _callerLabel.placeholder    = @"请输入网络编号";
    } else {
        
        self.title = @"小表数据查询";
        _callerName.text            = @"户 号：";
        _callerLabel.placeholder    = @"请输入户号";
        _callerLabel.text           = self.user_id_str;
    }
    
    [_callerLabel becomeFirstResponder];
    
    cellID = @"meterDataID";
    
    [self _getUserInfo];
    
    [self _getSysTime];
    
    [self _setTableView];
    
}


- (void)_setTableView
{
    _tableView.delegate         = self;
    _tableView.dataSource       = self;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MeterDataTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
}

- (void)_getSysTime
{
    //获取系统当前时间
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *time              = [formatter stringFromDate:[NSDate date]];
    self.fromDate.text = time;
    self.toDate.text   = time;
}

- (void)_getUserInfo
{
    defaults = [NSUserDefaults standardUserDefaults];
    _userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];
}
/**
 *  大表数据查询
 *
 *  @param fromDate    <#fromDate description#>
 *  @param toDate      <#toDate description#>
 *  @param callerLabel <#callerLabel description#>
 */
- (void)_requestData:(NSString *)fromDate :(NSString *)toDate :(NSString *)callerLabel
{
    self.tableView.hidden = YES;
    if ([fromDate caseInsensitiveCompare:toDate]<=0) {
        
        [SVProgressHUD showWithStatus:@"加载中"];
        
        NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/MessageServlet",self.ip];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        
        NSDictionary *parameters = @{@"username":self.userName,
                                     @"password":self.passWord,
                                     @"db":self.db,
                                     @"date1":fromDate,
                                     @"date2":toDate,
                                     @"calling_tele":callerLabel
                                     };
        
        AFHTTPResponseSerializer *serializer = manager.responseSerializer;
        
        manager.requestSerializer.timeoutInterval = 30;
        
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        
        __weak typeof(self) weakSelf = self;
        
        bigMeterTask =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            
            NSError *error = nil;
            
            if (responseObject) {
                
                if ([[responseObject objectForKey:@"count"] integerValue] == 0) {
                    
                    [SVProgressHUD showErrorWithStatus:@"暂无数据!" maskType:SVProgressHUDMaskTypeGradient];
                    
                } else {

                    [SVProgressHUD showInfoWithStatus:@"加载成功"];
                    
                    NSDictionary *dicResponse   = [responseObject objectForKey:@"meters"];
                    
                    weakSelf.dataNum.text       = [NSString stringWithFormat:@"数    量: %@",[responseObject objectForKey:@"count"]];
                    
                    for (NSDictionary *dic in dicResponse) {
                        
                        weakSelf.userNameLabel.text     = [NSString stringWithFormat:@"用户名: %@",[dic objectForKey:@"user_name"]];
                        weakSelf.userNumLabel.text      = [NSString stringWithFormat:@"用户号: %@",[dic objectForKey:@"meter_id"]];
                        
                        MeterDataModel *meterDataModel  = [[MeterDataModel alloc] initWithDictionary:dic error:&error];
                        [_dataArr addObject:meterDataModel];
                    }
                    weakSelf.tableView.hidden = NO;
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }else{//responseObject = nil
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"暂无数据"]];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加载失败:%@",error]];
            
        }];
        [bigMeterTask resume];
    } else {
        [SVProgressHUD showErrorWithStatus:@"错误的选择区间!" maskType:SVProgressHUDMaskTypeGradient];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.userNumLabel removeFromSuperview];
    [self.userNameLabel removeFromSuperview];
    [self.dataNum removeFromSuperview];
    
    _callerLabel.delegate       = self;
    _callerLabel.returnKeyType  = UIReturnKeyDone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [self.userNumLabel removeFromSuperview];
    [self.userNameLabel removeFromSuperview];
    [self.dataNum removeFromSuperview];
    if (bigMeterTask) {
        [bigMeterTask cancel];
    }
    if (litMeterTask) {
        [litMeterTask cancel];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeterDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle          = UITableViewCellSelectionStyleNone;
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterDataTableViewCell" owner:self options:nil] lastObject];
    }
    cell.serialNum.text         = [NSString stringWithFormat:@"%li",(long)indexPath.row];
    cell.serialNum.font         = [UIFont systemFontOfSize:10];
    cell.serialNum.textColor    = [UIColor redColor];
    cell.meterDataModel         = _dataArr[indexPath.row];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SCToastView showInView:self.view text:@"加载中" duration:0.5 autoHide:YES];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"水表数据" message:[NSString stringWithFormat:@"%@",((MeterDataModel *)_dataArr[indexPath.row]).message] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *alertVC2 = [UIAlertController alertControllerWithTitle:@"参考读数" message:[NSString stringWithFormat:@"%@",((MeterDataModel *)_dataArr[indexPath.row]).collect_num] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    if (_isBigMeter) {
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    } else {
        [alertVC2 addAction:action];
        [self presentViewController:alertVC2 animated:YES completion:^{
            
        }];
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_callerLabel resignFirstResponder];
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

- (IBAction)conformBtn:(id)sender {
    
    [_callerLabel resignFirstResponder];
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];
    if (_isBigMeter) {
        
        [self _requestData:_fromDate.text :_toDate.text :_callerLabel.text];
    } else {
//        GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"提示" message:@"数据库欠缺" buttonTitle:@"确定" buttonTouchedAction:^{
//            
//        } dismissAction:^{
//            
//        }];
//        [alertView show];
        
        [self requestLitMeterData:_fromDate.text :_toDate.text :_callerLabel.text];
    }
}
/**
 *  请求小表历史数据
 *
 *  @param fromDate <#fromDate description#>
 *  @param toDate   <#toDate description#>
 *  @param meter_id <#meter_id description#>
 */
- (void)requestLitMeterData:(NSString *)fromDate :(NSString *)toDate :(NSString *)meter_id {
    self.tableView.hidden = YES;
    if ([fromDate caseInsensitiveCompare:toDate]<=0) {
        
        [SVProgressHUD showWithStatus:@"查询中"];
        
        NSString *url                       = [NSString stringWithFormat:@"%@/Small_Meter_Reading/HisDateSelectServlet",litMeterApi];
        
        NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        
        NSDictionary *parameters = @{
                                     @"fromDate":fromDate,
                                     @"toDate":toDate,
                                     @"user_id":meter_id
                                     };
        
        AFHTTPResponseSerializer *serializer = manager.responseSerializer;
        
        manager.requestSerializer.timeoutInterval = 30;
        
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        __weak typeof(self) weakSelf = self;
        
        litMeterTask =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (responseObject) {
                NSLog(@"小表数据查询：%@",responseObject);
                [SVProgressHUD dismiss];
                
                NSError *error;
                
                _dataArr = [NSMutableArray array];
                [_dataArr removeAllObjects];
                
                for (NSDictionary *dic in responseObject) {
                    
                    weakSelf.userNameLabel.text     = [NSString stringWithFormat:@"地址: %@",[dic objectForKey:@"user_addr"]];
                    weakSelf.userNumLabel.text      = [NSString stringWithFormat:@"所属区域: %@",[dic objectForKey:@"collector_area"]];
                    
                    MeterDataModel *meterDataModel  = [[MeterDataModel alloc] initWithDictionary:dic error:&error];
                    [_dataArr addObject:meterDataModel];
                    
                }
                weakSelf.dataNum.text = [NSString stringWithFormat:@"数量：%ld",(long)_dataArr.count];
                if ([weakSelf.dataNum.text isEqualToString:@"数量：0"]) {
                    [SVProgressHUD showInfoWithStatus:@"此时间区间暂无数据" maskType:SVProgressHUDMaskTypeGradient];
                }
                weakSelf.tableView.hidden = NO;
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSLog(@"错误信息：%@",error);
            
            if (error.code == -1001) {
                
                [SVProgressHUD showInfoWithStatus:@"请求超时" maskType:SVProgressHUDMaskTypeGradient];
            }
        }];
        
        [litMeterTask resume];
        
    } else {
            GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"提示" message:@"错误的日期选择区间！" buttonTitle:@"确定" buttonTouchedAction:^{
        
            } dismissAction:^{
        
            }];
            [alertView show];
    }
}

- (IBAction)dateBtn:(UIButton *)sender {
    
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];
    [_callerLabel resignFirstResponder];
    
    KSDatePicker* picker = [[KSDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 300)];
    
    picker.appearance.radius = 5;
    
    //设置回调
    picker.appearance.resultCallBack = ^void(KSDatePicker* datePicker,NSDate* currentDate,KSDatePickerButtonType buttonType){
        
        if (buttonType == KSDatePickerButtonCommit) {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if (sender.tag == 100) {
                
                _fromDate.text = [formatter stringFromDate:currentDate];
            }else {
                _toDate.text = [formatter stringFromDate:currentDate];
            }
        }
    };
    // 显示
    [picker show];

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        //用户结束输入
        [textField resignFirstResponder];
        if (_isBigMeter) {
            
            [self _requestData:_fromDate.text :_toDate.text :_callerLabel.text];
        } else {
            
            [self requestLitMeterData:_fromDate.text :_toDate.text :_callerLabel.text];
        }
    }
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
@end
