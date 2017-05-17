//
//  MeterEditScrollView.m
//  first
//
//  Created by HS on 16/7/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterEditScrollView.h"
#import "SCToastView.h"

@implementation MeterEditScrollView
static int flag = 0;
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (flag == 0) {
        [self _configContent];
        flag++;
    }
}

//控件部署
- (void)_configContent
{
    //    UILabel *label = [[UILabel alloc] init];
    //    label.backgroundColor = [UIColor blackColor];
    //    label.text = @"测试用";
    //    label.textColor = [UIColor whiteColor];
    //    [_scrollView addSubview:label];
    //    [label mas_makeConstraints:^(MASConstraintMaker *make) {
    //
    //        make.size.equalTo(CGSizeMake(100, 50));
    //        make.center.equalTo(_scrollView.center);
    //    }];
    
    //    NSArray *arr = @[@"_latitudeLabel",@"_longitudeLabel",@"_wheelTypeLabel",@"_collectTimeLabel",@"_collectIDLabel",@"_connectIDLabel",@"_meter_idLabel",@"_installAddrLabel",@"_unitAddressLabel",@"_userID",@"_meterID",@"_fromLabel",@"_toLabel",@"_remarksLabel",@"_limitOfUsageLabel",@"_excessiveAlarmLabel",@"_reversalAlarmLabel"];
    //    NSMutableArray *labelArr = [NSMutableArray arrayWithArray:arr];
    //    NSMutableArray *textFieldArr = [NSMutableArray arrayWithObjects:_latitudeTextField,_longitudeTextField,_wheelTypeTextField,_collectTimeTextField,_collectIDTextField,_connectIDTextField,_meter_idTextField,_installAddrTextField,_unitAddressTextField,_fromTextField,_toTextField,_remarksTextField,_limitOfUsageAlarmTextField,_reversalAlarmTextField,_excessiveAlarmTextField, nil];
    
    //    for (int i = 0; i < arr.count; i++) {
    //        labelArr[i] = [[UILabel alloc] init];
    //
    //        [_scrollView addSubview:labelArr[i]];
    //    }
    
    //    for (int i = 0; i < textFieldArr.count; i++) {
    //        textFieldArr[i] = [[UITextField alloc] init];
    //        [_scrollView addSubview:textFieldArr[i]];
    //    }
    
    
    _userID = [[UILabel alloc] init];
    _userID.text = @"用户号: ";
    _userID.font = [UIFont systemFontOfSize:13];
    _userID.textColor = [UIColor blueColor];
    [self addSubview:_userID];
    [_userID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(15);
        make.left.equalTo(self.mas_left).with.offset(10);
        make.size.equalTo(CGSizeMake(150, 25));
    }];
    
    _meterID = [[UILabel alloc] init];
    _meterID.text = @"表位号: ";
    _meterID.font = [UIFont systemFontOfSize:13];
    _meterID.textColor = [UIColor blueColor];
    [self addSubview:_meterID];
    [_meterID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(15);
        make.centerX.equalTo(self.centerX).with.offset(50);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _installAddrLabel = [[UILabel alloc] init];
    _installAddrLabel.textColor = [UIColor blueColor];
    _installAddrLabel.text = @"安装地址: ";
    _installAddrLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_installAddrLabel];
    [_installAddrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_meterID.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _meter_idLabel = [[UILabel alloc] init];
    _meter_idLabel.text = @"表身号: ";
    _meter_idLabel.font = [UIFont systemFontOfSize:13];
    _meter_idLabel.textColor = [UIColor blueColor];
    [self addSubview:_meter_idLabel];
    [_meter_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).with.offset(10);
        make.top.equalTo(_installAddrLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _connectIDLabel = [[UILabel alloc] init];
    _connectIDLabel.textColor = [UIColor blueColor];
    _connectIDLabel.text = @"通讯联络号: ";
    _connectIDLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_connectIDLabel];
    [_connectIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_meter_idLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _collectIDLabel = [[UILabel alloc] init];
    _collectIDLabel.textColor = [UIColor blueColor];
    _collectIDLabel.text = @"采集编号: ";
    _collectIDLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_collectIDLabel];
    [_collectIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_connectIDLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    
    _installTimeLabel = [[UILabel alloc] init];
    _installTimeLabel.textColor = [UIColor blueColor];
    _installTimeLabel.text = @"安装时间: ";
    _installTimeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_installTimeLabel];
    [_installTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_collectIDLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _wheelTypeLabel = [[UILabel alloc] init];
    _wheelTypeLabel.textColor = [UIColor blueColor];
    _wheelTypeLabel.text = @"字轮类型: ";
    _wheelTypeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_wheelTypeLabel];
    [_wheelTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_installTimeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _regionLabel = [[UILabel alloc] init];
    _regionLabel.textColor = [UIColor blueColor];
    _regionLabel.text = @"所属区域: ";
    _regionLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_regionLabel];
    [_regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_wheelTypeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _meterTypeLabel = [[UILabel alloc] init];
    _meterTypeLabel.textColor = [UIColor blueColor];
    _meterTypeLabel.text = @"表具类型: ";
    _meterTypeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_meterTypeLabel];
    [_meterTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_regionLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _caliberLabel = [[UILabel alloc] init];
    _caliberLabel.textColor = [UIColor blueColor];
    _caliberLabel.text = @"口     经: ";
    _caliberLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_caliberLabel];
    [_caliberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_meterTypeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    UILabel *remoteWay = [[UILabel alloc] init];
    remoteWay.textColor = [UIColor blueColor];
    remoteWay.text = @"远传方式: ";
    remoteWay.font = [UIFont systemFontOfSize:13];
    [self addSubview:remoteWay];
    [remoteWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(_caliberLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    UILabel *remoteType = [[UILabel alloc] init];
    remoteType.textColor = [UIColor blueColor];
    remoteType.text = @"远传类型";
    remoteType.font = [UIFont systemFontOfSize:13];
    [self addSubview:remoteType];
    [remoteType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(remoteWay.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(100, 25));
    }];
    
    _longitudeLabel = [[UILabel alloc] init];
    _longitudeLabel.textColor = [UIColor blueColor];
    _longitudeLabel.text = @"经度: ";
    _longitudeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_longitudeLabel];
    [_longitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
    
    _latitudeLabel = [[UILabel alloc] init];
    _latitudeLabel.textColor = [UIColor blueColor];
    _latitudeLabel.text = @"纬度: ";
    _latitudeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_latitudeLabel];
    [_latitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteType.mas_bottom).with.offset(10);
        make.centerX.equalTo(self.centerX);
        make.size.equalTo(CGSizeMake(50, 25));
    }];
//    //定位
//    _locaBtn = [[UIButton alloc] init];
//    [_locaBtn setImage:[UIImage imageNamed:@"定位3"] forState:UIControlStateNormal];
//    [_locaBtn addTarget:self action:@selector(buttoAction) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_locaBtn];
//    [_locaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(remoteType.mas_bottom).with.offset(5);
//        make.right.equalTo(self.mas_right).with.offset(-20);
//        make.size.equalTo(CGSizeMake(35, 35));
//    }];
    
    UILabel *setAlarm = [[UILabel alloc] init];
    setAlarm.textColor = [UIColor blueColor];
    setAlarm.text = @"警报参数设置";
    setAlarm.font = [UIFont systemFontOfSize:18];
    [self addSubview:setAlarm];
    [setAlarm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(_longitudeLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 35));
    }];
    
    //警报介绍
    UILabel *alarmIntroduce = [[UILabel alloc] init];
    alarmIntroduce.text = @"警报介绍";
    alarmIntroduce.font = [UIFont systemFontOfSize:13];
    [self addSubview:alarmIntroduce];
    [alarmIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    //参数设置
    UILabel *parameterSet = [[UILabel alloc] init];
    parameterSet.text = @"参数设置";
    parameterSet.font = [UIFont systemFontOfSize:13];
    [self addSubview:parameterSet];
    [parameterSet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    //是否启用
    UILabel *enableLabel = [[UILabel alloc] init];
    enableLabel.text = @"是否启用";
    enableLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:enableLabel];
    [enableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right);
        make.top.equalTo(setAlarm.mas_bottom);
        make.size.equalTo(CGSizeMake(60, 25));
    }];
    
    //用水过量报警
    _excessiveAlarmLabel = [[UILabel alloc] init];
    _excessiveAlarmLabel.text = @"用水过量报警";
    _excessiveAlarmLabel.textColor = [UIColor darkGrayColor];
    _excessiveAlarmLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_excessiveAlarmLabel];
    [_excessiveAlarmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(alarmIntroduce.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //水表倒流
    _reversalAlarmLabel = [[UILabel alloc] init];
    _reversalAlarmLabel.text = @"水表倒流";
    _reversalAlarmLabel.textColor = [UIColor darkGrayColor];
    _reversalAlarmLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_reversalAlarmLabel];
    [_reversalAlarmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(_excessiveAlarmLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //长时间不在线
    UILabel *longTimeNotServer = [[UILabel alloc] init];
    longTimeNotServer.text = @"长时间不在线";
    longTimeNotServer.textColor = [UIColor darkGrayColor];
    longTimeNotServer.font = [UIFont systemFontOfSize:10];
    [self addSubview:longTimeNotServer];
    [longTimeNotServer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(_reversalAlarmLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //日用量超量程
    UILabel *dayOverFlow = [[UILabel alloc] init];
    dayOverFlow.text = @"日用量超量程";
    dayOverFlow.textColor = [UIColor darkGrayColor];
    dayOverFlow.font = [UIFont systemFontOfSize:10];
    [self addSubview:dayOverFlow];
    [dayOverFlow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(longTimeNotServer.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //长时间没有用水
    UILabel *longtimeNotUse = [[UILabel alloc] init];
    longtimeNotUse.text = @"长时间没有用水";
    longtimeNotUse.textColor = [UIColor darkGrayColor];
    longtimeNotUse.font = [UIFont systemFontOfSize:10];
    [self addSubview:longtimeNotUse];
    [longtimeNotUse mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(dayOverFlow.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //月用水上限
    _limitOfUsageLabel = [[UILabel alloc] init];
    _limitOfUsageLabel.text = @"月用水上限";
    _limitOfUsageLabel.textColor = [UIColor darkGrayColor];
    _limitOfUsageLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_limitOfUsageLabel];
    [_limitOfUsageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(longtimeNotUse.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //时段用水上限
    UILabel *intervalLabel = [[UILabel alloc] init];
    intervalLabel.text = @"时段用水上限";
    intervalLabel.textColor = [UIColor darkGrayColor];
    intervalLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:intervalLabel];
    [intervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(_limitOfUsageLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    //备注信息
    _remarksLabel = [[UILabel alloc] init];
    _remarksLabel.text = @"备注信息";
    _remarksLabel.textColor = [UIColor blueColor];
    _remarksLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_remarksLabel];
    [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.top.equalTo(intervalLabel.mas_bottom).with.offset(10);
        make.size.equalTo(CGSizeMake(120, 25));
    }];
    
}

- (void)buttoAction
{
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"正在定位..." duration:2 autoHide:YES];
}


@end
