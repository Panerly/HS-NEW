//
//  MeterEditViewController.h
//  first
//
//  Created by HS on 16/6/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterEditModel.h"

@interface MeterEditViewController : UIViewController

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *dataArr;

//用户信息
@property (nonatomic, strong) NSString *ipLabel;
@property (nonatomic, strong) NSString *dbLabel;
@property (nonatomic, strong) NSString *userNameLabel;
@property (nonatomic, strong) NSString *passWordLabel;

@property (nonatomic, strong) NSString *meter_id;

@property (nonatomic, strong) MeterEditModel *meterEditModel;


@property (nonatomic, strong) UIScrollView *scrollView;
//安装地址
@property (nonatomic, strong) NSString *user_addr;
//用户号
@property (nonatomic, strong) UILabel *userID;
//表位号
@property (nonatomic, strong) UILabel *meterID;
//安装地址
@property (nonatomic, strong) UILabel *installAddrLabel;
@property (nonatomic, strong) UITextField *installAddrTextField;
//单位地址
@property (nonatomic, strong) UILabel *unitAddressLabel;
@property (nonatomic, strong) UITextField *unitAddressTextField;
//表身号
@property (nonatomic, strong) UILabel *meter_idLabel;
@property (nonatomic, strong) UITextField *meter_idTextField;
//通讯联络号
@property (nonatomic, strong) UILabel *connectIDLabel;
@property (nonatomic, strong) UITextField *connectIDTextField;
//采集编号
@property (nonatomic, strong) UILabel *collectIDLabel;
@property (nonatomic, strong) UITextField *collectIDTextField;
//安装时间
@property (nonatomic, strong) UILabel *installTimeLabel;
@property (nonatomic, strong) UITextField *installTimeTextField;
//字轮类型
@property (nonatomic, strong) UILabel *wheelTypeLabel;
@property (nonatomic, strong) UITextField *wheelTypeTextField;
//所属区域
@property (nonatomic, strong) UILabel *regionLabel;
@property (nonatomic, strong) UITextField *regionTextField;
//表具类型
@property (nonatomic, strong) UILabel *meterTypeLabel;
@property (nonatomic, strong) UITextField *meterTypeTextField;
//口径
@property (nonatomic, strong) UILabel *caliberLabel;
@property (nonatomic, strong) UITextField *caliberTextField;
//经度
@property (nonatomic, strong) UILabel *longitudeLabel;
@property (nonatomic, strong) UITextField *longitudeTextField;
//纬度
@property (nonatomic, strong) UILabel *latitudeLabel;
@property (nonatomic, strong) UITextField *latitudeTextField;
//远传方式
@property (nonatomic, strong) UITextField *remoteWayTextField;
//远传类型
@property (nonatomic, strong) UITextField *remoteTypeTextField;
//用水过量报警
@property (nonatomic, strong) UILabel *excessiveAlarmLabel;
@property (nonatomic, strong) UITextField *excessiveAlarmTextField;
@property (nonatomic, strong) UISwitch *excessiveSwitchBtn;
//水表倒流报警
@property (nonatomic, strong) UILabel *reversalAlarmLabel;
@property (nonatomic, strong) UITextField *reversalAlarmTextField;
@property (nonatomic, strong) UISwitch *reversalSwitchBtn;

//日用水量上限
@property (nonatomic, strong) UISwitch *limitOfDayUsageSwitchBtn;
@property (nonatomic, strong) UITextField *limitOfDayUsageAlarmTextField;
//月用水量上限
@property (nonatomic, strong) UILabel *limitOfUsageLabel;
@property (nonatomic, strong) UITextField *limitOfUsageAlarmTextField;
@property (nonatomic, strong) UISwitch *limitOfUsageSwitchBtn;
//长时间不在线
@property (nonatomic, strong) UITextField *longTimeNotServerTextField;
@property (nonatomic, strong) UISwitch *longTimeNotServerSwitchBtn;
@property (nonatomic, strong) UILabel *longTimeNotServer;
//长时间没有用水
@property (nonatomic, strong) UISwitch *longtimeNotUseSwitchBtn;

//时段用水上限值
//从
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UITextField *fromTextField;
//到
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *toTextField;
@property (nonatomic, strong) UISwitch *fromToSwitchBtn;

//备注信息
@property (nonatomic, strong) UILabel *remarksLabel;
@property (nonatomic, strong) UITextView *remarksTextView;

//定位button
@property (nonatomic, strong) UIButton *locaBtn;

//id 唯一标识符
@property (nonatomic, strong) NSMutableArray *idArray;
//参数
@property (nonatomic, strong) NSMutableArray *numArray;

@property (nonatomic, strong) UIButton *saveBtn;
@end
