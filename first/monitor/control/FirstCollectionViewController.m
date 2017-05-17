//
//  ImageBrowserCollectionViewController.m
//  first
//
//  Created by HS on 16/7/12.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "FirstCollectionViewController.h"
#import "CollectionViewCell.h"
#import "SecondViewController.h"
#import "MagicMoveTransition.h"
#import "AMWaveTransition.h"

@interface FirstCollectionViewController ()<UINavigationControllerDelegate>

@property (strong, nonatomic) AMWaveTransition *interactive;

@end

@implementation FirstCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";


- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"ImageBrowser" bundle:nil] instantiateViewControllerWithIdentifier:@"firstCollectionID"];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    [MLTransition invalidate];
    [self.navigationController setDelegate:self];
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.interactive detachInteractiveGesture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _interactive = [[AMWaveTransition alloc] init];
    [SCToastView showInView:self.view text:@"测试数据" duration:1 autoHide:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    
    if (operation != UINavigationControllerOperationNone) {
        return [AMWaveTransition transitionWithOperation:operation];
    }
    if ([toVC isKindOfClass:[SecondViewController class]]) {
        MagicMoveTransition *transition = [[MagicMoveTransition alloc]init];
        return transition;
    }else{
        return nil;
    }
}

#pragma mark <UICollectionViewDataSource>
//section的数目
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section Item的数目
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

//创建cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    collectionView.backgroundColor = [UIColor whiteColor];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(PanScreenWidth/3.5, PanScreenHeight/4);
//}
//横向间距
//- (CGFloat) collectionView:(UICollectionView *)collectionView
//                    layout:(UICollectionViewLayout *)collectionViewLayout
//minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 2.0f;
//}
////设置纵向的行间距
//- (CGFloat) collectionView:(UICollectionView *)collectionView
//                    layout:(UICollectionViewLayout *)collectionViewLayout
//minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 2.0f;
//}
////通过调整inset使单元格顶部和底部都有间距(inset次序: 上，左，下，右边)
//- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView
//                         layout:(UICollectionViewLayout *)collectionViewLayout
//         insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 0.0f);
//}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:YES];
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}
@end
