//
//  HomeViewController.h
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WeatherModel.h"

@interface HomeViewController : UIViewController

@property (nonatomic, strong) NSString *yestoday;
@property (nonatomic, strong) NSString *tomorrow;

@property (weak, nonatomic) IBOutlet UIImageView *weatherPicImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightC;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthC;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic)  UIImageView *day1Image;
@property (strong, nonatomic)  UIImageView *day2Image;
@property (strong, nonatomic)  UIImageView *day3Image;
@property (strong, nonatomic)  UIImageView *day4Image;
@property (strong, nonatomic)  UIImageView *day5Image;
@property (strong, nonatomic)  UIImageView *day6Image;
@property (strong, nonatomic)  UIImageView *day7Image;

@property (strong, nonatomic)  UILabel *day1Label;
@property (strong, nonatomic)  UILabel *day2Label;
@property (strong, nonatomic)  UILabel *day3Label;
@property (strong, nonatomic)  UILabel *day4Label;
@property (strong, nonatomic)  UILabel *day5Label;
@property (strong, nonatomic)  UILabel *day6Label;
@property (strong, nonatomic)  UILabel *day7Label;

@property (strong, nonatomic)  UILabel *time1Label;
@property (strong, nonatomic)  UILabel *time2Label;
@property (strong, nonatomic)  UILabel *time3Label;
@property (strong, nonatomic)  UILabel *time4Label;
@property (strong, nonatomic)  UILabel *time5Label;
@property (strong, nonatomic)  UILabel *time6Label;
@property (strong, nonatomic)  UILabel *time7Label;



@property (weak, nonatomic) IBOutlet UIVisualEffectView *weatherDetailEffectView;

@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *weather;

@property (weak, nonatomic) IBOutlet UILabel *temLabel;
@property (weak, nonatomic) IBOutlet UILabel *windDriection;
@property (weak, nonatomic) IBOutlet UILabel *windForceScale;
@property (weak, nonatomic) IBOutlet UILabel *time;

- (IBAction)position:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *positionBtn;

@property (nonatomic, strong) NSMutableArray *dataArray;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *weather_bg;




@property (nonatomic, strong) NSString *locaCity;

- (IBAction)refresh:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

@end
