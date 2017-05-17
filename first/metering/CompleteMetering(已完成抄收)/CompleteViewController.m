//
//  CompleteViewController.m
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CompleteViewController.h"
#import "CompleteTableViewCell.h"
#import "CompleteModel.h"

// 拼接字符串
static NSString *boundaryStr = @"--";   // 分隔字符串
static NSString *randomIDStr;           // 本次上传标示字符串
static NSString *uploadID;              // 上传(php)脚本中，接收文件字段


@interface CompleteViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isBigMeter;
    UIImage *_firstImage;
    UIImage *_secondImage;
    UIImage *_thirdImage;
    UILabel *alertLabel;
    UISegmentedControl *segmentedControl;
}
@property (nonatomic, strong) FMDatabase *db;
@property(nonatomic, strong) UIButton *selectAllBtn;//全选按钮
@property(nonatomic, strong) UIButton *uploadBtn;//上传
@property(nonatomic, strong) NSMutableArray *uploadArr;//上传数据的数组

@end

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已完成";
    
    [self createTableView];
    [self setUploadAndselectBtn];
    [self setSegmentedCtrl];
    
    self.uploadArr = [NSMutableArray array];
    
    randomIDStr = @"V2ymHFg03ehbqgZCaKO6jy";
    uploadID    = @"uploadFile";
}

- (void)setUploadAndselectBtn {
    //选择按钮
    UIButton *selectedBtn       = [UIButton buttonWithType:UIButtonTypeSystem];
    selectedBtn.frame           = CGRectMake(0, 0, 60, 30);
    [selectedBtn setTitle:@"选择" forState:UIControlStateNormal];
    [selectedBtn addTarget:self action:@selector(selectedBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithCustomView:selectedBtn];
//    self.navigationItem.rightBarButtonItem =selectItem;
    
    
    //全选
    _selectAllBtn       = [UIButton buttonWithType:UIButtonTypeSystem];
    _selectAllBtn.frame = CGRectMake(0, 0, 60, 30);
    [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_selectAllBtn addTarget:self action:@selector(selectAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem               = [[UIBarButtonItem alloc] initWithCustomView:_selectAllBtn];
    self.navigationItem.rightBarButtonItems = @[selectItem,leftItem];
    _selectAllBtn.hidden                    = YES;
    
    
    //上传按钮
    _uploadBtn                      = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadBtn.frame                = CGRectMake(25, PanScreenHeight - 50 - 49, PanScreenWidth - 50, (PanScreenWidth - 50)/7);
    _uploadBtn.backgroundColor      = [UIColor lightGrayColor];
    _uploadBtn.clipsToBounds        = YES;
    _uploadBtn.layer.cornerRadius   = (PanScreenWidth - 50)/7/2;
    _uploadBtn.enabled              = NO;
    [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [_uploadBtn addTarget:self action:@selector(uploadClick:) forControlEvents:UIControlEventTouchUpInside];
}
//上传按钮点击事件
- (void)uploadClick:(UIButton *) button {
    
    if (self.tableView.editing) {
        [self uploadDB];
    }
    else return;
}

- (void)uploadDB {
    
    [self uploadData:nil];
}
//选择按钮点击响应事件
- (void)selectedBtn:(UIButton *)button {
    
    _uploadBtn.enabled = YES;
    //支持同时选中多行
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing) {
        
        _selectAllBtn.hidden = NO;
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [self.uploadArr removeAllObjects];
        [self refreshBtnState];
    }else{
        
        _selectAllBtn.hidden       = YES;
        _uploadBtn.backgroundColor = [UIColor lightGrayColor];
        _uploadBtn.enabled         = NO;
        [button setTitle:@"选择" forState:UIControlStateNormal];
        [self.uploadArr removeAllObjects];
        [self refreshBtnState];
    }
    
}

//全选
- (void)selectAllBtnClick:(UIButton *)button {

    if (!self.uploadArr) {
        
        self.uploadArr = [NSMutableArray arrayWithCapacity:self.dataArr.count];
    }
    for (int i = 0; i < self.dataArr.count; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self.uploadArr addObject:self.dataArr[i]];
    }
    [self refreshBtnState];
    NSLog(@"self.deleteArr:%@  %@", self.uploadArr,self.dataArr);
}



//刷新上传按钮的状态
- (void)refreshBtnState{
    
    if (self.uploadArr.count >= 1) {
        
            [self.view addSubview:_uploadBtn];
        _uploadBtn.backgroundColor = [UIColor redColor];
    }else {
        
        if (self.uploadArr.count < 1) {
            
            _uploadBtn.backgroundColor = [UIColor lightGrayColor];
            [_uploadBtn removeFromSuperview];
        }
    }
}


//切换控件部署
- (void)setSegmentedCtrl {
    
    if (!segmentedControl) {
        
        segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"小表完成",@"大表完成"]];
        [segmentedControl setSelectedSegmentIndex:0];
        _isBigMeter = NO;
        [segmentedControl addTarget:self action:@selector(segmentedCtrlAction:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = segmentedControl;
        [self.tableView addSubview:segmentedControl];
        /*[segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(PanScreenWidth/2.5, 30));
            make.top.equalTo(self.view.mas_top).with.offset(69);
            make.centerX.equalTo(self.view.centerX);
        }];*/
    }
}
//大小表切换
- (void)segmentedCtrlAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self updateDB];
            _isBigMeter = NO;
            [self.uploadArr removeAllObjects];
            break;
        case 1:
            [self updateBigMeterDB];
            _isBigMeter = YES;
            [self.uploadArr removeAllObjects];
            break;
        default:
            break;
    }
}
/**
 *  查询数据库更新表格
 *
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createDB];
    [self updateDB];
}

//从数据库获取更新小表数据 刷新tableview
- (void)updateDB {
    [self.db open];
    
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM meter_complete where collect_area != '00' order by user_id"];
    
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([resultSet next]) {
        
        NSString *meter_id          = [resultSet stringForColumn:@"meter_id"];
        NSString *user_id           = [resultSet stringForColumn:@"user_id"];
        NSString *collect_time      = [resultSet stringForColumn:@"collect_time"];
        NSString *remark            = [resultSet stringForColumn:@"remark"];
        NSString *collecTime        = [resultSet stringForColumn:@"collect_time"];
        NSString *collect_num       = [resultSet stringForColumn:@"collect_num"];
        NSString *user_name         = [resultSet stringForColumn:@"user_name"];
        NSString *collect_area      = [resultSet stringForColumn:@"collect_area"];
        NSString *install_addr      = [resultSet stringForColumn:@"install_addr"];
        NSString *collect_avg       = [resultSet stringForColumn:@"collect_avg"];
        NSString *metering_status   = [resultSet stringForColumn:@"metering_status"];
        NSString *x                 = [resultSet stringForColumn:@"x"];
        NSString *y                 = [resultSet stringForColumn:@"y"];
        
        NSData *first_image  = [resultSet dataForColumn:@"Collect_img_name1"];
        NSData *second_image = [resultSet dataForColumn:@"Collect_img_name2"];
        NSData *third_image  = [resultSet dataForColumn:@"Collect_img_name3"];
        
        CompleteModel *completeModel    = [[CompleteModel alloc] init];
        completeModel.meter_id          = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id           =[NSString stringWithFormat:@"%@",user_id];
        completeModel.collect_time      = collecTime;
        completeModel.remark            = remark;
        completeModel.collect_num       = collect_num;
        completeModel.user_name         = user_name;
        completeModel.collect_area      = collect_area;
        completeModel.install_addr      = install_addr;
        completeModel.collect_avg       = collect_avg;
        completeModel.metering_status   = metering_status;
        completeModel.x                 = x;
        completeModel.y                 = y;
        completeModel.collect_time      = [NSString stringWithFormat:@"%@",collect_time];
        completeModel.image             = [UIImage imageWithData:first_image];
        completeModel.second_img        = [UIImage imageWithData:second_image];
        completeModel.third_img         = [UIImage imageWithData:third_image];
        
        [self.dataArr addObject:completeModel];

    }
    if (self.dataArr.count != 0) {

        if (alertLabel) {
            
            [alertLabel removeFromSuperview];
            alertLabel = nil;
        }
    }else{
        
        if (!alertLabel) {
            
            [self showAlertLabel];
        }
    }
    
    [self.db close];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showAlertLabel {
    if (!alertLabel) {
        
        alertLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        alertLabel.text             = @"暂无抄收数据";
        alertLabel.textColor        = [UIColor lightGrayColor];
        alertLabel.textAlignment    = NSTextAlignmentCenter;
        alertLabel.center           = self.view.center;
        [self.view addSubview:alertLabel];
    }
}

- (void)updateBigMeterDB {
    [self.db open];
    
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM meter_complete where collect_area = '00' order by user_id"];
    
    _dataArr               = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([resultSet next]) {
        
        NSString *meter_id        = [resultSet stringForColumn:@"meter_id"];
        NSString *user_id         = [resultSet stringForColumn:@"user_id"];
        NSString *remark          = [resultSet stringForColumn:@"remark"];
        NSString *collecTime      = [resultSet stringForColumn:@"collect_time"];
        NSString *collect_num     = [resultSet stringForColumn:@"collect_num"];
        NSString *user_name       = [resultSet stringForColumn:@"user_name"];
        NSString *collect_area    = [resultSet stringForColumn:@"collect_area"];
        NSString *install_addr    = [resultSet stringForColumn:@"install_addr"];
        NSString *collect_avg     = [resultSet stringForColumn:@"collect_avg"];
        NSString *metering_status = [resultSet stringForColumn:@"metering_status"];
        NSString *x               = [resultSet stringForColumn:@"x"];
        NSString *y               = [resultSet stringForColumn:@"y"];
        
        NSData *first_image       = [resultSet dataForColumn:@"Collect_img_name1"];
        NSData *second_image      = [resultSet dataForColumn:@"Collect_img_name2"];
        NSData *third_image       = [resultSet dataForColumn:@"Collect_img_name3"];
        
        CompleteModel *completeModel  = [[CompleteModel alloc] init];
        completeModel.meter_id        = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id         =[NSString stringWithFormat:@"%@",user_id];
        completeModel.collect_time    = collecTime;
        completeModel.remark          = remark;
        completeModel.collect_num     = collect_num;
        completeModel.user_name       = user_name;
        completeModel.collect_area    = collect_area;
        completeModel.install_addr    = install_addr;
        completeModel.collect_avg     = collect_avg;
        completeModel.metering_status = metering_status;
        completeModel.x               = x;
        completeModel.y               = y;
        completeModel.image           = [UIImage imageWithData:first_image];
        completeModel.second_img      = [UIImage imageWithData:second_image];
        completeModel.third_img       = [UIImage imageWithData:third_image];
        [_dataArr addObject:completeModel];
    }
    
    if (self.dataArr.count != 0) {

        if (alertLabel) {
            [alertLabel removeFromSuperview];
            alertLabel = nil;
        }
    }else{
        if (!alertLabel) {
            
            [self showAlertLabel];
        }
    }
    
    [self.db close];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

//连接数据库
- (void)createDB {
    NSString *doc      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db     = [FMDatabase databaseWithPath:fileName];
    self.db            = db;
}


- (void)createTableView {
    _tableView                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    //_tableView.backgroundColor = COLORRGB(227, 230, 255);
    [_tableView registerNib:[UINib nibWithNibName:@"CompleteTableViewCell" bundle:nil] forCellReuseIdentifier:@"completeID"];
    //去掉自带分割线
    [_tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

//取消选中时 将存放在self.deleteArr中的数据移除
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    [self.uploadArr removeObject:[self.dataArr objectAtIndex:indexPath.row]];
    [self refreshBtnState];
}

//是否可以编辑  默认的时YES
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//选择编辑的方式,按照选择的方式对表进行处理
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
    
}
//选择你要对表进行处理的方式  默认是删除方式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_uploadBtn.enabled || self.tableView.editing) {
        
        [self.uploadArr addObject:[self.dataArr objectAtIndex:indexPath.row]];
        [self refreshBtnState];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completeID" forIndexPath:indexPath];
    cell.layer.shouldRasterize  = YES;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CompleteTableViewCell" owner:self options:nil] lastObject];
    }
    cell.completeModel   = _dataArr[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
//    //长按手势
//    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
//    longPressed.minimumPressDuration = 1;
//    [cell addGestureRecognizer:longPressed];
    
    return cell;
}
//-(void)longPressedAct:(UILongPressGestureRecognizer *)gesture
//{
//    if(gesture.state == UIGestureRecognizerStateBegan) {
//        CGPoint point = [gesture locationInView:self.tableView];
//        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
//        if(indexPath == nil) return ;
//        self.tableView.editing = YES;
//        [self refreshBtnState];
//        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
//        _selectAllBtn.hidden = NO;
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadData:(id)sender {

    NSLog(@"需要上传的：%@",self.uploadArr);
    
    [AnimationView showInView:self.view];
    
    
    NSString *uploadUrl                = [NSString stringWithFormat:@"%@/Meter_Reading/Reading_nowServlet1",litMeterApi];
    
    AFSecurityPolicy *securityPolicy   = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionConfiguration *config  = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager      = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    [manager setSecurityPolicy:securityPolicy];
    
    NSMutableArray *install_addr_arr   = [NSMutableArray arrayWithCapacity:_uploadArr.count];
    
    NSMutableDictionary *paraDic       = [NSMutableDictionary dictionaryWithCapacity:_uploadArr.count];
    NSMutableArray *paraArr            = [NSMutableArray arrayWithCapacity:_uploadArr.count];
    NSMutableArray *imageArr           = [NSMutableArray array];

    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    
    //将有照片的户的地址存起来
    for (int i = 0; i < _uploadArr.count; i++) {
        
        if (((CompleteModel *)_uploadArr[i]).image) {
        
            //通过安装地址删除本地库信息（上传成功的话）
            [imageArr addObject:((CompleteModel *)_uploadArr[i]).install_addr];
        }
        
    }
    
    //设置图片扩展名
    for (int i = 0; i < _uploadArr.count; i++) {
        
        if (((CompleteModel *)_uploadArr[i]).image) {
            
            NSData *data  = UIImageJPEGRepresentation(((CompleteModel *)_uploadArr[i]).image, .1f);
            NSData *data2 = UIImageJPEGRepresentation(((CompleteModel *)_uploadArr[i]).second_img, .1f);
            
            if (i>imageArr.count-1) {
                if (data) {
                    
                    [imageDic setObject:data forKey:[NSString stringWithFormat:@"first%@.jpg",imageArr[imageArr.count-1]]];
                }
                if (data2) {
                    
                    [imageDic setObject:data2 forKey:[NSString stringWithFormat:@"second%@.jpg",imageArr[imageArr.count-1]]];
                }
            }else{
                if (data) {
                    
                    [imageDic setObject:data forKey:[NSString stringWithFormat:@"first%@.jpg",imageArr[i]]];
                }
                if (data2) {
                    
                    [imageDic setObject:data2 forKey:[NSString stringWithFormat:@"second%@.jpg",imageArr[i]]];
                }
            }
        }
    }
    
    
    for (int i = 0; i < _uploadArr.count; i++) {
        
        //通过安装地址删除本地库信息（上传成功的话）
        [install_addr_arr addObject:((CompleteModel *)_uploadArr[i]).install_addr];
        
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).meter_id forKey:@"meter_id"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_time forKey:@"collect_dt"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_num forKey:@"collect_num"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_avg forKey:@"collect_avg"];
        [paraDic setObject:[((CompleteModel *)_uploadArr[i]).metering_status isEqualToString:@""]?@"正常":((CompleteModel *)_uploadArr[i]).metering_status forKey:@"collect_status"];
        [paraDic setObject:@"1" forKey:@"bs"];
        
        [paraArr addObject:paraDic];
    }
    
    NSError *error;
    NSData *dataPara     = [NSJSONSerialization dataWithJSONObject:paraArr options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:dataPara encoding:NSUTF8StringEncoding];
    
    NSDictionary *para = @{
                           @"meter_key":jsonString
                           };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes    = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [self uploadFileWithURL:[NSURL URLWithString:uploadUrl] imageDic:imageDic pramDic:para manager:manager installArr:install_addr_arr];
}

#pragma mark - 私有方法
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadID,uploadFile];
    [strM appendFormat:@"Content-Type: %@\r\n\r\n", mimeType];
    
    NSLog(@"%@", strM);
    return [strM copy];
}

- (NSString *)bottomString:(NSString *)key value:(NSString *)value
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    [strM appendFormat:@"%@\r\n",value];
    
    
    NSLog(@"%@", strM);
    return [strM copy];
}

#pragma mark - 上传文件
- (void)uploadFileWithURL:(NSURL *)url imageDic:(NSDictionary *)imgDic pramDic:(NSDictionary *)pramDic manager:(AFHTTPSessionManager *)manager installArr:(NSMutableArray *)installArr
{
    // 1> 数据体
    
    NSMutableData *dataM = [NSMutableData data];
    
    //    [dataM appendData:[boundaryStr dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *name  in [imgDic allKeys]) {
        NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:name];
        [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
        [dataM appendData:[imgDic valueForKey:name]];
    }
    
    for (NSString *name  in [pramDic allKeys]) {
        NSString *bottomStr = [self bottomString:name value:[pramDic valueForKey:name]];
        [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [dataM appendData:[[NSString stringWithFormat:@"%@%@--\r\n", boundaryStr, randomIDStr] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:20];
    
    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;
    //    NSLog(@"%@",dataM);
    
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    __weak typeof(self) weakSelf         = self;

    // 3> 连接服务器发送请求
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            
            [AnimationView dismiss];
            
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
                
                NSLog(@"上传成功：%@",responseObject);
                
                if ([weakSelf.db open]) {
                    
                    for (int i = 0; i < _uploadArr.count; i++) {
                        
                        if (installArr.count > 0) {
                            
                            [weakSelf.db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where install_addr = '%@'",installArr[i]]];
                        }
                    }
                    
                    [weakSelf.db close];
                } else {
                    
                    [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                }
                FMResultSet *restultSet = [weakSelf.db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
                [weakSelf.dataArr removeAllObjects];
                while ([restultSet next]) {
                    NSString *meter_id   = [restultSet stringForColumn:@"meter_id"];
                    NSString *user_id    = [restultSet stringForColumn:@"user_id"];
                    NSData *first_image  = [restultSet dataForColumn:@"Collect_img_name1"];
                    NSData *second_image = [restultSet dataForColumn:@"Collect_img_name2"];
                    NSData *third_image  = [restultSet dataForColumn:@"Collect_img_name3"];
                    
                    CompleteModel *completeModel = [[CompleteModel alloc] init];
                    completeModel.meter_id       = [NSString stringWithFormat:@"%@",meter_id];
                    completeModel.user_id        =[NSString stringWithFormat:@"%@",user_id];
                    completeModel.image          = [UIImage imageWithData:first_image];
                    completeModel.second_img     = [UIImage imageWithData:second_image];
                    completeModel.third_img      = [UIImage imageWithData:third_image];
                    [weakSelf.dataArr addObject:completeModel];
                }
                [weakSelf.db close];
                [weakSelf.uploadArr removeAllObjects];
                [weakSelf refreshBtnState];
                
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                if (weakSelf.dataArr.count>0) {
                    [weakSelf showAlertLabel];
                }
                [SCToastView showInView:weakSelf.tableView text:@"上传成功" duration:2.5 autoHide:YES];
            } else if ([[responseObject objectForKey:@"type"] isEqualToString:@"失败"]) {
                [SCToastView showInView:weakSelf.tableView text:@"上传失败" duration:2.5 autoHide:YES];
            }

        }
        if (error) {
            NSLog(@"上传失败：%@",error);
            [AnimationView dismiss];
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败！\n原因:%@",error] duration:5 autoHide:YES];
        }
    }];
    
    [task resume];
    
}

@end
