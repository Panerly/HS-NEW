//
//  UserInfoViewController.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserNameViewController.h"
#import "DateView.h"
#import "TZPopInputView.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *cellID;
    NSData *imageData;
    NSUserDefaults *defaults;
    UIDatePicker *datePicker;
}
@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账户信息";
    
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    [bgView setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
//    [self.view addSubview:bgView];
//    
//    UIVisualEffectView *effectView;
//    if (!effectView) {
//        effectView = [[UIVisualEffectView alloc] initWithFrame:self.view.frame];
//    }
//    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    [self.view addSubview:effectView];
    
    self.view.backgroundColor = COLORRGB(238, 238, 238);
    
    self.userIcon.clipsToBounds = YES;
    self.userIcon.layer.cornerRadius = 50;
    [self.userIcon.layer setMasksToBounds:YES];
    [self.userIcon.layer setBorderColor:COLORRGB(233, 233, 216).CGColor];
    [self.userIcon.layer setBorderWidth:2];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [self _setTableView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"userInfor" bundle:nil] instantiateViewControllerWithIdentifier:@"userInforID"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    if (imageData != nil) {
        [_userIcon setImage:[NSKeyedUnarchiver unarchiveObjectWithData:imageData] forState:UIControlStateNormal];
    }
    _userIcon.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.5 animations:^{
        _userIcon.transform = CGAffineTransformIdentity;
    }];
    
    if ([defaults objectForKey:@"userNameValue"] != nil) {
        _userNameLabel.text = [defaults objectForKey:@"userNameValue"];
    }
}

//设置输入框并赋值上次预设值
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_inputView) {
        self.inputView = [[TZPopInputView alloc] init];
    }
    if (![defaults objectForKey:@"litMeterAlarmValue"]) {
        _inputView.textFiled1.text = [defaults objectForKey:@"litMeterAlarmValue"];
    }
    if (![defaults objectForKey:@"bigMeterAlarmValue"]) {
        _inputView.textFiled2.text = [defaults objectForKey:@"bigMeterAlarmValue"];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        _userIcon.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }];
}

- (void)_setTableView
{
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = 5;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    cellID = @"attrIdenty";
}

//点击更换头像
- (IBAction)userImage:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *change = [UIAlertAction actionWithTitle:@"修改头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:change];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"修改昵称";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"修改警报参数";
    }
    if (indexPath.row == 2) {
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"] isEqualToString:@"男"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"] isEqualToString:@"女"]) {
            cell.textLabel.text = @"性别 : 男";
        }else {
            
            cell.textLabel.text = [NSString stringWithFormat:@"性别 ：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"]];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        UserNameViewController *userNameVC = [[UserNameViewController alloc] init];
        [self showViewController:userNameVC sender:nil];
    }
    if (indexPath.row == 1){
        
        self.inputView.titleLable.text = @"设置增幅警报";
        [self.inputView setItems:@[@"大表警报增幅值设置",@"小表警报增幅值设置"]];
        
        [self.inputView show];
        
//        self.inputView.textFiled1.placeholder = [defaults objectForKey:@"bigMeterAlarmValue"]?[defaults objectForKey:@"bigMeterAlarmValue"]:@"请输入";
//        self.inputView.textFiled2.placeholder = [defaults objectForKey:@"litMeterAlarmValue"]?[defaults objectForKey:@"litMeterAlarmValue"]:@"请输入";
        
        self.inputView.textFiled1.placeholder = @"请输入";
        self.inputView.textFiled2.placeholder = @"请输入";
        
        if ([defaults objectForKey:@"bigMeterAlarmValue"]) {
            self.inputView.textFiled1.text = [defaults objectForKey:@"bigMeterAlarmValue"];
        }
        if ([defaults objectForKey:@"litMeterAlarmValue"]) {
            self.inputView.textFiled2.text = [defaults objectForKey:@"litMeterAlarmValue"];
        }
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(defaults) weakDefaults = defaults;
        self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
            [weakSelf.inputView hide];
            [weakDefaults setObject:weakSelf.inputView.textFiled1.text forKey:@"bigMeterAlarmValue"];
            [weakDefaults setObject:weakSelf.inputView.textFiled2.text forKey:@"litMeterAlarmValue"];
            [weakDefaults synchronize];
        };
        
    }
    if (indexPath.row == 2) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *boy = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"男" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *girl = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"女" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:boy];
        [alert addAction:girl];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    [_userIcon setImage:image forState:UIControlStateNormal];

    imageData = [NSKeyedArchiver archivedDataWithRootObject:image];
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"image"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

- (void)setDatePicker
{
    NSString *bornDate;
    if (!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, PanScreenHeight-100-49, PanScreenWidth, 100)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.backgroundColor = [UIColor lightGrayColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, PanScreenHeight-100, PanScreenWidth, 30)];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [datePicker addSubview:btn];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy年MM月dd日";
        bornDate = [formatter stringFromDate:[defaults objectForKey:@"bornStr"]];
    }
    [self.view addSubview:datePicker];
    
    [defaults setObject:bornDate forKey:@"bornDate"];
    [defaults synchronize];
    [_tableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:.5 animations:^{
        datePicker.frame = CGRectMake(0, PanScreenHeight, PanScreenWidth, 100);
    } completion:^(BOOL finished) {
        [datePicker removeFromSuperview];
    }];
}

@end
