//
//  CurrentReceiveTableViewCell.m
//  first
//
//  Created by HS on 16/6/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CurrentReceiveTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "FirstCollectionViewController.h"
#import "CurrentReceiveViewController.h"

@implementation CurrentReceiveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _userName.text                  = self.CRModel.meter_name;
    _x                              = self.CRModel.x;
    _y                              = self.CRModel.y;
    _userImage.image                = [self isnormal:self.CRModel.alarm];
    _userImage.clipsToBounds        = YES;
    _userImage.layer.cornerRadius   = 25;
}

//是否显示警报图片
- (UIImage *)isnormal:(NSString *)messageFlag {
    if ([messageFlag isEqualToString:@"无"]) {
        return [UIImage imageNamed:@"AppIcon60x60@3x"];
    }else if ([messageFlag isEqualToString:@"有"]) {
        return [UIImage imageNamed:@"icon_danger"];
    }
    return [UIImage imageNamed:@"AppIcon60x60@3x"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)naviButton:(id)sender {

    NSLog(@"%@-----%@",_x,_y);
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"导航提示" message:[NSString stringWithFormat:@"导航前往 ‘%@’ ？",_userName.text] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *conf = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //检测定位功能是否开启
        if([CLLocationManager locationServicesEnabled]){
            CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([_y integerValue], [_x integerValue]);
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                           MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
        }else{
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [[self findVC] presentViewController:alertVC animated:YES completion:^{
                
            }];
        }

    }];
    [alertVC addAction:cancel];
    [alertVC addAction:conf];
    [[self findVC] presentViewController:alertVC animated:YES completion:^{
        
    }];
    
}

- (UIViewController *)findVC
{
    UIResponder *next = self.nextResponder;
    
    while (1) {
        
        if ([next isKindOfClass:[UIViewController class]]) {
           return  (UIViewController *)next;
        }
          next =  next.nextResponder;
    }
    return nil;
}
- (IBAction)scenePhotos:(id)sender {
    FirstCollectionViewController *showImageVC = [[FirstCollectionViewController alloc] init];
    [[self findVC].navigationController showViewController:showImageVC sender:nil];
}





@end
