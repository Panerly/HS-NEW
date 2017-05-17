//
//  NewHomeViewController.h
//  first
//
//  Created by HS on 15/03/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewHomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *tmpLabel;     //气温
@property (weak, nonatomic) IBOutlet UILabel *maxTmpLabel;  //最高气温
@property (weak, nonatomic) IBOutlet UILabel *minTmpLabel;  //最低气温
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;    //城市
@property (weak, nonatomic) IBOutlet UIImageView *weatherTodayImageView;//今日天气状况图
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;  //更新时间
@property (weak, nonatomic) IBOutlet UILabel *windDirLabel; //风向
@property (weak, nonatomic) IBOutlet UILabel *hunLabel;     //湿度
@property (weak, nonatomic) IBOutlet UILabel *popLabel;     //降水概率

//一周天气时间
@property (weak, nonatomic) IBOutlet UILabel *day1Label;
@property (weak, nonatomic) IBOutlet UILabel *day2Label;
@property (weak, nonatomic) IBOutlet UILabel *day3Label;
@property (weak, nonatomic) IBOutlet UILabel *day4Label;
@property (weak, nonatomic) IBOutlet UILabel *day5Label;
@property (weak, nonatomic) IBOutlet UILabel *day6Label;
@property (weak, nonatomic) IBOutlet UILabel *day7Label;

//一周天气状况图
@property (weak, nonatomic) IBOutlet UIImageView *day1WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day3WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day4WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day2WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day5WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day6WeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *day7WeatherImageView;

//一周天气气温
@property (weak, nonatomic) IBOutlet UILabel *day1TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day2TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day3TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day4TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day5TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day6TmpLabel;
@property (weak, nonatomic) IBOutlet UILabel *day7TmpLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectCityBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTodayImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTodayImageViewHeight;




@end
