//
//  ViewController.h
//  NHNetworkTimeExample
//
//  Created by Nguyen Cong Huy on 9/20/15.
//  Copyright © 2015 Nguyen Cong Huy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "SettingViewController.h"
@interface FirstViewController : UIViewController<HomeViewControllerDelegate, SettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)openCamera:(id)sender;
- (IBAction)deleteFiles:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (weak, nonatomic) IBOutlet UIButton *shareCSVButton;
- (IBAction)Share_CSV:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *ShareVideoButton;
- (IBAction)Share_Video:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
//@property (weak, nonatomic) IBOutlet UIButton *settingBtn;



- (IBAction)playVideo:(id)sender;
@end

