//
//  ScanImageViewController.m
//  first
//
//  Created by HS on 16/8/25.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "ScanImageViewController.h"

@interface ScanImageViewController ()
@property (strong, nonatomic) UIImageView *image;

@end

@implementation ScanImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backAction        = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    [backAction setImage:[UIImage imageNamed:@"icon_back@3x"] forState:UIControlStateNormal];
    UIBarButtonItem *backitem   = [[UIBarButtonItem alloc] initWithCustomView:backAction];
    self.navigationController.navigationItem.backBarButtonItem = backitem;
    
    self.view.backgroundColor   = [UIColor whiteColor];
    
    _image                      = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    _image.backgroundColor      = [UIColor redColor];
    
    NSString *doc               = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName          = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db              = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete"];
        while ([restultSet next]) {
            NSData *imageData = [restultSet dataForColumn:@"Collect_img_name1"];
            [self.image setImage:[UIImage imageWithData:imageData]];
        }
        [db close];
    }
    [self.view addSubview:_image];
    
}

@end
