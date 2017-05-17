//
//  SecondViewController.h
//  first
//
//  Created by HS on 16/7/12.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageViewForSecond;

//- (IBAction)tapAction:(id)sender;
//- (IBAction)PanPopAction:(id)sender;
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender;

@end
