//
//  LocaDBViewController.m
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LocaDBViewController.h"
#import "DBModel.h"
#import "TableViewCell.h"
#import "SingleViewController.h"

@interface LocaDBViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    BOOL isBigMeter;
}

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation LocaDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"本地数据";
    
    [self createTableView];
  
    [self setSegment];
    
    UIBarButtonItem *deletAll              = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_delete@3x"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteBtn)];
    self.navigationItem.rightBarButtonItem = deletAll;
    
}

- (void)deleteBtn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定删除 %@ 本地库数据？",isBigMeter?@"大表":@"小表"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmBtn  = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
        FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
        
        if ([db open]) {
            
            for (int i = 0; i < _dataArr.count; i++) {
                
                [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",((DBModel *)_dataArr[i]).user_addr]];
            }
            
            [db close];
            [_dataArr removeAllObjects];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
        }
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelBtn];
    [alertVC addAction:confirmBtn];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self segmentedControl:self.segmentedControl didScrollWithXOffset:0];
    if (isBigMeter) {
        [self queryBigMeterDB];
    }else{
        [self queryDB];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.db close];
}

- (void)setSegment {
    self.segmentedControl            = [[UISegmentedControl alloc] initWithItems:@[@"小表抄收",@"大表抄收"]];
    self.segmentedControl.frame      = CGRectMake(0, 0, PanScreenWidth/2.5, 30);
    [self.segmentedControl setTitle:@"小表抄收" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"大表抄收" forSegmentAtIndex:1];

    [self.segmentedControl addTarget:self action:@selector(segmentControl:) forControlEvents:UIControlEventValueChanged];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView    = self.segmentedControl;
    isBigMeter                       = NO;
}
- (void)segmentControl :(UISegmentedControl *)segmentedControl{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            
            [self queryDB];
            isBigMeter = NO;
            break;
        case 1:
            
            [self queryBigMeterDB];
            isBigMeter = YES;
            break;
        default:
            break;
    }
}


- (void)queryDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
   
    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:@"select *from litMeter_info where collector_area != '00' order by id"];
        
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([resultSet next]) {
            
            NSString *meter_id  = [resultSet stringForColumn:@"meter_id"];
            NSString *user_addr = [resultSet stringForColumn:@"install_addr"];

            DBModel *dbModel    = [[DBModel alloc] init];
            dbModel.meter_id    = [NSString stringWithFormat:@"%@",meter_id];
            dbModel.user_addr   =[NSString stringWithFormat:@"%@",user_addr];
            [_dataArr addObject:dbModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    self.db = db;
}

- (void)queryBigMeterDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
//    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:@"select *from litMeter_info where collector_area = '00' order by id"];
        
        _dataArr               = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([resultSet next]) {
            
            NSString *meter_id  = [resultSet stringForColumn:@"meter_id"];
            NSString *user_addr = [resultSet stringForColumn:@"install_addr"];
            
            DBModel *dbModel    = [[DBModel alloc] init];
            dbModel.meter_id    = [NSString stringWithFormat:@"%@",meter_id];
            dbModel.user_addr   =[NSString stringWithFormat:@"%@",user_addr];
            [_dataArr addObject:dbModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    self.db = db;
    
}


- (void)createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight - 49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    cell.DBModel = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SingleViewController *singleVC    = [[SingleViewController alloc] init];
    singleVC.meter_id_string          = ((DBModel *)_dataArr[indexPath.row]).user_addr;
    singleVC.meter_id.text            = ((DBModel *)_dataArr[indexPath.row]).meter_id;
    singleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:singleVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
