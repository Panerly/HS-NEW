//
//  LitMeterListViewController.m
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterListViewController.h"
#import "LitMeterDetailListViewController.h"
#import "LitMeterListTableViewCell.h"
#import "LitMeterModel.h"

@interface LitMeterListViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
UISearchResultsUpdating
>
{
    UIImageView *loadingView;
    BOOL flag;//判断滑动的方向
    NSURLSessionTask *task;
    BOOL isNormal;
    UIButton *selectedBtn;
}

//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@end

@implementation LitMeterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isHisData?_isHisData:@"小区浏览";
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self setEffectView];
    
    [self initTableView];

    [self requestCommunityData];
    [self requestAbnormalCommunityData];
    
    //切换按钮
    selectedBtn         = [UIButton buttonWithType:UIButtonTypeSystem];
    selectedBtn.frame   = CGRectMake(0, 0, 60, 30);
    [selectedBtn setTitle:@"异常" forState:UIControlStateNormal];
    [selectedBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    isNormal = YES;
    [selectedBtn addTarget:self action:@selector(_selectDataSource:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectItem             = [[UIBarButtonItem alloc] initWithCustomView:selectedBtn];
    self.navigationItem.rightBarButtonItems = @[selectItem];
}

//选择全部数据还是抄收有异常的小区
- (void)_selectDataSource :(BOOL)DataSourceFlag {
    if (isNormal == YES) {
        if (!_dataArray) {
            [self requestCommunityData];
        }
        [selectedBtn setTitle:@"全部" forState:UIControlStateNormal];
        [selectedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        isNormal = !isNormal;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }else {
        if (!_abnormalDataArray) {
            [self requestAbnormalCommunityData];
        }
        [selectedBtn setTitle:@"异常" forState:UIControlStateNormal];
        [selectedBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        isNormal = !isNormal;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [task cancel];
}

- (void)startLoading {
    //刷新控件
    loadingView         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loadingView.center  = self.view.center;
    UIImage *image      = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loadingView setImage:image];
    [self.view addSubview:loadingView];
}

/**
 *  设置玻璃模糊效果
 */
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

/**
 *  请求小区数据
 */
#pragma mark - normal meter dataSource
- (void)requestCommunityData {
    
    [self startLoading];
    
    if (self.tableView.mj_header.state == MJRefreshStateRefreshing) {
        [loadingView removeFromSuperview];
    }
    
    NSURLSessionConfiguration *config           = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager               = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFHTTPResponseSerializer *serializer        = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval   = 30;
    serializer.acceptableContentTypes           = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *communityURL                      = [NSString stringWithFormat:@"%@/Small_Meter_Reading/Small_NumberServlet",litMeterApi];
    __weak typeof(self) weekSelf                = self;
    NSDictionary *para = @{
                           @"xqbh":[[NSUserDefaults standardUserDefaults] objectForKey:@"xqbh"]
                           };
    task = [manager POST:communityURL parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (!weekSelf.dataArray) {
            weekSelf.dataArray = [NSMutableArray array];
        }
        if (responseObject) {
            [weekSelf.tableView.mj_header endRefreshing];
            NSError *error = nil;
            for (NSDictionary *dic in responseObject) {
                LitMeterModel *litMeterModel = [[LitMeterModel alloc] initWithDictionary:dic error:&error];
                [weekSelf.dataArray addObject:litMeterModel];
            }
        }
        [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [SVProgressHUD showInfoWithStatus:@"加载成功"];
        if (loadingView) {
            [UIView animateWithDuration:.3 animations:^{
                loadingView.transform = CGAffineTransformMakeScale(.01, .01);
            } completion:^(BOOL finished) {
                
                [loadingView removeFromSuperview];
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (loadingView) {
            [loadingView removeFromSuperview];
            
        }
        [weekSelf.tableView.mj_header endRefreshing];
        if (error.code == 3840) {
            [SVProgressHUD showInfoWithStatus:@"服务器错误" maskType:SVProgressHUDMaskTypeGradient];
        }else{
            
            [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
        }
        
        NSLog(@"小区浏览页请求数据失败：\n%@",error);
    }];
    
    [task resume];
}

#pragma mark - abnormal meter dataSource
//请求异常小区
- (void)requestAbnormalCommunityData {
    if (!loadingView) {
        
        [self startLoading];
    }
    
    if (self.tableView.mj_header.state == MJRefreshStateRefreshing) {
        [loadingView removeFromSuperview];
    }
    
    NSURLSessionConfiguration *config           = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager               = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFHTTPResponseSerializer *serializer        = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval   = 60;
    serializer.acceptableContentTypes           = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *communityURL                      = [NSString stringWithFormat:@"%@/Small_Meter_Reading/NotNormalServlet",litMeterApi];
    __weak typeof(self) weekSelf                = self;
    NSDictionary *para = @{
                           @"xqbh":[[NSUserDefaults standardUserDefaults] objectForKey:@"xqbh"]
                           };
    task = [manager POST:communityURL parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if (!weekSelf.abnormalDataArray) {
            weekSelf.abnormalDataArray = [NSMutableArray array];
        }
        if (responseObject) {
            [weekSelf.tableView.mj_header endRefreshing];
            NSError *error = nil;
            for (NSDictionary *dic in responseObject) {
                LitMeterModel *litMeterModel = [[LitMeterModel alloc] initWithDictionary:dic error:&error];
                [weekSelf.abnormalDataArray addObject:litMeterModel];
            }
        }
        
        [SVProgressHUD showInfoWithStatus:@"加载成功"];
        if (loadingView) {
            
            [loadingView removeFromSuperview];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (loadingView) {
            
            [loadingView removeFromSuperview];
        }
        [weekSelf.tableView.mj_header endRefreshing];
        [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
        
        NSLog(@"小区浏览页请求数据失败：\n%@",error);
    }];
    
    [task resume];
}



//初始化tableview
- (void)initTableView {
    
    _tableView                      = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64 - 49)];
    _tableView.delegate             = self;
    _tableView.dataSource           = self;
    _tableView.backgroundColor      = [UIColor clearColor];
    _tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeOnDrag;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestCommunityData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
    //调用初始化searchController
    self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
    self.searchController.dimsBackgroundDuringPresentation      = NO;
    self.searchController.hidesNavigationBarDuringPresentation  = YES;
    self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    self.searchController.searchBar.placeholder                 = @"搜索";
    
    self.searchController.searchBar.delegate    = self;
    self.searchController.searchResultsUpdater  = (id)self;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    
    [_tableView registerNib:[UINib nibWithNibName:@"LitMeterListTableViewCell" bundle:nil] forCellReuseIdentifier:@"LitMeterListID"];
    
    [self.view addSubview:_tableView];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (isNormal) {
        
        return (!self.searchController.active)?self.dataArray.count : self.searchResults.count;
    }else {
        return (!self.searchController.active)?self.abnormalDataArray.count : self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LitMeterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LitMeterListID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LitMeterListTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    if (self.searchResults == nil) {
        
        tableView.separatorStyle = YES;
    }
    if (isNormal) {
        cell.litMeterModel = (!self.searchController.active)?_dataArray[indexPath.row] : self.searchResults[indexPath.row];
    } else {
        cell.litMeterModel = (!self.searchController.active)?_abnormalDataArray[indexPath.row] : self.searchResults[indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    cell.textLabel.textColor = [UIColor redColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LitMeterDetailListViewController *detail = [[LitMeterDetailListViewController alloc] init];
    if (isNormal) {
        detail.village_name = (!self.searchController.active)?((LitMeterModel *)_dataArray[indexPath.row]).small_name:((LitMeterModel *)_searchResults[indexPath.row]).small_name;
    }else {
        detail.village_name = (!self.searchController.active)?((LitMeterModel *)_abnormalDataArray[indexPath.row]).small_name:((LitMeterModel *)_searchResults[indexPath.row]).small_name;
    }
    detail.isNormal = isNormal ? @"正常" : @"异常";
    detail.hidesBottomBarWhenPushed = YES;
    [SVProgressHUD dismiss];
    [self.navigationController showViewController:detail sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (flag) {
        
        cell.layer.transform = CATransform3DMakeTranslation(-PanScreenWidth, 1, 1);
        
    } else {
        
        cell.layer.transform = CATransform3DMakeTranslation(PanScreenWidth, 1, 1);
        
    }
    //设置动画时间为0.25秒,xy方向缩放的最终值为1
    [UIView animateWithDuration:.35 animations:^{
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
    } completion:nil];
    
}

float _oldY;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual: self.tableView]) {
        if (self.tableView.contentOffset.y > _oldY) {
            flag = YES;
        }
        else{
            flag = NO;
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 获取开始拖拽时tableview偏移量
    _oldY = self.tableView.contentOffset.y;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults = [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr     = [NSMutableArray array];
    NSMutableArray *arr2    = [NSMutableArray array];
    [arr2 removeAllObjects];
    
    if (isNormal) {
        for (LitMeterModel *litMeterModel in self.dataArray) {
            [arr addObject:litMeterModel.small_name];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (LitMeterModel *litMeterModel in self.dataArray) {
            if ([arr2 containsObject:litMeterModel.small_name]) {
                [self.searchResults addObject:litMeterModel];
            }
        }
    } else {
        for (LitMeterModel *litMeterModel in self.abnormalDataArray) {
            [arr addObject:litMeterModel.small_name];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (LitMeterModel *litMeterModel in self.abnormalDataArray) {
            if ([arr2 containsObject:litMeterModel.small_name]) {
                [self.searchResults addObject:litMeterModel];
            }
        }
    }
    //刷新表格
    [self.tableView reloadData];
}


//移除搜索栏
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}

@end
