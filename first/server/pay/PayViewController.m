//
//  PayViewController.m
//  first
//
//  Created by HS on 16/8/2.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "PayViewController.h"

@interface PayViewController ()<UITextFieldDelegate>


@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"水费缴纳";
    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    _createTime.font = [UIFont systemFontOfSize:15];
    _createTime.textAlignment = NSTextAlignmentCenter;
    _createTime.text = [NSString stringWithFormat:@"订单创建时间： %@",time];
    _moneyNum.delegate = self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"Pay" owner:self options:nil] lastObject];
    }
    return self;
}

#pragma mark - UITextFieldDelegate

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_money resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
- (IBAction)payBtn:(id)sender {
    [_money resignFirstResponder];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    if ([_moneyNum.text floatValue] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"金额不能为空！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    } else if ([_moneyNum.text floatValue]<.0f) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入正确的金额！" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"商户暂未开通！" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
@end
