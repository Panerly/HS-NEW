//
//  SingleViewController.m
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SingleViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FBShimmeringView.h"

// 拼接字符串
static NSString *boundaryStr = @"--";   // 分隔字符串
static NSString *randomIDStr;           // 本次上传标示字符串
static NSString *uploadID;              // 上传(php)脚本中，接收文件字段

@interface SingleViewController ()
<
AVCaptureMetadataOutputObjectsDelegate,
UITextFieldDelegate
>
{
    UIImagePickerController *_imagePickerController;
    //确定传的是哪个照片
    NSInteger num;

    UIImageView *loading;
    
    NSString *time;
}



@end

@implementation SingleViewController

static BOOL flag;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isBigMeter?@"大表抄收页":@"小表抄收页";
    
    flag = YES;
    
    [self _getCode];
     
    [self _makeImageTouchLess];
    
    UIBarButtonItem *loca = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"定位3@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(locaBtn)];
    
    self.navigationItem.rightBarButtonItems = @[loca];
    
    if (self.meter_id_string) {
        self.meter_id.text = self.meter_id_string;
    
        [self getInfo:self.meter_id_string];
        
    }else{
        GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"确定" message:@"无效的条码号！" buttonTitle:@"确定" buttonTouchedAction:^{
            
        } dismissAction:^{
            
        }];
        [alertView show];
    }
    [_thisPeriodValue setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_thisPeriodValue setValue:[UIFont boldSystemFontOfSize:18] forKeyPath:@"_placeholderLabel.font"];
    FBShimmeringView *shimmeringView           = [[FBShimmeringView alloc] initWithFrame:_thisPeriodValue.bounds];
    shimmeringView.shimmering                  = YES;
    shimmeringView.shimmeringBeginFadeDuration = 0.4;
    shimmeringView.shimmeringOpacity           = 0.1f;
    shimmeringView.shimmeringAnimationOpacity  = 1.f;
    [self.view addSubview:shimmeringView];
    shimmeringView.center                      = self.view.center;
    shimmeringView.contentView = _thisPeriodValue;
    shimmeringView.multipleTouchEnabled = NO;
    
    randomIDStr = @"V2ymHFg03ehbqgZCaKO6jy";
    uploadID = @"uploadFile";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_thisPeriodValue becomeFirstResponder];
    _thisPeriodValue.delegate = self;
}

/**
 *  获取本地库单户详情
 *
 *  @param install_addr <#install_addr description#>
 */
- (void)getInfo :(NSString *)install_addr {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  区域编码：%@", fileName, install_addr);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from litMeter_info where install_addr = '%@'",install_addr]];
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([restultSet next]) {
            self.meter_id.text = [restultSet stringForColumn:@"meter_id"];
            self.user_name.text = [NSString stringWithFormat:@"户号：%@",[restultSet stringForColumn:@"user_id"]];
            self.install_addr.text = [restultSet stringForColumn:@"install_addr"];
            self.previousReading.text = [restultSet stringForColumn:@"collector_num"];
            self.previousSettle.text = [restultSet stringForColumn:@"install_time"];
            self.collect_area = [restultSet stringForColumn:@"collector_area"];
        }
    }
}


- (void)_makeImageTouchLess
{
    self.firstImage.multipleTouchEnabled  = NO;
    self.secondImage.multipleTouchEnabled = NO;
    self.thirdImage.multipleTouchEnabled  = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)locaBtn
{
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"正在定位..." duration:1 autoHide:YES];
    //检测定位功能是否开启
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [self.locationManager setDistanceFilter:5.0];
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
    
    return nil;
}

#pragma mark - CLLocationManagerDelegate 代理方法实现
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"经度：%f,纬度：%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"定位成功" duration:1 autoHide:YES];
    [_locationManager stopUpdatingLocation];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"使用当前坐标 ？" message:[NSString stringWithFormat:@"\n经度：%f\n\n纬度：%f",newLocation.coordinate.longitude,newLocation.coordinate.latitude] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _x = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        _y = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:action];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];

}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"定位失败"];
}


- (IBAction)takePhoto:(UIButton *)sender {
    
    [self _camera:sender.tag];
}

- (void)_camera:(NSInteger )imageValue{
    num = imageValue;
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:NULL];
    }else
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        [self selectImageFromCamera];
    }
}



- (void)_getCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.userNameLabel = [defaults objectForKey:@"userName"];
    self.passWordLabel = [defaults objectForKey:@"passWord"];
    self.ipLabel       = [defaults objectForKey:@"ip"];
    self.dbLabel       = [defaults objectForKey:@"db"];
}

//上传数据
- (IBAction)uploadPhoto:(id)sender {
    
    NSLog(@"上传数据");
    
    [AnimationView showInView:self.view];
    
    NSString *uploadUrl               = [NSString stringWithFormat:@"%@/Meter_Reading/Reading_nowServlet1",litMeterApi];
    
    AFSecurityPolicy *securityPolicy  = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    [manager setSecurityPolicy:securityPolicy];
    
    NSData *data = UIImageJPEGRepresentation(_firstImage.image, .1f);
    NSData *data2 = UIImageJPEGRepresentation(_secondImage.image, .1f);
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    if (data) {
        
        [imageDic setObject:data forKey:[NSString stringWithFormat:@"first%@.jpg",_meter_id_string]];
    }
    if (data2) {
        
        [imageDic setObject:data2 forKey:[NSString stringWithFormat:@"second%@.jpg",_meter_id_string]];
    }
    
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];

    NSDictionary *para = [NSDictionary dictionary];
    
    int increase       = [_thisPeriodValue.text intValue] - [_previousReading.text intValue];
    int increaseAlarm  = _isBigMeter?[[[NSUserDefaults standardUserDefaults] objectForKey:@"bigMeterAlarmValue"] intValue]:[[[NSUserDefaults standardUserDefaults] objectForKey:@"litMeterAlarmValue"] intValue];
    
    if (increaseAlarm>0) {//判断是否有预设值
        
        if (increase > increaseAlarm) {
            
            [AnimationView dismiss];
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表增幅值大于警报增幅值！\n请核实后重新填入，或者进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
            }];
        }else{//通过增幅监测
            
            if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表值不能低于上期抄收值！" preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }else {//通过水表逆流监测 开始上传
                
                NSDictionary *parameters = @{
                                             @"meter_id"      : _meter_id.text,
                                             @"collect_dt"    : currentTime,
                                             @"collect_num"   : _thisPeriodValue.text,
                                             @"collect_avg"   : [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]],
                                             @"collect_status": _meteringSituation.text?_meteringSituation.text:@"正常",
                                             @"bs"            : @"1"
                                             };
                
                NSError *error;
                NSData *dataPara = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:dataPara encoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonpara = @{
                                       @"meter_key":jsonString
                                       };
                para = jsonpara;
                AFHTTPResponseSerializer *serializer = manager.responseSerializer;
                
                serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
                
                
                [self uploadFileWithURL:[NSURL URLWithString:uploadUrl] imageDic:imageDic pramDic:para manager:manager installArr:_meter_id_string];
                
            }
        }

    }else{
        [AnimationView dismiss];
        UIAlertAction *action      = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"未设置增幅警报" message:@"预设增幅警报值不能为0，\n进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
}

//保存到本地数据库
- (IBAction)saveToLocal:(id)sender {
    
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *timeForNow = [formatter stringFromDate:[NSDate date]];
    time = timeForNow;
    
    if (_thisPeriodValue.text == nil) {
        GUAAlertView *alert = [GUAAlertView alertViewWithTitle:@"提示" message:@"本期抄表值不能为空！" buttonTitle:@"确定" buttonTouchedAction:^{
            
        } dismissAction:^{
            
        }];
        [alert show];
    }
    if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
        if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
            
            UIAlertAction *action      = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表值不能低于上期抄收值！" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
    } else {
        int increase      = [_thisPeriodValue.text intValue] - [_previousReading.text intValue];
        int increaseAlarm = _isBigMeter?[[[NSUserDefaults standardUserDefaults] objectForKey:@"bigMeterAlarmValue"] intValue]:[[[NSUserDefaults standardUserDefaults] objectForKey:@"litMeterAlarmValue"] intValue];
        
        if (increaseAlarm>0) {//判断是否有预设值
            if (increase > increaseAlarm) {//如果增幅大于增幅警报值
                [AnimationView dismiss];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"忽略继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (!_x || !_y) {//无坐标信息
                        UIAlertAction *conformBtn = [UIAlertAction actionWithTitle:@"定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self locaBtn];
                        }];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"不使用" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                            NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
                            FMDatabase *db = [FMDatabase databaseWithPath:fileName];
                            if ([db open]) {
                                
                                BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 text null, Collect_img_name3 text null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num text not null, user_id text null, collect_time text null, metering_status text null, collect_avg text null);"];
                                
                                if (result) {
                                    NSLog(@"创建抄收完成表成功");
                                } else {
                                    NSLog(@"创建抄收完成表失败！");
                                    [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
                                }
                            }
                            NSData *imageData  = UIImageJPEGRepresentation(_firstImage.image, .4);
                            NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, 1);
                            NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, 1);
                            
                            [db executeUpdate:@"insert into meter_complete (user_name, install_addr, collect_num, meter_id, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area, collect_time, metering_status, collect_avg) values (?,?,?,?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area, time, _meteringSituation.text?_meteringSituation.text:@"正常", [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]]];
                            
                            if ([db open]) {
                                [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                                [db close];
                            } else {
                                [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                            }
                            
                            [SCToastView showInView:self.view text:@"保存成功" duration:.5 autoHide:YES];
                            [self.navigationController popViewControllerAnimated:YES];
                            
                        }];
                        UIAlertController *alertVC2 = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定不使用当前地理坐标?" preferredStyle:UIAlertControllerStyleAlert];
                        [alertVC2 addAction:cancelBtn];
                        [alertVC2 addAction:conformBtn];
                        [self presentViewController:alertVC2 animated:YES completion:^{
                            
                        }];
                    }else{//有坐标信息
                        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
                        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
                        if ([db open]) {
                            BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 text null, Collect_img_name3 text null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num text not null, user_id text null, collect_time text null, metering_status text null, collect_avg text null);"];
                            
                            if (result) {
                                NSLog(@"创建抄收完成表成功");
                            } else {
                                NSLog(@"创建抄收完成表失败！");
                                [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
                            }
                        }
                        NSData *imageData  = UIImageJPEGRepresentation(_firstImage.image, .1);
                        NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, .1);
                        NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, .1);
                        
                        [db executeUpdate:@"insert into meter_complete (user_name, install_addr, collect_num, meter_id, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area, collect_time, metering_status, collect_avg) values (?,?,?,?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area, time, _meteringSituation.text?_meteringSituation.text:@"正常", [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]]];
                        
                        if ([db open]) {
                            [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                            [db close];
                        } else {
                            [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                        }
                        
                        [SCToastView showInView:self.view text:@"保存成功" duration:.5 autoHide:YES];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表增幅值大于警报增幅值！\n请核实后重新填入，或进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:action];
                [confirm setValue:[UIColor redColor] forKey:@"titleTextColor"];
                [alertVC addAction:confirm];
                NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"提示⚠️"];
                
                [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
                
                [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 2)];
                
                [alertVC setValue:alertControllerStr forKey:@"attributedTitle"];
                
                [self presentViewController:alertVC animated:YES completion:^{
                }];
            }else{//通过增幅监测
                
                if (!_x || !_y) {//如果有地理坐标
                    UIAlertAction *conformBtn = [UIAlertAction actionWithTitle:@"定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self locaBtn];
                    }];
                    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"不使用" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
                        FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
                        if ([db open]) {
                            
                            BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 text null, Collect_img_name3 text null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num text not null, user_id text null, collect_time text null ,metering_status text null, collect_avg text null);"];
                            
                            if (result) {
                                
                                NSLog(@"创建抄收完成表成功");
                            } else {
                                
                                NSLog(@"创建抄收完成表失败！");
                                [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
                            }
                        }
                        NSData *imageData  = UIImageJPEGRepresentation(_firstImage.image, .4);
                        NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, 1);
                        NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, 1);
                        
                        [db executeUpdate:@"insert into meter_complete (user_name, install_addr, collect_num, meter_id, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area, collect_time, metering_status, collect_avg) values (?,?,?,?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area, time, _meteringSituation.text?_meteringSituation.text:@"正常", [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]]];
                        
                        if ([db open]) {
                            
                            [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                            
                            [db close];
                        } else {
                            [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                        }
                        [SCToastView showInView:self.view text:@"保存成功" duration:.5 autoHide:YES];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }];
                    UIAlertController *alertVC2 = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定不使用当前地理坐标?" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC2 addAction:cancelBtn];
                    [alertVC2 addAction:conformBtn];
                    [self presentViewController:alertVC2 animated:YES completion:^{
                        
                    }];
                }else{//没有坐标信息
                    NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
                    FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
                    if ([db open]) {
                        
                        BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 text null, Collect_img_name3 text null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num text not null, user_id text null, collect_time text null, metering_status text null, collect_avg text null);"];
                        
                        if (result) {
                            
                            NSLog(@"创建抄收完成表成功");
                        } else {
                            
                            NSLog(@"创建抄收完成表失败！");
                            [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
                        }
                    }
                    NSData *imageData  = UIImageJPEGRepresentation(_firstImage.image, .4);
                    NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, 1);
                    NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, 1);
                    
                    [db executeUpdate:@"insert into meter_complete (user_name, install_addr, collect_num, meter_id, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area, collect_time, metering_status, collect_avg) values (?,?,?,?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area, time, _meteringSituation.text?_meteringSituation.text:@"正常", [NSString stringWithFormat:@"%d",[_thisPeriodValue.text intValue] - [_previousReading.text intValue]]];
                    
                    if ([db open]) {
                        
                        [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                        
                        [db close];
                    } else {
                        [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                    }
                    
                    [SCToastView showInView:self.view text:@"保存成功" duration:.5 autoHide:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }else{
            GUAAlertView *alert = [GUAAlertView alertViewWithTitle:@"增幅警报不能为空！" message:@"请到设置页面设置增幅警报！" buttonTitle:@"确定" buttonTouchedAction:^{
                
            } dismissAction:^{
                
            }];
            [alert show];
        }
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:.25 animations:^{
        [self.previousSettle resignFirstResponder];
        [self.previousReading resignFirstResponder];
        [self.thisPeriodValue resignFirstResponder];
        [self.meteringExplain resignFirstResponder];
        [self.meteringSituation resignFirstResponder];
    }];
}

#pragma mark 从摄像头获取图片或视频
- (void)selectImageFromCamera
{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    _imagePickerController.videoMaximumDuration = 15;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeJPEG];
    //设置摄像头模式（拍照，录制视频）为拍照模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:^{
        
    }];
}

//获取成功后赋值
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if (num == 300) {
        
        self.firstImage.image = image;
    }
    if (num == 301) {
        self.secondImage.image = image;
        
    }
    if (num == 302) {
        self.thirdImage.image = image;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)meterStatuesBtn:(UIButton *)sender {
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"正常",@"水表破损",@"水表倒装",@"人工估表",@"水表停走",@"周检换表",@"用水异常"] imageArray:@[@"icon_normal",@"icon_demage",@"icon_reversal",@"icon_compute",@"icon_meter_stop",@"icon_changemeter",@"icon_abnormal"] doneBlock:^(NSInteger selectedIndex) {
        
        switch (selectedIndex) {
            case 0:
                _meteringSituation.text      = @"正常";
                _meteringSituation.textColor = [UIColor greenColor];
                break;
            case 1:
                _meteringSituation.text      = @"水表破损";
                _meteringSituation.textColor = [UIColor redColor];
                break;
            case 2:
                _meteringSituation.text      = @"水表倒装";
                _meteringSituation.textColor = [UIColor redColor];
                break;
            case 3:
                _meteringSituation.text      = @"人工估表";
                _meteringSituation.textColor = [UIColor redColor];
                break;
            case 4:
                _meteringSituation.text      = @"水表停走";
                _meteringSituation.textColor = [UIColor redColor];
                break;
            case 5:
                _meteringSituation.text      = @"周检换表";
                _meteringSituation.textColor = [UIColor redColor];
                break;
            case 6:
                _meteringSituation.text      = @"用水异常";
                _meteringSituation.textColor = [UIColor redColor];
                break;
                
            default:
                _meteringSituation.text      = @"正常";
                _meteringSituation.textColor = [UIColor greenColor];
                break;
        }
    } dismissBlock:^{
        
        NSLog(@"user canceled. do nothing.");
    }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}
- (BOOL)validateNumber:(NSString*)number {
    BOOL res               = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i                  = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range     = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}



#pragma mark - 私有方法
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadID,uploadFile];
    [strM appendFormat:@"Content-Type: %@\r\n\r\n", mimeType];
    
    NSLog(@"%@", strM);
    return [strM copy];
}

- (NSString *)bottomString:(NSString *)key value:(NSString *)value
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    [strM appendFormat:@"%@\r\n",value];
    
    
    NSLog(@"%@", strM);
    return [strM copy];
}

#pragma mark - 上传文件
- (void)uploadFileWithURL:(NSURL *)url imageDic:(NSDictionary *)imgDic pramDic:(NSDictionary *)pramDic manager:(AFHTTPSessionManager *)manager installArr:(NSString *)installArr
{
    // 1> 数据体
    
    
    NSMutableData *dataM = [NSMutableData data];
    
    //    [dataM appendData:[boundaryStr dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *name  in [imgDic allKeys]) {
        NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:name];
        [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
        [dataM appendData:[imgDic valueForKey:name]];
    }
    
    for (NSString *name  in [pramDic allKeys]) {
        NSString *bottomStr = [self bottomString:name value:[pramDic valueForKey:name]];
        [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [dataM appendData:[[NSString stringWithFormat:@"%@%@--\r\n", boundaryStr, randomIDStr] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:20];
    
    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;
    //    NSLog(@"%@",dataM);
    
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    
    __weak typeof(self) weakSelf = self;
    
    // 3> 连接服务器发送请求
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [AnimationView dismiss];
        
        NSLog(@"上传成功：%@",responseObject);
        if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
            
            [SCToastView showInView:self.view text:@"上传成功" duration:1 autoHide:YES];
            
            NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
            FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
            
            if ([db open]) {
                
                [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                
                [db close];
            } else {
                
                [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
            }
            if ([db open]) {
                
                BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 text null, Collect_img_name3 text null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num text not null, user_id text null, collect_time text null, metering_status text null, collect_avg text null);"];
                
                if (result) {
                    
                    NSLog(@"创建抄收完成表成功");
                } else {
                    
                    NSLog(@"创建抄收完成表失败！");
                    [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
                }
            }
            NSData *imageData  = UIImageJPEGRepresentation(_firstImage.image, .4);
            NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, 1);
            NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, 1);
            
            [db executeUpdate:@"insert into meter_complete (user_name, install_addr, collect_num, meter_id, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area, collect_time, metering_status, collect_avg) values (?,?,?,?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area, time, _meteringSituation.text?_meteringSituation.text:@"正常", [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]]];
            
            //成功后退出
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败%@",error] duration:1 autoHide:YES];
        }
        if (error) {
            NSLog(@"上传失败：%@",error);
            [AnimationView dismiss];
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败！\n原因:%@",error.code== -1004?@"服务器连接失败":error] duration:5 autoHide:YES];
        }
    }];
    
    [task resume];
    
}
@end
