//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
@class HomeViewController;
@protocol HomeViewControllerDelegate <NSObject>
- (void)addItemViewController:(HomeViewController *)controller didFinishEnteringItem:(NSArray *)item;
@end
@interface HomeViewController : UIViewController<CLLocationManagerDelegate,MFMailComposeViewControllerDelegate>
{
    
    CMMotionManager *motionManager;
    CMMotionActivityManager *motionActivityManager;
    CLLocationManager *locationManager;
    CMPedometer *pedometer;
}
@property (nonatomic, weak) id <HomeViewControllerDelegate> delegate;
@property (nonatomic)  NSString *strNetDate;
@property (nonatomic) float sensorInterval;
@property (nonatomic) int fps;// framesPerSecond
@end
