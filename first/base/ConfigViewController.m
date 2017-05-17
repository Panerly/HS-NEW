//
//  ConfigViewController.m
//  first
//
//  Created by HS on 16/5/24.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "ConfigViewController.h"
//#import "LoginViewController.h"
//#import "KeychainItemWrapper.h"

@interface ConfigViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
//{
//    KeychainItemWrapper *wrapper;
//}
{
    NSUserDefaults *defaults;
    BOOL flag;
    NSArray *_pickerIPArr;
    NSArray *_pickerNameArr;
    NSArray *_dBArr;
}
@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configKeyChainItemWrapper];
    flag = NO;
    
    defaults = [NSUserDefaults standardUserDefaults];

    
    _pickerIPArr    = [NSArray array];
    _pickerNameArr  = [NSArray array];
    _dBArr          = [NSArray array];
    _pickerNameArr  = @[@"杭州水表",@"杭水测试",@"杭州水务",@"浙江工商大学",@"中国科技大学",@"池州供排水",@"宣城水司",@"杭州下沙街道",@"成都节水办"];
    _dBArr          = @[@"bigmeter_water",@"bigmeter_water",@"bigmeter",@"bigmeter_zjgs",@"bigmeter_zkd",@"bigmeter_chizhou",@"bigmeter_xc",@"bigmeter_xs",@"bigmeter_chengdu"];
    _pickerIPArr    = @[@"60.191.39.206:8000",@"192.168.3.156:8080",@"122.224.204.102:8080",@"124.160.64.122:8080",@"202.141.176.120:8080",@"218.23.188.30:8000",@"58.243.104.26:8080",@"183.129.135.2:8080",@"125.70.9.203:5002"];
    
    self.IPConfig.text = [defaults objectForKey:@"ip"] == nil ? @"60.191.39.206:8000" : [defaults objectForKey:@"ip"];
    self.DBConfig.text = [defaults objectForKey:@"db"] == nil ? @"bigmeter_water" : [defaults objectForKey:@"db"];
}

//- (void)configKeyChainItemWrapper
//{
//    wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"IPNumber" accessGroup:@"hzsb.com.hzsbcop.pan"];
//    
//    //取出密码
//    self.IPConfig.text = [wrapper objectForKey:(id)kSecValueData];
//    
//    //取出账号
//    self.DBConfig.text = [wrapper objectForKey:(id)kSecAttrAccount];
//    
//    //清空设置
//    //    [wrapper resetKeychainItem];
//}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"unit"];
    
    _userCountLabel.text = [NSString stringWithFormat:@"%@",str == nil ? @"所属单位:杭州水表" : str];
}
//从storyboard加载
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self  = [[UIStoryboard storyboardWithName:@"Config" bundle:nil] instantiateViewControllerWithIdentifier:@"Config"];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//配置完成按钮
- (IBAction)saveBtn:(id)sender {
    
    //保存账号
//    [wrapper setObject:self.DBConfig.text forKey:(id)kSecAttrAccount];
//    
//    //保存密码
//    [wrapper setObject:self.IPConfig.text forKey:(id)kSecValueData];
    
    
    [defaults setObject:self.IPConfig.text forKey:@"ip"];
    [defaults setObject:self.DBConfig.text forKey:@"db"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)userCountBtn:(id)sender {

    if (!_pickerView) {
        
        _pickerView                 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, PanScreenHeight, PanScreenWidth, 200)];
        _pickerView.backgroundColor = [UIColor lightGrayColor];
        _pickerView.delegate        = self;
        _pickerView.dataSource      = self;
        
        for (int i = 0; i < _pickerNameArr.count; i++) {
            
            if ([_pickerNameArr[i] isEqualToString:[defaults objectForKey:@"count"]]) {
                
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_DBConfig resignFirstResponder];
    [_IPConfig resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        
        _pickerView.frame = CGRectMake(0, PanScreenHeight, PanScreenWidth, 200);
        
    } completion:^(BOOL finished) {
        
        [_pickerView removeFromSuperview];
        flag = !flag;
    }];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerNameArr.count;
}
#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return _pickerNameArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _userCountLabel.text = [NSString stringWithFormat:@"所属单位:  %@",_pickerNameArr[row]];
    [defaults setObject:_pickerNameArr[row] forKey:@"count"];
    [defaults setObject:_userCountLabel.text forKey:@"unit"];
    [defaults synchronize];
    _IPConfig.text = _pickerIPArr[row];
    _DBConfig.text = _dBArr[row];
}
@end
