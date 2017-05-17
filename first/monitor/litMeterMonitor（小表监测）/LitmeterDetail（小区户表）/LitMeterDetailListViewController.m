//
//  LitMeterDetailListViewController.m
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailListViewController.h"
#import "LitMeterDetailModel.h"
#import "LitMeterDetailTableViewCell.h"

#import "LitMeterDetailViewController.h"

@interface LitMeterDetailListViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate
>

{
    UIImageView *loadingView;
    NSURLSessionTask *task;
}

//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,assign,getter=isTableViewLoadData)BOOL tableViewLoadData;

@end

@implementation LitMeterDetailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"小区户表列表";
    
    [self setEffectView];
    
    [self initTableView];
    
    [self requestData];
}
- (void)ReturnTextBlock:(ReturnTextBlock)block {
    
    self.returnTextBlock = block;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    
    if (self.searchController.active) {
        
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
    if (task) {
        
        [task cancel];
    }
}

- (void)startLoading {
    //刷新控件
    loadingView         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loadingView.center  = self.view.center;
    UIImage *image      = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loadingView setImage:image];
    [self.view addSubview:loadingView];
}

- (void)setEffectView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setImage:[UIImage imageNamed:@"bg_server.jpg"]];
    [self.view addSubview:imageView];
    
    UIVisualEffectView *effectView;
    if (!effectView) {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    }
    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    [self.view addSubview:effectView];
}

- (void)initTableView {
    _tableView                      = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64)];
    _tableView.delegate             = self;
    _tableView.dataSource           = self;
    _tableView.backgroundColor      = [UIColor clearColor];
    _tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeOnDrag;
    
    [_tableView registerNib:[UINib nibWithNibName:@"LitMeterDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"litMeterDetailCellID"];
    
    self.tableView.separatorStyle = NO;
    [_tableView setExclusiveTouch:YES];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
    //调用初始化searchController
    self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
    self.searchController.dimsBackgroundDuringPresentation      = NO;
    self.searchController.hidesNavigationBarDuringPresentation  = YES;
    self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    self.searchController.searchBar.placeholder                 = @"搜索";
    
    self.searchController.searchBar.delegate    = self;
    self.searchController.searchResultsUpdater  = self;
    //搜索栏表头视图
    self.tableView.tableHeaderView              = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    [GCDQueue executeInMainQueue:^{
        // Load data.
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < self.dataArr.count; i++) {
            
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        self.tableViewLoadData = YES;
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } afterDelaySecs:0.25f];
    
    [self.view addSubview:_tableView];
}

- (void)requestData {
    
    [AnimationView showInView:self.view];
    if (self.tableView.mj_header.state == MJRefreshStateRefreshing) {
        
        [AnimationView dismiss];
    }
    AFHTTPSessionManager *manager               = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *serializer        = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval   = 60;
    serializer.acceptableContentTypes           = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *communityURL                      = [NSString stringWithFormat:@"%@/Small_Meter_Reading/Small_New_DataServlet",litMeterApi];
    __weak typeof(self) weekSelf                = self;

    NSDictionary *parameters = @{
                                 @"name":self.village_name
                                 };

    task = [manager POST:communityURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            [weekSelf.tableView.mj_header endRefreshing];
            NSError *error = nil;
            [AnimationView dismiss];
            [SVProgressHUD showInfoWithStatus:@"加载成功"];

            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];

            for (NSDictionary *dic in responseObject) {
                LitMeterDetailModel *model = [[LitMeterDetailModel alloc] initWithDictionary:dic error:&error];
                [_dataArr addObject:model];
            }
            
            _abnormalDataArr = [NSMutableArray array];
            [_abnormalDataArr removeAllObjects];
            for (NSDictionary *dic in responseObject) {
                if ([[dic objectForKey:@"collect_Status"] isEqualToString:@"正常"]) {
                    
                }else {
                    
                    LitMeterDetailModel *model = [[LitMeterDetailModel alloc] initWithDictionary:dic error:&error];
                    [_abnormalDataArr addObject:model];
                }
            }
            
        }
        
        [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weekSelf.tableView.mj_header endRefreshing];
        [AnimationView dismiss];
        [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
    }];
    [task resume];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_isNormal isEqualToString:@"异常"]) {
        
        if ([((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collect_Status isEqualToString:@"抄收超时"]) {
            
            return 70;
        }else {
            
            return 90;
        }
    } else {
        if (![((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_Status isEqualToString:@"正常"]) {
            
            if ([((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_Status isEqualToString:@"抄收超时"]) {
                
                return 70;
            }else {
                
                return 90;
            }
        }else {
            
            return 70;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_isNormal isEqualToString:@"异常"]) {
        
        return self.isTableViewLoadData ? ((!self.searchController.active)?self.abnormalDataArr.count : self.searchResults.count):0;
        
    }else {
        
        return self.isTableViewLoadData ? ((!self.searchController.active)?self.dataArr.count : self.searchResults.count):0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LitMeterDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"litMeterDetailCellID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LitMeterDetailTabelCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
//    if (self.searchResults == nil) {
//        
//    }
    tableView.separatorStyle = NO;
    if (![_isNormal isEqualToString:@"正常"]) {
        cell.litMeterDetailModel = (!self.searchController.active)?_abnormalDataArr[indexPath.row] : self.searchResults[indexPath.row];
    }else {
        
        cell.litMeterDetailModel = (!self.searchController.active)?_dataArr[indexPath.row] : self.searchResults[indexPath.row];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LitMeterDetailViewController *detailVC = [[LitMeterDetailViewController alloc] init];
    
    if (![_isNormal isEqualToString:@"正常"]) {
        detailVC.meter_ID              = [self _clearLineBreak:((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).user_Id];
        detailVC.user_addr_str         = [self _clearLineBreak:[NSString stringWithFormat:@"地址:%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).user_addr:((LitMeterDetailModel *)_searchResults[indexPath.row]).user_addr]];
        detailVC.user_name_str         = [NSString stringWithFormat:@"户号:%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).user_Id:((LitMeterDetailModel *)_searchResults[indexPath.row]).user_Id];
        detailVC.collect_id_str        = [NSString stringWithFormat:@"采集编号：%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collect_no:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_no];
        
        detailVC.location_str          = [NSString stringWithFormat:@"所属区域：%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collector_area:((LitMeterDetailModel *)_searchResults[indexPath.row]).collector_area];
        detailVC.meter_condition_str   = [NSString stringWithFormat:@"表况：%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collect_Status:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_Status];
        detailVC.previous_reading_str  = [NSString stringWithFormat:@"上期读数：%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).up_collect_num:((LitMeterDetailModel *)_searchResults[indexPath.row]).up_collect_num];
        detailVC.current_reading_str   = [NSString stringWithFormat:@"本期读数：%@",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collect_num:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_num];
        detailVC.usage_str             = [NSString stringWithFormat:@"本期用量：%@ 吨",(!self.searchController.active)?((LitMeterDetailModel *)_abnormalDataArr[indexPath.row]).collect_yl:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_yl];

    }else {
        detailVC.meter_ID              = [self _clearLineBreak:((LitMeterDetailModel *)_dataArr[indexPath.row]).user_Id];
        detailVC.user_addr_str         = [self _clearLineBreak:[NSString stringWithFormat:@"地址:%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).user_addr:((LitMeterDetailModel *)_searchResults[indexPath.row]).user_addr]];
        detailVC.user_name_str         = [NSString stringWithFormat:@"户号:%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).user_Id:((LitMeterDetailModel *)_searchResults[indexPath.row]).user_Id];
        detailVC.collect_id_str        = [NSString stringWithFormat:@"采集编号：%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_no:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_no];
        detailVC.location_str          = [NSString stringWithFormat:@"所属区域：%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).collector_area:((LitMeterDetailModel *)_searchResults[indexPath.row]).collector_area];
        detailVC.meter_condition_str   = [NSString stringWithFormat:@"表况：%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_Status:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_Status];
        detailVC.previous_reading_str  = [NSString stringWithFormat:@"上期读数：%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).up_collect_num:((LitMeterDetailModel *)_searchResults[indexPath.row]).up_collect_num];
        detailVC.current_reading_str   = [NSString stringWithFormat:@"本期读数：%@",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_num:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_num];
        detailVC.usage_str             = [NSString stringWithFormat:@"本期用量：%@ 吨",(!self.searchController.active)?((LitMeterDetailModel *)_dataArr[indexPath.row]).collect_yl:((LitMeterDetailModel *)_searchResults[indexPath.row]).collect_yl];
        
    }
    detailVC.remark_str            = [NSString stringWithFormat:@"备注：暂无"];
    detailVC.water_type_str        = [NSString stringWithFormat:@"用水类型：居民用水"];
    detailVC.phone_num_str         = [NSString stringWithFormat:@"手机：暂无"];
    
//    if (self.returnTextBlock != nil) {
//        self.returnTextBlock(((LitMeterDetailModel *)_dataArr[indexPath.row]).);
//    }
    
    [SVProgressHUD dismiss];
    [self.navigationController showViewController:detailVC sender:nil];
}

- (NSString *)_clearLineBreak:(NSString *)string {
    
    //去除\n
    if ([string rangeOfString:@"\n"].location != NSNotFound) {
        [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    return string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults= [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    [arr2 removeAllObjects];
    
    if (![_isNormal isEqualToString:@"正常"]) {
        for (LitMeterDetailModel *model in self.abnormalDataArr) {
            [arr addObject:model.user_addr];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (LitMeterDetailModel *model in self.abnormalDataArr) {
            if ([arr2 containsObject:model.user_addr]) {
                [self.searchResults addObject:model];
            }
        }
    } else {
        for (LitMeterDetailModel *model in self.dataArr) {
            [arr addObject:model.user_addr];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (LitMeterDetailModel *model in self.dataArr) {
            if ([arr2 containsObject:model.user_addr]) {
                [self.searchResults addObject:model];
            }
        }
    }
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}


@end
