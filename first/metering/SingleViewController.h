//
//  SingleViewController.h
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleViewController : UIViewController

<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate
>
//SingleViewController.xib
- (IBAction)takePhoto:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


- (IBAction)uploadPhoto:(id)sender;
- (IBAction)saveToLocal:(id)sender;

@property (nonatomic, strong) NSString *meter_id_string;
@property (weak, nonatomic) IBOutlet UILabel *meter_id;

//上期抄表度数
@property (weak, nonatomic) IBOutlet UITextField *previousReading;
//上期抄表时间
@property (weak, nonatomic) IBOutlet UITextField *previousSettle;
//本期抄表值
@property (weak, nonatomic) IBOutlet UITextField *thisPeriodValue;
//抄表情况
@property (weak, nonatomic) IBOutlet UITextField *meteringSituation;
//抄表说明
@property (weak, nonatomic) IBOutlet UITextField *meteringExplain;


//表样拍照
@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
//初始示值照片
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
//表号、条码照片
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;


//用户信息
@property (nonatomic, strong) NSString *ipLabel;
@property (nonatomic, strong) NSString *dbLabel;
@property (nonatomic, strong) NSString *userNameLabel;
@property (nonatomic, strong) NSString *passWordLabel;

@property (nonatomic, strong) CLLocationManager* locationManager;

//经纬度
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

//用户名
@property (weak, nonatomic) IBOutlet UILabel *user_name;
//安装地址
@property (weak, nonatomic) IBOutlet UILabel *install_addr;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSString *collect_area;

#pragma mark - 测试第二版样张
//用户名
//@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (nonatomic, assign) BOOL isBigMeter;























@end
