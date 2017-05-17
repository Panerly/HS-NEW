//
//  MeterEditScrollView.h
//  first
//
//  Created by HS on 16/7/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterEditScrollView : UIScrollView
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
//表具类型
@property (nonatomic, strong) UILabel *meterTypeLabel;
//口径
@property (nonatomic, strong) UILabel *caliberLabel;
//经度
@property (nonatomic, strong) UILabel *longitudeLabel;
@property (nonatomic, strong) UITextField *longitudeTextField;
//纬度
@property (nonatomic, strong) UILabel *latitudeLabel;
@property (nonatomic, strong) UITextField *latitudeTextField;
//用水过量报警
@property (nonatomic, strong) UILabel *excessiveAlarmLabel;
@property (nonatomic, strong) UITextField *excessiveAlarmTextField;
//水表倒流报警
@property (nonatomic, strong) UILabel *reversalAlarmLabel;
@property (nonatomic, strong) UITextField *reversalAlarmTextField;
//月用水量上限
@property (nonatomic, strong) UILabel *limitOfUsageLabel;
@property (nonatomic, strong) UITextField *limitOfUsageAlarmTextField;


//时段用水上限值
//从
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UITextField *fromTextField;
//到
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *toTextField;


//备注信息
@property (nonatomic, strong) UILabel *remarksLabel;
@property (nonatomic, strong) UITextField *remarksTextField;

//定位button
@property (nonatomic, strong) UIButton *locaBtn;

@property (nonatomic, strong) UIButton *saveBtn;
@end
