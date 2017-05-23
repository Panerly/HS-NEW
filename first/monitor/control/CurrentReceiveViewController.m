//
//  CurrentReceiveViewController.m
//  first
//
//  Created by HS on 16/6/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CurrentReceiveViewController.h"
#import "AFNetworking.h"
#import "CurrentReceiveTableViewCell.h"
#import "DetailViewController.h"
#import "CRModel.h"
#import "DetailModel.h"
#import "HisDetailViewController.h"
#import "MeterEditViewController.h"
#import "AMWaveTransition.h"
#import "ListSelectView.h"

@interface CurrentReceiveViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UINavigationControllerDelegate
>
{
    NSString *identy;
    UIImageView *loading;
    NSMutableArray *areaListArr;
    NSMutableArray *flagListArr;
}
//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@end

@implementation CurrentReceiveViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    self.definesPresentationContext = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
     if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
     {
         self.edgesForExtendedLayout = UIRectEdgeNone;
     }
    
    identy = @"currentReceive";
    
    [self _getCode];
    
    [self initRightItem];
    
    [self _createTabelView];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"db"] isEqualToString:@"bigmeter_chizhou"]) {
        
        [self _requestAreaData:[[NSUserDefaults standardUserDefaults] objectForKey:@"flg"]];
    }else {
        
        [self _requestArea];
    }
    
    self.dataArr = [NSMutableArray array];
    areaListArr  = [NSMutableArray array];
    flagListArr  = [NSMutableArray array];
}

//选择所有数据item
- (void)initRightItem {
    
    UIButton *rightButton       = [[UIButton alloc]initWithFrame:CGRectMake(0,0,57,45)];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    rightButton.showsTouchWhenHighlighted = YES;
    
    [rightButton setTintColor:[UIColor whiteColor]];
    [rightButton setImage:[UIImage imageNamed:@"icon_more@3x"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showAllData:)forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem  = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)showAllData:(UIButton *)sender {
    
    ListSelectView *select_view = [[ListSelectView alloc] initWithFrame:self.view.bounds];
    
    select_view.choose_type     = MORECHOOSETITLETYPE;
    select_view.isShowCancelBtn = YES;
    select_view.isShowSureBtn   = NO;
    select_view.isShowTitle     = YES;
    
    __weak typeof(self) weakSelf = self;
    
    [select_view addTitleArray:areaListArr andTitleString:@"请选择区域" animated:YES completionHandler:^(NSString * _Nullable string, NSInteger index) {
        
        NSLog(@"%@------%ld",string,(long)index);
        [weakSelf _requestAreaData:flagListArr[index]];
    } withSureButtonBlock:^{
        
        NSLog(@"sure btn");
    }];

    [FTPopOverMenu showForSender:sender withMenuArray:@[@"  选择区域",@"  所有数据"] doneBlock:^(NSInteger selectedIndex) {
        
        switch (selectedIndex) {
            case 0:
            {
                if (areaListArr.count == 0) {
                    
                    [weakSelf _requestArea];
                }else {
                    
                    [weakSelf.view addSubview:select_view];
                }
            }
                break;
            case 1:
                
                [weakSelf _requestData];
                break;
                
            default:
                break;
        }
        
    } dismissBlock:^{
        
    }];
}


//请求区域信息
- (void)_requestArea {
    
    __weak typeof(self) weakSelf = self;
    
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"请稍等" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/waterweb/GetareaServlet",self.ipLabel];
//    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.8.156:8080/waterweb/GetareaServlet"];//测试
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];

    manager.requestSerializer.timeoutInterval = 10;
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"];
    NSString *db = [[NSUserDefaults standardUserDefaults] objectForKey:@"db"];
    NSString *collector_area = [[NSUserDefaults standardUserDefaults] objectForKey:@"collector_area"];
    
    
    NSDictionary *para = @{
                           @"username":userName,
                           @"password":passWord,
                           @"db":db,
                           @"collector_area":collector_area
                           };
    
    NSURLSessionTask *areaTask = [manager GET:urlStr parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        
        if (responseObject) {
            
            for (NSDictionary *dic in responseObject) {
                
                if ([[dic objectForKey:@"collector_area"] isEqualToString:@"暂无分区"]) {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无分区" message:@"是否查看所有数据?" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf _requestData];
                    }];
                    [alert addAction:cancelAction];
                    [alert addAction:action];
                    [weakSelf presentViewController:alert animated:YES completion:^{
                        
                    }];
                }else {
                    
                    [areaListArr addObject:[dic objectForKey:@"collector_area"]];
                    [flagListArr addObject:[dic objectForKey:@"flg"]];
                }
            }
            if (areaListArr.count != 0) {
                
                [weakSelf showListView:areaListArr];
            }
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无数据" message:@"是否查看所有数据?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf _requestData];
            }];
            [alert addAction:cancelAction];
            [alert addAction:action];
            [weakSelf presentViewController:alert animated:YES completion:^{
                
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取区域列表失败，是否重试？" message:[NSString stringWithFormat:@"失败信息:%@",error] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf _requestArea];
        }];
        [alert addAction:cancelAction];
        [alert addAction:confirm];
        [weakSelf presentViewController:alert animated:YES completion:^{
            
        }];
    }];
    
    [areaTask resume];
}

//请求所在区域的数据
- (void)_requestAreaData:(NSString *)string {
    //刷新控件
    loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    if (_tableView.mj_header.isRefreshing) {
        
        [loading removeFromSuperview];
    }
    
    NSString *areaUrl                  = [NSString stringWithFormat:@"http://%@/waterweb/ListServlet",self.ipLabel];
//    NSString *areaUrl                  = [NSString stringWithFormat:@"http://192.168.8.156:8080/waterweb/ListServlet"];//测试用
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{
                                 @"username":self.userNameLabel,
                                 @"password":self.passWordLabel,
                                 @"db":self.dbLabel,
                                 @"type":self.typeLabel,
                                 @"flg":string
                                 };
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:areaUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [_tableView.mj_header endRefreshing];
            
            NSDictionary *responseObjectArr = [responseObject objectForKey:@"meters"];
            
            [self.dataArr removeAllObjects];
            
            for (NSDictionary *dic in responseObjectArr) {
                
                NSError *error = nil;
                
                CRModel *crModel = [[CRModel alloc] initWithDictionary:dic error:&error];
                
                [self.dataArr addObject:crModel];
                
            }
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [loading removeFromSuperview];
        }else {
            [loading removeFromSuperview];
            [_tableView.mj_header endRefreshing];
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无数据" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [loading removeFromSuperview];
        [_tableView.mj_header endRefreshing];
        
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
}

- (void)showListView:(NSMutableArray *)arr {
    
    ListSelectView *select_view = [[ListSelectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    
    select_view.choose_type     = MORECHOOSETITLETYPE;
    select_view.isShowCancelBtn = YES;
    select_view.isShowSureBtn   = NO;
    select_view.isShowTitle     = YES;
    
    
    __weak typeof(self) weakSelf = self;
    [select_view addTitleArray:arr andTitleString:@"请选择区域" animated:YES completionHandler:^(NSString * _Nullable string, NSInteger index) {
        
        NSLog(@"%@------%ld",string,(long)index);
        [weakSelf _requestAreaData:flagListArr[index]];
    } withSureButtonBlock:^{
        NSLog(@"sure btn");
    }];
    [self.view addSubview:select_view];
}

//获取用户信息
- (void)_getCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.userNameLabel  = [defaults objectForKey:@"userName"];
    self.passWordLabel  = [defaults objectForKey:@"passWord"];
    self.ipLabel        = [defaults objectForKey:@"ip"];
    self.dbLabel        = [defaults objectForKey:@"db"];
    self.typeLabel      = [defaults objectForKey:@"type"];
}

//添加cell动画
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.title isEqualToString:@"实时抄见"]) {
        
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        
        //设置动画时间为0.25秒,xy方向缩放的最终值为1
        [UIView animateWithDuration:.35 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:nil];
        
    }else if ([self.title isEqualToString:@"历史抄见"]){
        
        // 1. 配置CATransform3D的内容
        CATransform3D transform;
        transform       = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 0.7, 0.4);
        transform.m34   = 1.0/ -600;
        
        // 2. 定义cell的初始状态
        cell.layer.shadowColor  = [[UIColor blackColor]CGColor];
        cell.layer.shadowOffset = CGSizeMake(10, 10);
        cell.alpha              = 0;
        
        cell.layer.transform    = transform;
        cell.layer.anchorPoint  = CGPointMake(0, 0.5);
        
        // 3. 定义cell的最终状态，并提交动画
        [UIView beginAnimations:@"transform" context:NULL];
        [UIView setAnimationDuration:0.5];
        cell.layer.transform    = CATransform3DIdentity;
        cell.alpha              = 1;
        cell.layer.shadowOffset = CGSizeMake(0, 0);
        cell.frame              = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [UIView commitAnimations];
        
    }
    
}

//请求实时抄见数据
- (void)_requestData
{
    //刷新控件
    loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }
    
    NSString *logInUrl                  = [NSString stringWithFormat:@"http://%@/waterweb/LServlet1",self.ipLabel];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;

    NSDictionary *parameters = @{
                                 @"username":self.userNameLabel,
                                 @"password":self.passWordLabel,
                                 @"db":self.dbLabel,
                                 @"type":self.typeLabel,
                                 };

    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [_tableView.mj_header endRefreshing];
            
            NSDictionary *responseObjectArr = [responseObject objectForKey:@"meters"];
                        
            [self.dataArr removeAllObjects];

            for (NSDictionary *dic in responseObjectArr) {
                
                NSError *error = nil;
                
                CRModel *crModel = [[CRModel alloc] initWithDictionary:dic error:&error];
                
                [self.dataArr addObject:crModel];
                
            }
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [loading removeFromSuperview];
        }else {
            [loading removeFromSuperview];
            [_tableView.mj_header endRefreshing];
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无数据" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [loading removeFromSuperview];
        [_tableView.mj_header endRefreshing];
        
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
}

//创建tableview
- (void)_createTabelView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight-54*2) style:UITableViewStylePlain];
    
    self.tableView.separatorStyle = NO;
    [_tableView setExclusiveTouch:YES];
    
    _tableView.mj_header                            = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestData)];
    _tableView.mj_header.automaticallyChangeAlpha   = YES;
    _tableView.keyboardDismissMode                  = UIScrollViewKeyboardDismissModeOnDrag;
    
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
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];

    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    identy = @"currentReceive";
    
    [_tableView registerNib:[UINib nibWithNibName:@"CurrentReceive" bundle:nil] forCellReuseIdentifier:identy];
    
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDelegate UITableViewDataSource




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (!self.searchController.active)?self.dataArr.count : self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CurrentReceiveTableViewCell *crCell = [tableView dequeueReusableCellWithIdentifier:identy forIndexPath:indexPath];
    
    if (!crCell) {
        
        crCell = [[[NSBundle mainBundle] loadNibNamed:@"CurrentReceive" owner:self options:nil] lastObject];
    }

    if (self.searchResults == nil) {
        
        tableView.separatorStyle = YES;
    }
    crCell.backgroundColor = [UIColor clearColor];
    
    crCell.CRModel = (!self.searchController.active)?_dataArr[indexPath.row] : self.searchResults[indexPath.row];
    crCell.textLabel.textColor = [UIColor lightGrayColor];
    crCell.textLabel.font = [UIFont systemFontOfSize:14];
    crCell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    return crCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.title isEqualToString:@"实时抄见"]) {
        
        DetailViewController *detailVC  = [[DetailViewController alloc] init];
        
        detailVC.titleName              = (!self.searchController.active)?((CRModel *)_dataArr[indexPath.row]).meter_name : ((CRModel *)self.searchResults[indexPath.row]).meter_name;
        
        detailVC.crModel                = (!self.searchController.active)?_dataArr[indexPath.row] : _searchResults[indexPath.row];
        
        [self.navigationController showViewController:detailVC sender:nil];
    }
    
    if ([self.title isEqualToString:@"历史抄见"]) {
        
        HisDetailViewController *hisDetailVC = [[HisDetailViewController alloc] init];
        hisDetailVC.hidesBottomBarWhenPushed = YES;
        hisDetailVC.hisDetailModel = (!self.searchController.active)?_dataArr[indexPath.row] : _searchResults[indexPath.row];
        [self.navigationController showViewController:hisDetailVC sender:nil];
    }
    
    if ([self.title isEqualToString:@"水表修改"]) {
        
        MeterEditViewController *editDetailVC = [[MeterEditViewController alloc] init];
        editDetailVC.meter_id = (!self.searchController.active)?((CRModel *)_dataArr[indexPath.row]).meter_id : ((CRModel *)self.searchResults[indexPath.row]).meter_id;
        [self.navigationController showViewController:editDetailVC sender:nil];
    }
}

#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults= [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr     = [NSMutableArray array];
    NSMutableArray *arr2    = [NSMutableArray array];
    [arr2 removeAllObjects];
    
    for (CRModel *crModel in self.dataArr) {
        
        [arr addObject:crModel.meter_name];
    }
    arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    for (CRModel *crModel in self.dataArr) {
        
        if ([arr2 containsObject:crModel.meter_name]) {
            
            [self.searchResults addObject:crModel];
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

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    if (self.view.window == nil && [self isViewLoaded]) {
//        self.view = nil;
//    }
//}


#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}
#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeBounce];
    }
    return nil;
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}


@end
