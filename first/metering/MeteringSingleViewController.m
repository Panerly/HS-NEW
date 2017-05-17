//
//  MeteringSingleViewController.m
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringSingleViewController.h"
#import "SingleViewController.h"
#import "MeteringSingleTableViewCell.h"

@interface MeteringSingleViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate
>
{
    NSString *cellID;
    BOOL isDone;
}


//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@end

@implementation MeteringSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"任务详情";
    
    self.navigationController.navigationBar.translucent = YES;
    
    
    [self _createTableView];
    [self getDataFromDB];
    isDone = NO;
}

- (void)getCompleteNum {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from meter_complete where collect_area = '%@'",_area_id]];
        
        int uncompleteNum = 0;
        int completeNum   = 0;
        
        while ([restultSet next]) {
            if ([restultSet stringForColumn:@"install_addr"]) {
                completeNum++;
            }
        }
        
        FMResultSet *restultSet2 = [db executeQuery:[NSString stringWithFormat:@"select * from litMeter_info where collector_area = '%@'",_area_id]];
        
        while ([restultSet2 next]) {
            if ([restultSet2 stringForColumn:@"install_addr"]) {
                uncompleteNum++;
            }
        }
        
        self.completeNum.text = [NSString stringWithFormat:@"完成数量： %d / %d 户", completeNum, uncompleteNum];
    }

}

//每次视图出现都重新加载数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getCompleteNum];
    if (isDone) {
        [self getCompleteDataFromDB];
    }else {
        [self getDataFromDB];
    }
}
//视图消失移除搜索框
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)_createTableView
{
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    
    cellID                  = @"meteringsingleID";
    
    _tableView.mj_header                            = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    _tableView.mj_header.automaticallyChangeAlpha   = YES;
    _tableView.keyboardDismissMode                  = UIScrollViewKeyboardDismissModeOnDrag;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MeteringSingleTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    //调用初始化searchController
    self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
    self.searchController.dimsBackgroundDuringPresentation      = NO;
    self.searchController.hidesNavigationBarDuringPresentation  = NO;
    self.searchController.searchBar.placeholder                 = @"搜索";
    
    self.searchController.searchBar.delegate    = self;
    self.searchController.searchResultsUpdater  = self;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];

}

//刷新
- (void)refreshData {
    if (isDone) {
        [self getCompleteDataFromDB];
    }else {
        [self getDataFromDB];
    }
}

//获取未抄收的数据
- (void)getDataFromDB {
    
    NSString *doc       = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName  = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  区域编码：%@", fileName, _area_id);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        //如果被网络覆盖了 则再删除本地中已抄收的数据
        FMResultSet *completeRestultSet = [db executeQuery:[NSString stringWithFormat:@"select * from meter_complete where collect_area = '%@'",_area_id]];
        while ([completeRestultSet next]) {
            
            NSString *install_addr = [completeRestultSet stringForColumn:@"install_addr"];
            [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",install_addr]];
        }
        
        //查询未抄收的 更新tableview
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from litMeter_info where collector_area = '%@'",_area_id]];
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        [_tableView.mj_header endRefreshing];
        
        while ([restultSet next]) {
            
            NSString *install_addr          = [restultSet stringForColumn:@"install_addr"];
            MeterInfoModel *meterinfoModel  = [[MeterInfoModel alloc] init];
            meterinfoModel.install_Addr     = install_addr;
            [_dataArr addObject:meterinfoModel];
        }
        self.messionCount.text = [NSString stringWithFormat:@"待抄数量： %ld 户",(long)_dataArr.count];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//获取已抄收的数据并更新
- (void)getCompleteDataFromDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  区域编码：%@", fileName, _area_id);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from meter_complete where collect_area = '%@'",_area_id]];
        _dataArr                = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        [_tableView.mj_header endRefreshing];
        
        while ([restultSet next]) {
            
            NSString *install_addr = [restultSet stringForColumn:@"install_addr"];
            MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
            meterinfoModel.install_Addr = install_addr;
            [_dataArr addObject:meterinfoModel];
        }
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}


#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchController.active?_searchResults.count:_dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MeteringSingleTableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle                 = UITableViewCellSelectionStyleNone;
    cell.backgroundColor                = [UIColor clearColor];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeteringSingleTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= self.searchController.active?_searchResults[indexPath.row]:_dataArr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDone) {
        
        SingleViewController *singleVC      = [[SingleViewController alloc] init];
        singleVC.meter_id_string            = self.searchController.active?((MeterInfoModel *)_searchResults[indexPath.row]).install_Addr:((MeterInfoModel *)_dataArr[indexPath.row]).install_Addr;
        singleVC.hidesBottomBarWhenPushed   = YES;
        singleVC.isBigMeter                 = NO;
        [self.navigationController pushViewController:singleVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//大小表切换
- (IBAction)segmentCtrl:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            isDone = NO;
            if (self.searchController.active) {
                self.searchController.active = NO;
            }
            [self getDataFromDB];
            break;
        case 1:
            isDone = YES;
            if (self.searchController.active) {
                self.searchController.active = NO;
            }
            [self getCompleteDataFromDB];
            break;
        default:
            break;
    }
}
#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults = [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate    = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr             = [NSMutableArray array];
    NSMutableArray *arr2            = [NSMutableArray array];
    [arr2 removeAllObjects];
    
    for (MeterInfoModel *model in self.dataArr) {
        [arr addObject:model.install_Addr];
    }
    arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    for (MeterInfoModel *model in self.dataArr) {
        if ([arr2 containsObject:model.install_Addr]) {
            [self.searchResults addObject:model];
        }
    }
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn = [searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}
@end
