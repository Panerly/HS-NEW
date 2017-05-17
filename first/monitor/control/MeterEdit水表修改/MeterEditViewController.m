//
//  MeterEditViewController.m
//  first
//
//  Created by HS on 16/6/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterEditViewController.h"

@interface MeterEditViewController ()
<
CLLocationManagerDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource,
UIScrollViewDelegate,
UITextFieldDelegate,
LLSwitchDelegate
>
{
    NSMutableArray *alarmNsetList;
    //所属区域
    NSArray *_pickerNameArr;
    //表具类型
    NSArray *_pickerTypeArr;
    //口径
    NSArray *_pickerCaliArr;
    //远传方式
    NSArray *_pickerWayArr;
    //远传类型
    NSArray *_pickerRemoTypeArr;
    
    NSUserDefaults *defaults;
    BOOL flag;
}
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation MeterEditViewController

static int i = 0;

#define changeLabel @"水表修改"
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = changeLabel;
    
    LLSwitch *customSwitchBtn = [[LLSwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [customSwitchBtn setOn:NO];
    customSwitchBtn.animationDuration = 1.0f;
    customSwitchBtn.onColor = COLORRGB(75, 218, 91);
    customSwitchBtn.delegate = self;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customSwitchBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    
    [self _getCode];
    
    [self _configScrollView];
    
    [self _requestData];
    
    _dataArr = [NSMutableArray array];

    flag = NO;
}

- (void)_getCode
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.userNameLabel = [defaults objectForKey:@"userName"];
    self.passWordLabel = [defaults objectForKey:@"passWord"];
    self.ipLabel = [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"];
}

- (void)_requestData
{
    
     NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/EditServlet",self.ipLabel];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSDictionary *parameters = @{@"username":self.userNameLabel,
                                 @"password":self.passWordLabel,
                                 @"db":self.dbLabel,
                                 @"meterid":self.meter_id,
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            alarmNsetList = [NSMutableArray array];
            [alarmNsetList removeAllObjects];
//            NSLog(@"水表修改返回数据%@",responseObject);
            for (NSDictionary *dic in [responseObject objectForKey:@"alarmNsetList"]) {
                [alarmNsetList addObject:[dic objectForKey:@"TorF"]];
                
            }
            _idArray = [NSMutableArray array];
            [_idArray removeAllObjects];
            for (NSDictionary *idDic in [responseObject objectForKey:@"alarmNsetList"]) {
                [_idArray addObject:[idDic objectForKey:@"id"]];
            }
            
            _numArray = [NSMutableArray array];
            for (NSDictionary *numDic in [responseObject objectForKey:@"alarmNsetList"]) {
                [_numArray addObject:[numDic objectForKey:@"num"]];
            }
            
            [_excessiveSwitchBtn setOn:[[alarmNsetList objectAtIndex:0] isEqualToString:@"0"] ? NO : YES];
            [_reversalSwitchBtn setOn:[[alarmNsetList objectAtIndex:2]isEqualToString:@"0"] ? NO : YES];
            [_longTimeNotServerSwitchBtn setOn:[[alarmNsetList objectAtIndex:3]isEqualToString:@"0"] ? NO : YES];
            [_limitOfDayUsageSwitchBtn setOn:[[alarmNsetList objectAtIndex:4]isEqualToString:@"0"] ? NO : YES];
            [_longtimeNotUseSwitchBtn setOn:[[alarmNsetList objectAtIndex:1]isEqualToString:@"0"] ? NO : YES];
            
#pragma mark - diff db got diff count but at least 5
            if (alarmNsetList.count>5) {
                
                [_limitOfUsageSwitchBtn setOn:[[alarmNsetList objectAtIndex:5]isEqualToString:@"0"] ? NO : YES];
                [_fromToSwitchBtn setOn:[[alarmNsetList objectAtIndex:6]isEqualToString:@"0"] ? NO : YES];
            }
            
            NSMutableAttributedString *attrutedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"用户号: %@",[responseObject objectForKey:@"user_id"]]];
            
            [attrutedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 4)];
            
            _userID.attributedText      = attrutedStr;
            
            _installAddrTextField.text  = [responseObject objectForKey:@"username"];
            _longitudeTextField.text    = [responseObject objectForKey:@"x"];
            _latitudeTextField.text     = [responseObject objectForKey:@"y"];
            _remarksTextView.text       = [responseObject objectForKey:@"user_remark"];
            _user_addr                  = [responseObject objectForKey:@"user_addr"];
            
            NSDictionary *dic           = [responseObject objectForKey:@"meter1"];
            
            NSMutableAttributedString *attrutedStr_id = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"表位号: %@",[dic objectForKey:@"meter_id"]]];
            [attrutedStr_id addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 4)];
            
            _meterID.attributedText     = attrutedStr_id;
            _meter_idTextField.text     = [dic objectForKey:@"meter_wid"];
            _connectIDTextField.text    = [dic objectForKey:@"comm_id"];
            _collectIDTextField.text    = [dic objectForKey:@"collector_id"];
            _installTimeTextField.text  = [dic objectForKey:@"install_time"];
            _wheelTypeTextField.text    = [dic objectForKey:@"bz10"];
            _regionTextField.text       = [dic objectForKey:@"area"];
            _meterTypeTextField.text    = [dic objectForKey:@"meter_name"];
            _caliberTextField.text      = [dic objectForKey:@"meter_cali"];
            _remoteTypeTextField.text   = [dic objectForKey:@"type_name"];
            _remoteWayTextField.text    = [dic objectForKey:@"type"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据加载失败^_^!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }];
    [task resume];
    
}

//配置滑动试图
- (void)_configScrollView
{
    _scrollView                 = [[UIScrollView alloc] init];
    _scrollView.contentSize     = CGSizeMake(PanScreenWidth, 2*PanScreenHeight);
    _scrollView.scrollEnabled   = YES;
    _scrollView.pagingEnabled   = NO;
    _scrollView.delegate        = self;
    _scrollView.showsVerticalScrollIndicator    = YES;
    _scrollView.showsHorizontalScrollIndicator  = NO;
    _scrollView.backgroundColor                 = [UIColor whiteColor];
    //滑动时使键盘收回
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_scrollView];
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(PanScreenWidth, PanScreenHeight));
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self _configContent];
    [self unavailable];
    
    //保存按钮
    _saveBtn = [[UIButton alloc] init];
    [_saveBtn setImage:[UIImage imageNamed:@"save2"] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveBtn];
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-59);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.size.equalTo(CGSizeMake(55, 55));
    }];
}

- (UILabel *)allocLabel {
    return [[UILabel alloc] init];
}

//控件部署
- (void)_configContent
{
    _userID                 = [self allocLabel];
    _meterID                = [self allocLabel];
    _installAddrLabel       = [self allocLabel];
    _meter_idLabel          = [self allocLabel];
    _connectIDLabel         = [self allocLabel];
    _collectIDLabel         = [self allocLabel];
    _installTimeLabel       = [self allocLabel];
    _wheelTypeLabel         = [self allocLabel];
    _regionLabel            = [self allocLabel];
    _meterTypeLabel         = [self allocLabel];
    UILabel *remoteWay      = [self allocLabel];
    _caliberLabel           = [self allocLabel];
    UILabel *remoteType     = [self allocLabel];
    _latitudeLabel          = [self allocLabel];
    _longitudeLabel         = [self allocLabel];
    UILabel *setAlarm       = [self allocLabel];
    _excessiveAlarmLabel    = [self allocLabel];
    _remarksLabel           = [self allocLabel];
    _toLabel                = [self allocLabel];
    _fromLabel              = [self allocLabel];
    UILabel *intervalLabel  = [self allocLabel];
    UILabel *limitOfUsageAlarmUnit  = [self allocLabel];
    _limitOfUsageLabel              = [self allocLabel];
    UILabel *longtimeNotUse         = [self allocLabel];
    UILabel *dayOverFlowUnit        = [self allocLabel];
    UILabel *dayOverFlow            = [self allocLabel];
    UILabel *longTimeNotServerUnit  = [self allocLabel];
    _longTimeNotServer              = [self allocLabel];
    UILabel *reversalAlarmUnit      = [self allocLabel];
    _reversalAlarmLabel             = [self allocLabel];
    UILabel *excessiveAlarmUnit     = [self allocLabel];
    UILabel *alarmIntroduce         = [self allocLabel];
    UILabel *parameterSet           = [self allocLabel];
    UILabel *enableLabel            = [self allocLabel];
    
    NSMutableArray *labelArr = [NSMutableArray arrayWithObjects:_userID,_meterID,_installAddrLabel,_meter_idLabel,_connectIDLabel,_collectIDLabel,_installTimeLabel,_wheelTypeLabel,_regionLabel,_meterTypeLabel,remoteWay,_caliberLabel,remoteType,_latitudeLabel,_longitudeLabel,setAlarm,_excessiveAlarmLabel,_remarksLabel,_toLabel,_fromLabel,intervalLabel,limitOfUsageAlarmUnit,_limitOfUsageLabel,longtimeNotUse,dayOverFlowUnit,dayOverFlow,longTimeNotServerUnit,_longTimeNotServer,reversalAlarmUnit,_reversalAlarmLabel,excessiveAlarmUnit,alarmIntroduce,parameterSet,enableLabel,nil];
   
    for (int i = 0; i < labelArr.count; i++) {
        
        if (i<=16) {
            if (i<2) {
                ((UILabel *)labelArr[i]).font       = [UIFont systemFontOfSize:13];
                ((UILabel *)labelArr[i]).textColor  = [UIColor blackColor];
            }else {
            ((UILabel *)labelArr[i]).font       = [UIFont systemFontOfSize:13];
            ((UILabel *)labelArr[i]).textColor  = [UIColor blueColor];
            }
            
        } else {
            
        ((UILabel *)labelArr[i]).font       = [UIFont systemFontOfSize:10.0f];
        ((UILabel *)labelArr[i]).textColor  = [UIColor darkGrayColor];
            
        }
        [_scrollView addSubview:labelArr[i]];
    }
    
    _installAddrTextField           = [[UITextField alloc] init];
    _meter_idTextField              = [[UITextField alloc] init];
    _connectIDTextField             = [[UITextField alloc] init];
    _collectIDTextField             = [[UITextField alloc] init];
    _installTimeTextField           = [[UITextField alloc] init];
    _wheelTypeTextField             = [[UITextField alloc] init];
    _regionTextField                = [[UITextField alloc] init];
    _meterTypeTextField             = [[UITextField alloc] init];
    _caliberTextField               = [[UITextField alloc] init];
    _remoteWayTextField             = [[UITextField alloc] init];
    _remoteTypeTextField            = [[UITextField alloc] init];
    _longitudeTextField             = [[UITextField alloc] init];
    _latitudeTextField              = [[UITextField alloc] init];
    _excessiveAlarmTextField        = [[UITextField alloc] init];
    _reversalAlarmTextField         = [[UITextField alloc] init];
    _longTimeNotServerTextField     = [[UITextField alloc] init];
    _limitOfDayUsageAlarmTextField  = [[UITextField alloc] init];
    _limitOfUsageAlarmTextField     = [[UITextField alloc] init];
    _fromTextField                  = [[UITextField alloc] init];
    _toTextField                    = [[UITextField alloc] init];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:_installAddrTextField,_meter_idTextField,_connectIDTextField,_collectIDTextField,_installTimeTextField,_wheelTypeTextField,_regionTextField,_meterTypeTextField,_caliberTextField,_remoteWayTextField,_remoteTypeTextField,_longitudeTextField,_latitudeTextField,_excessiveAlarmTextField,_reversalAlarmTextField,_limitOfDayUsageAlarmTextField,_longTimeNotServerTextField,_limitOfUsageAlarmTextField,_fromTextField,_toTextField, nil];
    
    for (int i = 0; i < arr.count; i++) {
        
        ((UITextField *)arr[i]).borderStyle = UITextBorderStyleRoundedRect;
        ((UITextField *)arr[i]).font        = [UIFont systemFontOfSize:13];
        [_scrollView addSubview:arr[i]];
    }
    
    _userID.text = @"用户号: ";
    [_userID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_top).with.offset(15);
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.size.equalTo(CGSizeMake(150, 25));
    }];
    
    _meterID.text = @"表位号: ";
    [_meterID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_top).with.offset(15);
        make.centerX.equalTo(_scrollView.centerX).with.offset(50);
        make.size.equalTo(CGSizeMake(150, 25));
    }];
    
    _installAddrLabel.text = @"安装地址: ";
    [_installAddrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_meterID.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _installAddrTextField.font = [UIFont systemFontOfSize:11];
    [_installAddrTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_meterID.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _meter_idLabel.text = @"表  身  号: ";
    [_meter_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.left).with.offset(10);
        make.top.equalTo(_installAddrLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_meter_idTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_installAddrLabel.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _connectIDLabel.text = @"通讯联络号: ";
    [_connectIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_meter_idLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_connectIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_meter_idLabel.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _collectIDLabel.text = @"采集编号: ";
    [_collectIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_connectIDLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_collectIDTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_connectIDTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _installTimeLabel.text = @"安装时间: ";
    [_installTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_collectIDLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_installTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_collectIDTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _wheelTypeLabel.text = @"字轮类型: ";
    [_wheelTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_installTimeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_wheelTypeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_installAddrLabel.mas_right);
        make.top.equalTo(_installTimeTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _regionLabel.text = @"所属区域: ";
    [_regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_wheelTypeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_regionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_regionLabel.mas_right);
        make.top.equalTo(_wheelTypeLabel.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    UIButton *button        = [[UIButton alloc] init];
    button.tag              = 500;
    button.backgroundColor  = [UIColor clearColor];
    [button addTarget:self action:@selector(changeAttr:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_regionLabel.mas_right);
        make.top.equalTo(_wheelTypeLabel.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _meterTypeLabel.text = @"表具类型: ";
    [_meterTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_regionLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_meterTypeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_meterTypeLabel.mas_right);
        make.top.equalTo(_regionTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    UIButton *button2       = [[UIButton alloc] init];
    button2.tag             = 501;
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(changeAttr:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_meterTypeLabel.mas_right);
        make.top.equalTo(_regionTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _caliberLabel.text = @"口     经: ";
    [_caliberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_meterTypeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_caliberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_caliberLabel.mas_right);
        make.top.equalTo(_meterTypeTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    UIButton *button3       = [[UIButton alloc] init];
    button3.tag             = 502;
    button3.backgroundColor = [UIColor clearColor];
    [button3 addTarget:self action:@selector(changeAttr:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_caliberLabel.mas_right);
        make.top.equalTo(_meterTypeTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];

    remoteWay.text = @"远传方式: ";
    [remoteWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(_caliberLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_remoteWayTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remoteWay.mas_right);
        make.top.equalTo(_caliberTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    UIButton *button4       = [[UIButton alloc] init];
    button4.tag             = 503;
    button4.backgroundColor = [UIColor clearColor];
    [button4 addTarget:self action:@selector(changeAttr:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button4];
    [button4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remoteWay.mas_right);
        make.top.equalTo(_caliberTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    
    remoteType.text = @"远传类型";
    [remoteType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(remoteWay.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    [_remoteTypeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remoteType.mas_right);
        make.top.equalTo(_remoteWayTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    UIButton *button5       = [[UIButton alloc] init];
    button5.tag             = 504;
    button5.backgroundColor = [UIColor clearColor];
    [button5 addTarget:self action:@selector(changeAttr:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button5];
    [button5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remoteType.mas_right);
        make.top.equalTo(_remoteWayTextField.mas_bottom).with.offset(10);
        make.right.equalTo(self.view.right).with.offset(-10);
        make.height.equalTo(25);
    }];
    
    _longitudeLabel.text = @"经度: ";
    [_longitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(10);
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    
    [_longitudeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_longitudeLabel.mas_right).with.offset(-15);
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(90, 25));
    }];
    
    
    _latitudeLabel.text = @"纬度: ";
    [_latitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.centerX.equalTo(_scrollView.centerX).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    
    [_latitudeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_latitudeLabel.mas_right).with.offset(-15);
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(90, 25));
    }];
    
    //定位按钮
    _locaBtn = [[UIButton alloc] init];
    [_locaBtn setImage:[UIImage imageNamed:@"定位3"] forState:UIControlStateNormal];
    [_locaBtn addTarget:self action:@selector(locaBtn) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_locaBtn];
    [_locaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteType.mas_bottom).with.offset(5);
        make.right.equalTo(self.view.mas_right).with.offset(-15);
        make.size.equalTo(CGSizeMake(35, 35));
    }];
    
    setAlarm.text           = @"警报参数设置";
    setAlarm.font           = [UIFont systemFontOfSize:15.0f];
    setAlarm.textAlignment  = NSTextAlignmentCenter;
    [setAlarm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_scrollView.mas_centerX);
        make.top.equalTo(_longitudeLabel.mas_bottom).with.offset(30);
        make.size.equalTo(CGSizeMake(120, 35));
    }];
    
    //警报介绍
    alarmIntroduce.text         = @"警报介绍";
    alarmIntroduce.textColor    = [UIColor blackColor];
    alarmIntroduce.font         = [UIFont systemFontOfSize:13.0f];
    [alarmIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    //参数设置
    parameterSet.text           = @"参数设置";
    parameterSet.textColor      = [UIColor blackColor];
    parameterSet.font           = [UIFont systemFontOfSize:13.0f];
    parameterSet.textAlignment  = NSTextAlignmentCenter;
    [parameterSet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_scrollView.centerX);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    //是否启用
    enableLabel.text        = @"是否启用";
    enableLabel.textColor   = [UIColor blackColor];
    enableLabel.font        = [UIFont systemFontOfSize:13.0f];
    [enableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.right);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    //用水过量报警
    _excessiveAlarmLabel.text       = @"用水过量报警";
    _excessiveAlarmLabel.textColor  = [UIColor darkGrayColor];
    _excessiveAlarmLabel.font       = [UIFont systemFontOfSize:10.0f];
    [_excessiveAlarmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(alarmIntroduce.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
    _excessiveAlarmTextField.text = @"100";
    [_excessiveAlarmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alarmIntroduce.mas_bottom).with.offset(10);
        make.centerX.equalTo(_scrollView.centerX);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    excessiveAlarmUnit.text = @"吨/时";
    [excessiveAlarmUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_excessiveAlarmTextField.mas_right).with.offset(5);
        make.top.equalTo(alarmIntroduce.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    _excessiveSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_excessiveSwitchBtn];
    [_excessiveSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alarmIntroduce.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    //水表倒流
    _reversalAlarmLabel.text = @"水表倒流";
    [_reversalAlarmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(_excessiveAlarmLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
    _reversalAlarmTextField.text = @"1";
    [_reversalAlarmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_scrollView.centerX);
        make.top.equalTo(excessiveAlarmUnit.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    reversalAlarmUnit.text = @"吨/天";
    [reversalAlarmUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_reversalAlarmTextField.mas_right).with.offset(5);
        make.top.equalTo(_excessiveAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    _reversalSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_reversalSwitchBtn];
    [_reversalSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(excessiveAlarmUnit.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    //长时间不在线
    _longTimeNotServer.text = @"长时间不在线";
    [_longTimeNotServer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(_reversalAlarmLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
    _longTimeNotServerTextField.text = @"50";
    [_longTimeNotServerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_scrollView.centerX);
        make.top.equalTo(_reversalAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    longTimeNotServerUnit.text = @"小 时";
    [longTimeNotServerUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_reversalAlarmTextField.mas_right).with.offset(5);
        make.top.equalTo(_reversalAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    _longTimeNotServerSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_longTimeNotServerSwitchBtn];
    [_longTimeNotServerSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reversalAlarmUnit.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    //日用量超量程
    dayOverFlow.text = @"日用量超量程";
    [dayOverFlow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(_longTimeNotServer.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
    _limitOfDayUsageAlarmTextField.text = @"1000";
    [_limitOfDayUsageAlarmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_longTimeNotServerTextField.mas_bottom).with.offset(10);
        make.centerX.equalTo(_scrollView.centerX);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    dayOverFlowUnit.text = @"吨/天";
    [dayOverFlowUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_limitOfUsageAlarmTextField.mas_right).with.offset(5);
        make.top.equalTo(_longTimeNotServerTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    _limitOfDayUsageSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_limitOfDayUsageSwitchBtn];
    [_limitOfDayUsageSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_longTimeNotServer.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    //长时间没有用水
    longtimeNotUse.text = @"长时间没有用水";
    [longtimeNotUse mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(dayOverFlow.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    _longtimeNotUseSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_longtimeNotUseSwitchBtn];
    [_longtimeNotUseSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dayOverFlowUnit.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    //月用水上限
    _limitOfUsageLabel.text = @"月用水上限";
    [_limitOfUsageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(longtimeNotUse.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
    _limitOfUsageAlarmTextField.text = @"0";
    [_limitOfUsageAlarmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(longtimeNotUse.mas_bottom).with.offset(10);
        make.centerX.equalTo(_scrollView.centerX);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    limitOfUsageAlarmUnit.text = @"吨/天";
    [limitOfUsageAlarmUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_limitOfUsageAlarmTextField.mas_right).with.offset(5);
        make.top.equalTo(longtimeNotUse.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    _limitOfUsageSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_limitOfUsageSwitchBtn];
    [_limitOfUsageSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(longtimeNotUse.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    
    //时段用水上限
    intervalLabel.text = @"时段用水上限";
    [intervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(_limitOfUsageLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(80, 25));
    }];
    
    _fromLabel.text = @"从";
    [_fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(intervalLabel.mas_right);
        make.top.equalTo(_limitOfUsageAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(15, 25));
    }];
    
    [_fromTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_fromLabel.mas_right).with.offset(5);
        make.top.equalTo(_limitOfUsageAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    _toLabel.text = @"到";
    [_toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_fromTextField.mas_right).with.offset(5);
        make.top.equalTo(_limitOfUsageAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(15, 25));
    }];
    
    [_toTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toLabel.mas_right).with.offset(5);
        make.top.equalTo(_limitOfUsageAlarmTextField.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    _fromToSwitchBtn = [[UISwitch alloc] init];
    [_scrollView addSubview:_fromToSwitchBtn];
    [_fromToSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_limitOfUsageAlarmTextField.mas_bottom).with.offset(5);
        make.centerX.equalTo(enableLabel.centerX);
    }];
    
    
    //备注信息
    _remarksLabel.text      = @"备注信息";
    _remarksLabel.textColor = [UIColor blueColor];
    [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(5);
        make.top.equalTo(intervalLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    
    _remarksTextView                        = [[UITextView alloc] init];
    _remarksTextView.font                   = [UIFont systemFontOfSize:13];
    _remarksTextView.layer.borderColor      = [[UIColor blackColor] CGColor];
    _remarksTextView.layer.borderWidth      = 1;
    _remarksTextView.layer.cornerRadius     = 6;
    _remarksTextView.layer.masksToBounds    = YES;
    [_scrollView addSubview:_remarksTextView];
    [_remarksTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_remarksLabel.mas_right);
        make.top.equalTo(intervalLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(100);
    }];
    
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
        }
    }else{
        
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{

        }];
    }

    return nil;
}

//保存数据
- (UIButton *)saveBtn
{
    
//    NSMutableArray *alarmArr = [NSMutableArray array];
//    [alarmArr removeAllObjects];
////    NSArray *switchBtnArr = @[_excessiveSwitchBtn,_longtimeNotUseSwitchBtn,_longTimeNotServerSwitchBtn,_limitOfDayUsageSwitchBtn,_reversalSwitchBtn,_limitOfUsageSwitchBtn,_fromToSwitchBtn];
////    for (int i = 0; i < alarmNsetList.count; i++) {
////        alarmArr addObject:[NSString stringWithFormat:@"%d",((UISwitch *)switchBtnArr[i]).isOn];
////    }
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_excessiveSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_longtimeNotUseSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_longTimeNotServerSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_limitOfDayUsageSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_reversalSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_limitOfUsageSwitchBtn.isOn]];
//    [alarmArr addObject:[NSString stringWithFormat:@"%d",_fromToSwitchBtn.isOn]];
//    
//    NSDictionary *alarmIsNull = [NSDictionary dictionary];
//    NSMutableArray *arr = [NSMutableArray array];
//    
//    for (int i = 0; i < alarmArr.count-1; i++) {
//        alarmIsNull = @{
//                        @"TorF":alarmArr[i],
//                        @"num":_numArray[i],
//                        };
//        [arr addObject:alarmIsNull];
//    }
//    
//    NSDictionary *sevenT = @{
//                             @"TorF":alarmArr[6],
//                             @"num":_idArray[6],
//                             @"time_first":_fromTextField.text,
//                             @"time_last":_toTextField.text
//                             };
//    
//    NSMutableArray *alarmIsNullArray = [NSMutableArray arrayWithObjects:arr,sevenT, nil];
//    NSLog(@"最终---%@",alarmIsNullArray);
    
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"正在保存..." duration:2 autoHide:YES];
    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/EditServlet1",self.ipLabel];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSDictionary *parameters = @{@"username":self.userNameLabel,
                                 @"password":self.passWordLabel,
                                 @"db":self.dbLabel,
                                 @"meter_id":self.meter_id,
                                 @"user_name":_installAddrTextField.text,
                                 @"user_addr":_user_addr,
                                 @"comm_id":_connectIDTextField.text,
                                 @"collector_id":_collectIDTextField.text,
                                 @"install_time":_installTimeTextField.text,
                                 @"meter_wid":_meter_idTextField.text,
                                 @"bz10":_wheelTypeTextField.text,
                                 @"collector_area":_regionTextField.text,
                                 @"meter_name":_meterTypeTextField.text,
                                 @"meter_cali":_caliberTextField.text,
                                 @"type":_remoteWayTextField.text,
                                 @"type_name":_remoteTypeTextField.text,
                                 @"x":_longitudeTextField.text,
                                 @"y":_latitudeTextField.text,
                                 @"time_first":_fromTextField.text,
                                 @"time_last":_toTextField.text,
                                 @"user_remark":_remarksTextView.text,
                                 //@"alarmIsNull":alarmIsNullArray,
                                 @"save4edit":@"save4edit",
                                 };
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSURLSessionTask *task                  = [manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            if ([[responseObject objectAtIndex:0] isEqualToString:@"1"]) {
                
                [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存成功" duration:2 autoHide:YES];
            } else {
                
                [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存失败" duration:2 autoHide:YES];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"保存失败" duration:2 autoHide:YES];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"错误信息：%@",error] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];

    [task resume];
    return nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_scrollView removeFromSuperview];
}

// 代理方法实现
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"经度：%f,纬度：%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"定位成功" duration:2 autoHide:YES];
    _longitudeTextField.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    _latitudeTextField.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    [_locationManager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"定位失败"];
}

- (void)changeAttr:(UIButton *)sender
{
    _pickerNameArr      = [NSArray array];
    _pickerTypeArr      = [NSArray array];
    _pickerCaliArr      = [NSArray array];
    _pickerWayArr       = [NSArray array];
    _pickerRemoTypeArr  = [NSArray array];
    
    _pickerNameArr      = nil;
    _pickerTypeArr      = nil;
    _pickerCaliArr      = nil;
    _pickerWayArr       = nil;
    _pickerRemoTypeArr  = nil;
    
    /*//所属区域
     NSArray *_pickerNameArr;
     //表具类型
     NSArray *_pickerTypeArr;
     //口径
     NSArray *_pickerCaliArr;
     //远传方式
     NSArray *_pickerWayArr;
     //远传类型
     NSArray *_pickerRemoTypeArr;*/
    if (sender.tag == 500) {//所属区域
        i = 500;
        NSString *string = [defaults objectForKey:@"area_list"];
        _pickerNameArr = [string componentsSeparatedByString:@","];
    }else if (sender.tag == 501) {//表具类型
        i = 501;
        NSString *string = [defaults objectForKey:@"meter_name_list"];
        _pickerTypeArr = [string componentsSeparatedByString:@","];
    } else if (sender.tag == 502) {//口径
        i = 502;
        NSString *string = [defaults objectForKey:@"meter_cali_list"];
        _pickerCaliArr = [string componentsSeparatedByString:@","];
    } else if (sender.tag == 503) {//远传方式
        i = 503;
        NSString *string = [defaults objectForKey:@"type_list"];
        _pickerWayArr = [string componentsSeparatedByString:@","];
    } else if (sender.tag == 504) {//远传类型
        i = 504;
        NSString *string = [defaults objectForKey:@"sb_type_list"];
        _pickerRemoTypeArr = [string componentsSeparatedByString:@","];
    }
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, PanScreenHeight, PanScreenWidth, 200)];
//    _pickerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"picker_bg.jpg"]];
    _pickerView.backgroundColor = [UIColor colorWithRed:244/255.0f green:243/255.0f blue:244/255.0f alpha:1];
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    if (sender.tag == 500) {
        for (int i = 0; i < _pickerNameArr.count; i++) {
            if ([_pickerNameArr[i] isEqualToString:_regionTextField.text]) {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                [_pickerView reloadComponent:0];
            }
        }
    } else if (sender.tag == 501) {
        for (int i = 0; i < _pickerTypeArr.count; i++) {
            if ([_pickerTypeArr[i] isEqualToString:_meterTypeTextField.text]) {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                [_pickerView reloadComponent:0];
            }
        }
    } else if (sender.tag == 502) {
        for (int i = 0; i < _pickerCaliArr.count; i++) {
            if ([_pickerCaliArr[i] isEqualToString:_caliberTextField.text]) {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                [_pickerView reloadComponent:0];
            }
        }
    }else if (sender.tag == 503) {
        for (int i = 0; i < _pickerWayArr.count; i++) {
            if ([_pickerWayArr[i] isEqualToString:_remoteWayTextField.text]) {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                [_pickerView reloadComponent:0];
            }
        }
    }else if (sender.tag == 504) {
        for (int i = 0; i < _pickerRemoTypeArr.count; i++) {
            if ([_pickerRemoTypeArr[i] isEqualToString:_remoteTypeTextField.text]) {
                [_pickerView selectRow:i inComponent:0 animated:YES];
                [_pickerView reloadComponent:0];
            }
        }
    }
    
    if (flag == NO) {
        
        [self.view addSubview:_pickerView];
        
        [UIView animateWithDuration:.3 animations:^{
            _pickerView.frame = CGRectMake(0, PanScreenHeight-200, PanScreenWidth, 200);
        } completion:^(BOOL finished) {
            
            flag = !flag;
        }];
        
    } else {
        
        [UIView animateWithDuration:.3 animations:^{
            
            _pickerView.frame = CGRectMake(0, PanScreenHeight, PanScreenWidth, 200);
            
        } completion:^(BOOL finished) {
            
            [_pickerView removeFromSuperview];
            flag = !flag;
        }];
        
    }
    
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (i == 500) {
        return _pickerNameArr.count;
    } else if(i == 501){
        return _pickerTypeArr.count;
    }else if(i == 502){
        return _pickerCaliArr.count;
    }else if(i == 503){
        return _pickerWayArr.count;
    }else if(i == 504){
        return _pickerRemoTypeArr.count;
    }
    return 0;
}
#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (i == 500) {
        
        return _pickerNameArr[row];
        
    } else if(i == 501) {
        
        return _pickerTypeArr[row];
        
    } else if (i == 502) {
        
        return _pickerCaliArr[row];
        
    } else if (i == 503) {
        
        return _pickerWayArr[row];
        
    }else
        
        return _pickerRemoTypeArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (i == 500) {
        
        _regionTextField.text       = [NSString stringWithFormat:@"%@",_pickerNameArr[row]];
    } else if (i == 501) {
        
        _meterTypeTextField.text    = [NSString stringWithFormat:@"%@",_pickerTypeArr[row]];
    } else if (i == 502) {
        
        _caliberTextField.text      = [NSString stringWithFormat:@"%@",_pickerCaliArr[row]];
    } else if (i == 503) {
        
        _remoteWayTextField.text    = [NSString stringWithFormat:@"%@",_pickerWayArr[row]];
    } else if (i == 504) {
        
        _remoteTypeTextField.text   = [NSString stringWithFormat:@"%@",_pickerRemoTypeArr[row]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:.3 animations:^{
        
        _pickerView.frame = CGRectMake(0, PanScreenHeight, PanScreenWidth, 200);
        
    } completion:^(BOOL finished) {
        
        [_pickerView removeFromSuperview];
        flag = !flag;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return  NO;
}
#pragma mark - LLSwitchDelegate
-(void)didTapLLSwitch:(LLSwitch *)llSwitch {
    if (!llSwitch.on) {
        [self usable];
    }else {
        [self unavailable];
    }
}
//- (void)valueDidChanged:(LLSwitch *)llSwitch on:(BOOL)on {
//
//    if (!on) {
//        [self unavailable];
//    }else {
//        [self usable];
//    }
//}

- (void)unavailable {
    
    _installAddrTextField.delegate  = self;
    _installAddrTextField.textColor = [UIColor lightGrayColor];
    
    _meter_idTextField.delegate     = self;
    _meter_idTextField.textColor    = [UIColor lightGrayColor];
    
    _connectIDTextField.delegate    = self;
    _connectIDTextField.textColor   = [UIColor lightGrayColor];
    
    _collectIDTextField.delegate    = self;
    _collectIDTextField.textColor   = [UIColor lightGrayColor];
    
    _installTimeTextField.delegate  = self;
    _installTimeTextField.textColor = [UIColor lightGrayColor];
    
    _wheelTypeTextField.delegate    = self;
    _wheelTypeTextField.textColor   = [UIColor lightGrayColor];
}
- (void)usable {
    
    _installAddrTextField.delegate  = nil;
    _installAddrTextField.textColor = [UIColor blackColor];
    
    _meter_idTextField.delegate     = nil;
    _meter_idTextField.textColor    = [UIColor blackColor];
    
    _connectIDTextField.delegate    = nil;
    _connectIDTextField.textColor   = [UIColor blackColor];
    
    _collectIDTextField.delegate    = nil;
    _collectIDTextField.textColor   = [UIColor blackColor];
    
    _installTimeTextField.delegate  = nil;
    _installTimeTextField.textColor = [UIColor blackColor];
    
    _wheelTypeTextField.delegate    = nil;
    _wheelTypeTextField.textColor   = [UIColor blackColor];
}
@end
