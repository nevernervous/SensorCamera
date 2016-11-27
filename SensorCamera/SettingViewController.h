//
//  SettingViewController.h
//  SensorCamera
//
//  Created by borysM on 11/15/16.
//  Copyright © 2016 justin. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class SettingViewController;
@protocol SettingViewControllerDelegate <NSObject>
- (void)returnSensorSliderValue:(float)item;
- (void)returnFrameSliderValue:(int)item;

@end

@interface SettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

- (IBAction)GoBack:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sensorSlider;
@property (weak, nonatomic) IBOutlet UISlider *frameSlider;
@property (weak, nonatomic) IBOutlet UILabel *sensorIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *framesLabel;
@property (nonatomic, retain) id<SettingViewControllerDelegate> delegate;
@end
