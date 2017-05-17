//
//  ListSelectView.m
//  cjh
//
//  Created by wbb on 16/10/31.
//  Copyright © 2016年 njcjh. All rights reserved.
//

#import "ListSelectView.h"
@interface ListSelectView()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat kSingleTitleHeight;
    CGFloat kSingleBtnHeight;
}
@property (strong, nonatomic) UIView *selectView;
@property (assign, nonatomic) CGFloat collectionViewHeight;
@property (strong, nonatomic) NSArray *titleArray;
@property (assign, nonatomic) BOOL isAnimated;
@property (nonatomic,copy)NSString *title_str;
@property (copy,   nonatomic) dismissViewWithButton completionBlock;
@property (copy,   nonatomic) SureButtonBlock sureButtonBlock;
@end
@implementation ListSelectView

- (instancetype _Nonnull)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return self;
}
- (void)addTitleArray:(NSArray<NSString *> * __nullable)titleArray andTitleString:(NSString *__nullable)titleStr animated:(BOOL)animated completionHandler:(dismissViewWithButton __nullable)completionHandler withSureButtonBlock:(SureButtonBlock __nullable)sureButtonBlock {
    
    self.titleArray = titleArray;
    self.isAnimated = animated;
    self.completionBlock = completionHandler;
    self.sureButtonBlock = sureButtonBlock;
    self.title_str = titleStr;
    [self setupHeight];
    if (!_isShowTitle) {
        kSingleTitleHeight = 0.f;
    }else{
        kSingleTitleHeight = 50.f;
    }
    if (_isShowSureBtn||_isShowCancelBtn) {
        kSingleBtnHeight = 50;
    }else {
        kSingleBtnHeight = 0;
    }
    [self initSelectView];
    
    
    if (self.isAnimated) {
//        [self addPopAnimation];
        [self animationWithView:self.selectView duration:.5];
    }
    
}
// 根据文字大小和控件宽度计算控件高度
- (CGFloat)heightForText:(NSString *)text textFont:(CGFloat)fontSize standardWidth:(CGFloat)controlWidth
{
    if ([text length]==0) {
        return 0;
    }else {
        NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
        return [text boundingRectWithSize:CGSizeMake(controlWidth, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil].size.height;
    }
}
#pragma mark - setup methods

- (void)setupHeight {
    
    if(_choose_type == MORECHOOSETITLETYPE){
        self.collectionViewHeight = self.titleArray.count * kSingleSelectCellHeight;
    }else if (_choose_type == ONLYTEXTTYPE) {
        self.collectionViewHeight = [self heightForText:self.content_text textFont:kSingleContentTextFount standardWidth:PanScreenWidth-80]+10;
    }
    
    if (self.collectionViewHeight + 200 > PanScreenHeight) {
        self.collectionViewHeight = PanScreenHeight-300;
    }
}

- (void)initSelectView {
    
    self.selectView = [[UIView alloc]initWithFrame:CGRectMake(30, (PanScreenHeight-(self.collectionViewHeight+101))/2-80, PanScreenWidth-60, self.collectionViewHeight+kSingleTitleHeight+kSingleBtnHeight+1)];
    self.selectView.backgroundColor = [UIColor whiteColor];
    self.selectView.layer.cornerRadius = 10;
    self.selectView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.selectView.layer.shadowOffset = CGSizeMake(10, 10);
    self.selectView.layer.shadowOpacity = 0.5;
    self.selectView.layer.shadowRadius = 5;
    [self addSubview:self.selectView];
    /**
     标题Label
     */
    UILabel *tilteLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.selectView.frame.size.width, kSingleTitleHeight)];
    tilteLabel.hidden = _isShowTitle?NO:YES;;
    tilteLabel.text = _title_str;//@"请选择适合的选项";
    tilteLabel.font = [UIFont systemFontOfSize:18.f];
    tilteLabel.textAlignment = NSTextAlignmentCenter;
    [self.selectView addSubview:tilteLabel];
    /**
     横线
     */
    UILabel *horizontal1 = [[UILabel alloc]initWithFrame:CGRectMake(0 , tilteLabel.frame.size.height-1, self.selectView.frame.size.width, 0.5)];
    horizontal1.hidden = _isShowTitle?NO:YES;
    horizontal1.backgroundColor = [UIColor grayColor];
    [tilteLabel addSubview:horizontal1];
    
    if(_choose_type == MORECHOOSETITLETYPE) {
        /**
         *  注册tableview
         */
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.selectView.frame.size.width, self.collectionViewHeight) style:UITableViewStylePlain];
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.selectView addSubview:tableView];
    }else {
        /**
         注册contentLabel
         */
        UILabel *lab_content = [[UILabel alloc] initWithFrame:CGRectMake(10, kSingleTitleHeight, self.selectView.frame.size.width-20, self.collectionViewHeight)];
        lab_content.numberOfLines = 0;
        lab_content.font = [UIFont systemFontOfSize:kSingleContentTextFount];
        lab_content.text = self.content_text;
        [self.selectView addSubview:lab_content];
    }
    
    /**
     取消Button
     */
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.selectView.frame.size.height-50,_isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2-1: self.selectView.frame.size.width, kSingleBtnHeight)];
    [cancelButton setTitle:@"取 消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    cancelButton.hidden = _isShowCancelBtn?NO:YES;
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchDown];
    [self.selectView addSubview:cancelButton];
    /**
     确定Button
     */
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(_isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2+1:0, self.selectView.frame.size.height-50, _isShowSureBtn&&_isShowCancelBtn?self.selectView.frame.size.width/2-1: self.selectView.frame.size.width, kSingleBtnHeight)];
    okButton.hidden = _isShowSureBtn?NO:YES;
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction) forControlEvents:UIControlEventTouchDown];
    [self.selectView addSubview:okButton];
    /**
     竖线
     */
    UILabel *verticalline = [[UILabel alloc]initWithFrame:CGRectMake(cancelButton.frame.size.width, cancelButton.frame.origin.y, 0.5, cancelButton.frame.size.height)];
    verticalline.backgroundColor = [UIColor grayColor];
    verticalline.hidden = _isShowCancelBtn&&_isShowSureBtn?NO:YES;
    [self.selectView addSubview:verticalline];
    /**
     横线
     */
    UILabel *horizontal2 = [[UILabel alloc]initWithFrame:CGRectMake(0 , cancelButton.frame.origin.y-1, self.selectView.frame.size.width, 0.5)];
    horizontal2.hidden = _isShowCancelBtn||_isShowSureBtn?NO:YES;
    horizontal2.backgroundColor = [UIColor grayColor];
    [self.selectView addSubview:horizontal2];

}
#pragma mark listViewdataSource method and delegate method
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellid=@"listviewid";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellid];
        
//        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KSCREEN_WIDTH-20, cell.contentView.frame.size.height)];
////        lab.center = cell.center;
//        lab.text = self.titleArray[indexPath.row];
//        lab.textAlignment = NSTextAlignmentLeft;
//        lab.font = [UIFont systemFontOfSize:18.f];
//        [cell.contentView addSubview:lab];
        cell.textLabel.text = self.titleArray[indexPath.row];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kSingleSelectCellHeight;
}
//当选择下拉列表中的一行时，设置文本框中的值，隐藏下拉列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (UILabel *lab in cell.contentView.subviews) {
        if (self.completionBlock) {
            self.completionBlock(lab.text,indexPath.row);
        }
    }
    [self removeFromSuperview];
}

#pragma make - Action

- (void)cancelButtonAction {
    [self removeFromSuperview];
    
}
- (void)okButtonAction {
    self.sureButtonBlock();
    [self removeFromSuperview];
}
#pragma make - Animation

- (void)addPopAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithDouble:0.f];
    animation.toValue   = [NSNumber numberWithDouble:1.f];
    animation.duration  = .25f;
    animation.fillMode  = kCAFillModeBackwards;
    [self.layer addAnimation:animation forKey:nil];
}
- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];

    [view.layer addAnimation:animation forKey:nil];
}
@end
