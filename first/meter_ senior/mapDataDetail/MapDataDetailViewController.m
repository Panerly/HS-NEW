//
//  MapDataDetailViewController.m
//  first
//
//  Created by HS on 2016/12/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MapDataDetailViewController.h"
#import "LMReport.h"
#import "UIImageView+WebCache.h"


@interface MapDataDetailViewController ()<LMReportViewDatasource>

@property (nonatomic, strong) LMReportView *reportView;
@property (nonatomic, strong) NSArray *generalDatas;

@end

@implementation MapDataDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"区域：%@",self.collect_area_bs];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _dataArr = [NSMutableArray array];
    
    [self _requestMeterData:self.collect_area_bs];
}

- (NSArray *)generalDatas {
    if (_generalDatas) {
        return _generalDatas;
    }
    
    NSMutableArray *rows = [NSMutableArray array];
    for (NSInteger rowIndex = 0; rowIndex < self.dataArr.count; rowIndex++) {
        NSMutableArray *grids = [NSMutableArray array];
        NSInteger colIndex = 0;
        while (colIndex < 7) {
            LMRGrid *grid = [[LMRGrid alloc] init];
            
            if (rowIndex == 0) {
                switch (colIndex) {
                    case 0:
                        grid.text = @"抄收区域";
                        break;
                    case 1:
                        grid.text = @"抄收情况";
                        break;
                    case 2:
                        grid.text = @"抄收读数";
                        break;
                    case 3:
                        grid.text = @"抄收时间";
                        break;
                    case 4:
                        grid.text = @"水表表号";
                        break;
                    case 5:
                        grid.text = @"现场图片1";
                        break;
                    case 6:
                        grid.text = @"现场图片2";
                        break;
                    default:
                        break;
                }
            }
            else {
                switch (colIndex) {
                    case 0:

                        grid.text = [NSString stringWithFormat:@"%@",((MapDataModel *)_dataArr[rowIndex]).install_addr];
                        break;
                    case 1:
                        
                        grid.textColor      = [UIColor blueColor];
                        grid.font           = [UIFont boldSystemFontOfSize:15.f];
                        grid.textAlignment  = NSTextAlignmentCenter;

                        if ([((MapDataModel *)_dataArr[rowIndex]).bs isEqualToString:@"0"]) {
                            
                            grid.textColor = [UIColor redColor];
                            grid.text = @"未抄";
                        }else {
                            
                            grid.text = @"已抄收";
                        }
                        break;
                    case 2:

                        grid.text = [NSString stringWithFormat:@"%@ m³",((MapDataModel *)_dataArr[rowIndex]).collect_num];
                        break;
                    case 3:

                        grid.text = [NSString stringWithFormat:@"%@",((MapDataModel *)_dataArr[rowIndex]).collect_dt];
                        break;
                    case 4:

                        grid.text = [NSString stringWithFormat:@"%@",((MapDataModel *)_dataArr[rowIndex]).meter_id];
                        break;
                    case 5:

                        [self setGridImage:rowIndex :grid];
                        //grid.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,((MapDataModel *)_dataArr[rowIndex]).collect_img_name1]]]];
                        break;
                    case 6:
                        
                        [self setGridImage:rowIndex :grid];
                        //grid.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,((MapDataModel *)_dataArr[rowIndex]).collect_img_name2]]]];
                        break;
                    default:
                        break;
                }
            }
            [grids addObject:grid];
            colIndex++;
        }
        [rows addObject:grids];
    }
    _generalDatas = rows;
    return _generalDatas;
}

- (void)setGridImage :(NSInteger)rowIndex :(LMRGrid *)grid{
    NSURL *urlstr   = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Meter_Reading/%@",litMeterApi,((MapDataModel *)_dataArr[rowIndex]).collect_img_name2]];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:urlstr options:SDWebImageRetryFailed  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        [SVProgressHUD showProgress:receivedSize/expectedSize];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        grid.image = image;
    }];
}

#pragma mark - <LMReportViewDatasource>

- (NSInteger)numberOfRowsInReportView:(LMReportView *)reportView {
    
    return self.generalDatas.count;
}

- (NSInteger)numberOfColsInReportView:(LMReportView *)reportView {
    
    return [self.generalDatas.lastObject count];
}

- (CGFloat)reportView:(LMReportView *)reportView heightOfRow:(NSInteger)row {
    if (row == 0) {
        return 30;
    }
    else {
        return 60;
    }
}
- (CGFloat)reportView:(LMReportView *)reportView widthOfCol:(NSInteger)col {
   
    return 80;
}

- (LMRGrid *)reportView:(LMReportView *)reportView gridAtIndexPath:(NSIndexPath *)indexPath {
    
    LMRGrid *grid = self.generalDatas[indexPath.row][indexPath.col];
    return grid;
}


//请求水表抄收数据
- (void)_requestMeterData :(NSString *)area{
    
    [LSStatusBarHUD showLoading:@"加载中"];
    
    NSString *mapMeterDataUrl                 = [NSString stringWithFormat:@"%@/Meter_Reading/IosAreaCompleteServlet",litMeterApi];
    
    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSDictionary *para                        = @{
                                                  @"area_id":area
                                                  };
    
    __weak typeof(self) weakSelf              = self;
    
    NSURLSessionTask *meterTask               = [manager GET:mapMeterDataUrl parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [LSStatusBarHUD hideLoading];
        
        if (responseObject) {
            
            NSError *error;
            
            [weakSelf.dataArr addObject:@"title"];
            for (NSDictionary *responseDic in responseObject) {
                
                _mapDataModel = [[MapDataModel alloc] initWithDictionary:responseDic error:&error];
                
                [weakSelf.dataArr addObject:_mapDataModel];
                
            }
            
            if (weakSelf.dataArr.count>0) {
                
                weakSelf.reportView             = [[LMReportView alloc] init];
                weakSelf.reportView.datasource  = weakSelf;
                [weakSelf.view addSubview:weakSelf.reportView];
                
                CGRect rect         = weakSelf.view.bounds;
                rect                = CGRectInset(rect, 16, 16);
                rect.origin.y       += 60;
                rect.size.height    -= 64;
                weakSelf.reportView.frame       = rect;
                weakSelf.reportView.transform   = CGAffineTransformMakeScale(.01, .01);
                [UIView animateWithDuration:.5 animations:^{
                    weakSelf.reportView.transform = CGAffineTransformIdentity;
                }];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [LSStatusBarHUD hideLoading];
        [LSStatusBarHUD showMessage:@"加载失败！"];
        
        if (error.code == -1004) {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"服务器连接失败"] duration:1.5 autoHide:YES];
        }else {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"数据加载失败！\n%@",[error description]] duration:1.5 autoHide:YES];
            
        }
        
    }];
    
    [meterTask resume];
}

- (void)reportView:(LMReportView *)reportView didTapLabel:(LMRLabel *)label {
    
    if (label.indexPath.row == 0) {
        // 点击表头进行排序
        LMROrder order;
        if (reportView.sortedCol == label.indexPath.col && reportView.sortedOrder == LMROrderedDescending) {
            order = LMROrderedAscending;
        }
        else {
            order = LMROrderedDescending;
        }
        [reportView sortByCol:label.indexPath.col order:order];
    }
    else {
//        [self alertMessage:[NSString stringWithFormat:@"点击 %ld-%ld", label.indexPath.row, label.indexPath.col]];
    }
}

- (NSOrderedSet *)ascOrderedSetForSortedCol:(NSInteger)col {
    /*
     获取行索引的排序：先获取值的排序，然后一一对应到行索引的排序
     */
    NSMutableArray *sourceValues = [self.generalDatas mutableCopy];
    // 去掉第一行表头
    [sourceValues removeObjectAtIndex:0];
    //将列值数组从小到大排序
    NSArray *sortedValues = [sourceValues sortedArrayUsingComparator:^NSComparisonResult(NSArray *rows1, NSArray *rows2) {
        
        LMRGrid *grid1 = rows1[col];
        LMRGrid *grid2 = rows2[col];
        
        NSString *str1 = grid1.text;
        NSString *str2 = grid2.text;
        
        NSScanner *scanner = [NSScanner scannerWithString:str1];
        float floatValue;
        [scanner scanFloat:&floatValue];
        
        if ([scanner isAtEnd]) {
            //数字
            return str2.floatValue > str1.floatValue ? NSOrderedAscending : NSOrderedDescending;
        }
        else {
            //非数字
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            NSInteger length = str1.length < str2.length ? str1.length : str2.length;
            NSInteger loc = 0;
            while (loc < length) {
                
                NSString *word1 = [str1 substringWithRange:NSMakeRange(loc, 1)];
                NSString *word2 = [str2 substringWithRange:NSMakeRange(loc, 1)];
                
                NSInteger section1 = [collation sectionForObject:word1 collationStringSelector:@selector(description)];
                NSInteger section2 = [collation sectionForObject:word2 collationStringSelector:@selector(description)];
                
                return section2 > section1 ? NSOrderedDescending : NSOrderedAscending;
            }
            return NSOrderedAscending;
        }
    }];
    //获取行索引的排序
    NSMutableOrderedSet *sortedIndexes = [NSMutableOrderedSet orderedSet];
    for (id value in sortedValues) {
        NSInteger index = [sourceValues indexOfObject:value];
        //相同的字符串指向同一个(@"0" == @"0")，所以要把索引过的移除掉，避免同一个索引被多次加入到索引数组中
        sourceValues[index] = [NSNull null];
        [sortedIndexes addObject:[NSNumber numberWithInteger:index + 1]];
    }
    return sortedIndexes;
}

- (NSOrderedSet *)reportView:(LMReportView *)reportView indexesSortedByCol:(NSInteger)col order:(LMROrder)order {
    if (order == LMROrderedAscending) {
        return [self ascOrderedSetForSortedCol:col];
    }
    else if (order == LMROrderedDescending) {
        return [[self ascOrderedSetForSortedCol:col] reversedOrderedSet];
    }
    else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
