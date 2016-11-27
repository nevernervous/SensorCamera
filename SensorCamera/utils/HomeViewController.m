//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "NHNetworkTime.h"
#import "HomeViewController.h"
#import "FirstViewController.h"
#import "ViewUtils.h"
#import "VideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HomeViewController (){
    NSURL *outputURL;
   
    NSTimer* myTimer;
    NSFileHandle* fh;
    NSDate *cDate1;
    NSDate *cDate2;
    NSDate *recStartDate;
    NSDate *recStopDate;
    
    int framecounter;
    double myTimer_interval;
    NSTimeInterval sec_count;
    
    double Roll;
    double Pitch;
    double Yaw;
  
    double Rotate_x;
    double Rotate_y;
    double Rotate_z;
    
    double Gyro_x;
    double Gyro_y;
    double Gyro_z;
    
    double Acc_x;
    double Acc_y;
    double Acc_z;
   
    double Grav_x;
    double Grav_y;
    double Grav_z;
    
    double Quater_w;
    double Quater_x;
    double Quater_y;
    double Quater_z;
    double devicemotionData_timestamp;
    double  heading_x;
    double  heading_y;
    double  heading_z;
    double lon;
    double lat;
    float left1;
    
    
    NSString *activityType_v;
    NSDate *activityStartDate_v;
    NSString *activityEndDate_v;
    NSString *confidence_v;
    NSString *duration_v;
    NSNumber *numberOfSteps_v;
    NSNumber *distance_meters_v;
    NSNumber *pacePerMeter_v;
    NSNumber *cadence_v;
    NSNumber *floors_ascended_v;
    NSNumber *floors_descended_v;
   
    
    FirstViewController *previousViewController;
}
 -(void)setScreenLandscape;
-(void)setScreenPortrait;
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UILabel *networkTimeLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UISegmentedControl *segmentedSensorSelectControl;

@property (nonatomic) NSTimer *oneSecondTimer;
@property (nonatomic)  NSString *csvFilePath ;

@property (strong, nonatomic) UILabel *quaterWLabel;
@property (strong, nonatomic) UILabel *quaterXLabel;
@property (strong, nonatomic) UILabel *quaterYLabel;
@property (strong, nonatomic) UILabel *quaterZLabel;

@property (strong, nonatomic) UILabel *accXLabel;
@property (strong, nonatomic) UILabel *accYLabel;
@property (strong, nonatomic) UILabel *accZLabel;

@property (strong, nonatomic) UILabel *rotateXLabel;
@property (strong, nonatomic) UILabel *rotateYLabel;
@property (strong, nonatomic) UILabel *rotateZLabel;


@property (strong, nonatomic) UILabel *rollLabel;
@property (strong, nonatomic) UILabel *pitchLabel;
@property (strong, nonatomic) UILabel *yawLabel;

@property (strong, nonatomic) UILabel *headingXLabel;
@property (strong, nonatomic) UILabel *headingYLabel;
@property (strong, nonatomic) UILabel *headingZLabel;

@property (strong, nonatomic) UILabel *longLabel;
@property (strong, nonatomic) UILabel *latLabel;

@property (strong, nonatomic) UILabel *activityType;
@property (strong, nonatomic) UILabel *activityStartDate;
//@property (strong, nonatomic) UILabel *activityEndDate;
@property (strong, nonatomic) UILabel *confidence;

//@property (strong, nonatomic) UILabel *duration;
@property (strong, nonatomic) UILabel *numberOfSteps;
@property (strong, nonatomic) UILabel *distance_meters;
@property (strong, nonatomic) UILabel *pacePerMeter;
@property (strong, nonatomic) UILabel *cadenceLabel;
@property (strong, nonatomic) UILabel *floors_ascended;
@property (strong, nonatomic) UILabel *floors_descended;



@end

@implementation HomeViewController

- (id)init {
    if(self = [super init]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            motionManager = [[CMMotionManager alloc] init];
//            motionActivityManager  = [[CMMotionActivityManager alloc] init];
//            locationManager = [[CLLocationManager alloc] init];
        });

    }
    return self;
}
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    locationManager.headingFilter = kCLHeadingFilterNone;

    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];

    
}
-(void)getQuickLocationUpdate {
    // Create a location manager object
    locationManager = [[CLLocationManager alloc] init];
    
    // Set the delegate
    locationManager.delegate = self;
    // Request location authorization
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.distanceFilter = kCLDistanceFilterNone; //default :kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 1;//default :1
        [locationManager startUpdatingHeading];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    motionManager = [[CMMotionManager alloc] init];
    motionActivityManager  = [[CMMotionActivityManager alloc] init];
//    if ([CLLocationManager locationServicesEnabled])
//    {
        [self getQuickLocationUpdate];
//    }
    

    // --------- sensor init ------ //
    myTimer_interval = 1.00/_fps;
    
   
    
    if ([CMPedometer isStepCountingAvailable]) {
        
        pedometer = [[CMPedometer alloc] init];
    }
    else {
        
        NSLog(@"Step counting is not available on this device!");
    }

    
    
    confidence_v = @"low";
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];

    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash.png"] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    }
    
    self.networkTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.networkTimeLabel.frame = CGRectMake(10.0f, screenRect.size.height - 50.0f, 170.0f, 32.0f);
    self.networkTimeLabel.numberOfLines = 1;
    self.networkTimeLabel.backgroundColor = [UIColor clearColor];
    self.networkTimeLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.networkTimeLabel.textColor = [UIColor whiteColor];
    self.networkTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.networkTimeLabel.text = _strNetDate;
    [self.view addSubview:self.networkTimeLabel];
    
    self.quaterWLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.quaterWLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 590.0f, 170.0f, 32.0f);
    self.quaterWLabel.numberOfLines = 1;
    self.quaterWLabel.backgroundColor = [UIColor clearColor];
    self.quaterWLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.quaterWLabel.textColor = [UIColor whiteColor];
    self.quaterWLabel.textAlignment = NSTextAlignmentCenter;
    self.quaterWLabel.text = @"Quater_W = ";
    [self.view addSubview:self.quaterWLabel];

    self.quaterXLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.quaterXLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 560.0f, 170.0f, 32.0f);
    self.quaterXLabel.numberOfLines = 1;
    self.quaterXLabel.backgroundColor = [UIColor clearColor];
    self.quaterXLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.quaterXLabel.textColor = [UIColor whiteColor];
    self.quaterXLabel.textAlignment = NSTextAlignmentCenter;
    self.quaterXLabel.text = @"Quater_X = ";
    [self.view addSubview:self.quaterXLabel];
    
    self.quaterYLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.quaterYLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 530.0f, 170.0f, 32.0f);
    self.quaterYLabel.numberOfLines = 1;
    self.quaterYLabel.backgroundColor = [UIColor clearColor];
    self.quaterYLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.quaterYLabel.textColor = [UIColor whiteColor];
    self.quaterYLabel.textAlignment = NSTextAlignmentCenter;
    self.quaterYLabel.text = @"Quater_Y = ";
    [self.view addSubview:self.quaterYLabel];
    
    self.quaterZLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.quaterZLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 500.0f, 170.0f, 32.0f);
    self.quaterZLabel.numberOfLines = 1;
    self.quaterZLabel.backgroundColor = [UIColor clearColor];
    self.quaterZLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.quaterZLabel.textColor = [UIColor whiteColor];
    self.quaterZLabel.textAlignment = NSTextAlignmentCenter;
    self.quaterZLabel.text = @"Quater_Z = ";
    [self.view addSubview:self.quaterZLabel];
    
    
    self.accXLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.accXLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 460.0f, 170.0f, 32.0f);
    self.accXLabel.numberOfLines = 1;
    self.accXLabel.backgroundColor = [UIColor clearColor];
    self.accXLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.accXLabel.textColor = [UIColor whiteColor];
    self.accXLabel.textAlignment = NSTextAlignmentCenter;
    self.accXLabel.text = @"Acc_X";
    [self.view addSubview:self.accXLabel];
    
    self.accYLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.accYLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 430.0f, 170.0f, 32.0f);
    self.accYLabel.numberOfLines = 1;
    self.accYLabel.backgroundColor = [UIColor clearColor];
    self.accYLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.accYLabel.textColor = [UIColor whiteColor];
    self.accYLabel.textAlignment = NSTextAlignmentCenter;
    self.accYLabel.text = @"Acc_Y";
    [self.view addSubview:self.accYLabel];
    
    self.accZLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.accZLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 400.0f, 170.0f, 32.0f);
    self.accZLabel.numberOfLines = 1;
    self.accZLabel.backgroundColor = [UIColor clearColor];
    self.accZLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.accZLabel.textColor = [UIColor whiteColor];
    self.accZLabel.textAlignment = NSTextAlignmentCenter;
    self.accZLabel.text = @"Acc_Z";
    [self.view addSubview:self.accZLabel];
    
    self.rotateXLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.rotateXLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 360.0f, 170.0f, 32.0f);
    self.rotateXLabel.numberOfLines = 1;
    self.rotateXLabel.backgroundColor = [UIColor clearColor];
    self.rotateXLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.rotateXLabel.textColor = [UIColor whiteColor];
    self.rotateXLabel.textAlignment = NSTextAlignmentCenter;
    self.rotateXLabel.text = @"Rotate_X";
    [self.view addSubview:self.rotateXLabel];
    
    self.rotateYLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.rotateYLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 330.0f, 170.0f, 32.0f);
    self.rotateYLabel.numberOfLines = 1;
    self.rotateYLabel.backgroundColor = [UIColor clearColor];
    self.rotateYLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.rotateYLabel.textColor = [UIColor whiteColor];
    self.rotateYLabel.textAlignment = NSTextAlignmentCenter;
    self.rotateYLabel.text = @"Rotate_Y";
    [self.view addSubview:self.rotateYLabel];
    
    self.rotateZLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.rotateZLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 300.0f, 170.0f, 32.0f);
    self.rotateZLabel.numberOfLines = 1;
    self.rotateZLabel.backgroundColor = [UIColor clearColor];
    self.rotateZLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.rotateZLabel.textColor = [UIColor whiteColor];
    self.rotateZLabel.textAlignment = NSTextAlignmentCenter;
    self.rotateZLabel.text = @"Rotate_Z";
    [self.view addSubview:self.rotateZLabel];
    
    self.rollLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.rollLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 260.0f, 170.0f, 32.0f);
    self.rollLabel.numberOfLines = 1;
    self.rollLabel.backgroundColor = [UIColor clearColor];
    self.rollLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.rollLabel.textColor = [UIColor whiteColor];
    self.rollLabel.textAlignment = NSTextAlignmentCenter;
    self.rollLabel.text = @"Roll";
    [self.view addSubview:self.rollLabel];
    
    self.pitchLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.pitchLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 230.0f, 170.0f, 32.0f);
    self.pitchLabel.numberOfLines = 1;
    self.pitchLabel.backgroundColor = [UIColor clearColor];
    self.pitchLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.pitchLabel.textColor = [UIColor whiteColor];
    self.pitchLabel.textAlignment = NSTextAlignmentCenter;
    self.pitchLabel.text = @"Pitch";
    [self.view addSubview:self.pitchLabel];
    
    self.yawLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.yawLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 200.0f, 170.0f, 32.0f);
    self.yawLabel.numberOfLines = 1;
    self.yawLabel.backgroundColor = [UIColor clearColor];
    self.yawLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.yawLabel.textColor = [UIColor whiteColor];
    self.yawLabel.textAlignment = NSTextAlignmentCenter;
    self.yawLabel.text = @"Yaw";
    [self.view addSubview:self.yawLabel];

    self.headingXLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.headingXLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 510.0f, 170.0f, 32.0f);
    self.headingXLabel.numberOfLines = 1;
    self.headingXLabel.backgroundColor = [UIColor clearColor];
    self.headingXLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.headingXLabel.textColor = [UIColor greenColor];
    self.headingXLabel.textAlignment = NSTextAlignmentCenter;
    self.headingXLabel.text = @"Heading_X";
    [self.view addSubview:self.headingXLabel];

    self.headingYLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.headingYLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 460.0f, 170.0f, 32.0f);
    self.headingYLabel.numberOfLines = 1;
    self.headingYLabel.backgroundColor = [UIColor clearColor];
    self.headingYLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.headingYLabel.textColor = [UIColor greenColor];
    self.headingYLabel.textAlignment = NSTextAlignmentCenter;
    self.headingYLabel.text = @"Heading_Y";
    [self.view addSubview:self.headingYLabel];

    self.headingZLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.headingZLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 410.0f, 170.0f, 32.0f);
    self.headingZLabel.numberOfLines = 1;
    self.headingZLabel.backgroundColor = [UIColor clearColor];
    self.headingZLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.headingZLabel.textColor = [UIColor greenColor];
    self.headingZLabel.textAlignment = NSTextAlignmentCenter;
    self.headingZLabel.text = @"Heading_Z";
    [self.view addSubview:self.headingZLabel];

    self.longLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.longLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 350.0f, 170.0f, 32.0f);
    self.longLabel.numberOfLines = 1;
    self.longLabel.backgroundColor = [UIColor clearColor];
    self.longLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.longLabel.textColor = [UIColor greenColor];
    self.longLabel.textAlignment = NSTextAlignmentCenter;
    self.longLabel.text = @"Loingitude";
    [self.view addSubview:self.longLabel];

    self.latLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.latLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 300.0f, 170.0f, 32.0f);
    self.latLabel.numberOfLines = 1;
    self.latLabel.backgroundColor = [UIColor clearColor];
    self.latLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.latLabel.textColor = [UIColor greenColor];
    self.latLabel.textAlignment = NSTextAlignmentCenter;
    self.latLabel.text = @"Latitude";
    [self.view addSubview:self.latLabel];
    

    
    
    self.activityType= [[UILabel alloc] initWithFrame:CGRectZero];
    self.activityType.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 580.0f, 170.0f, 32.0f);
    self.activityType.numberOfLines = 1;
    self.activityType.backgroundColor = [UIColor clearColor];
    self.activityType.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.activityType.textColor = [UIColor greenColor];
    self.activityType.textAlignment = NSTextAlignmentCenter;
    self.activityType.text = @"Type : ";
    [self.view addSubview:self.activityType];
    
    
    self.activityStartDate= [[UILabel alloc] initWithFrame:CGRectZero];
    self.activityStartDate.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 550.0f, 170.0f, 32.0f);
    self.activityStartDate.numberOfLines = 1;
    self.activityStartDate.backgroundColor = [UIColor clearColor];
    self.activityStartDate.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.activityStartDate.textColor = [UIColor greenColor];
    self.activityStartDate.textAlignment = NSTextAlignmentCenter;
    self.activityStartDate.text = @"ActivityStartDate : ";
    [self.view addSubview:self.activityStartDate];
    
    
//    self.activityEndDate= [[UILabel alloc] initWithFrame:CGRectZero];
//    self.activityEndDate.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 520.0f, 170.0f, 32.0f);
//    self.activityEndDate.numberOfLines = 1;
//    self.activityEndDate.backgroundColor = [UIColor clearColor];
//    self.activityEndDate.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
//    self.activityEndDate.textColor = [UIColor greenColor];
//    self.activityEndDate.textAlignment = NSTextAlignmentCenter;
//    self.activityEndDate.text = @"ActivityEndDate : ";
//    [self.view addSubview:self.activityEndDate];
    
    
    self.confidence= [[UILabel alloc] initWithFrame:CGRectZero];
    self.confidence.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 520.0f, 170.0f, 32.0f);
    self.confidence.numberOfLines = 1;
    self.confidence.backgroundColor = [UIColor clearColor];
    self.confidence.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.confidence.textColor = [UIColor greenColor];
    self.confidence.textAlignment = NSTextAlignmentCenter;
    self.confidence.text = @"Confidence : ";
    [self.view addSubview:self.confidence];
    
    
    self.numberOfSteps= [[UILabel alloc] initWithFrame:CGRectZero];
    self.numberOfSteps.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 440.0f, 170.0f, 32.0f);
    self.numberOfSteps.numberOfLines = 1;
    self.numberOfSteps.backgroundColor = [UIColor clearColor];
    self.numberOfSteps.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.numberOfSteps.textColor = [UIColor greenColor];
    self.numberOfSteps.textAlignment = NSTextAlignmentCenter;
    self.numberOfSteps.text = @"NumberOfSteps : ";
    [self.view addSubview:self.numberOfSteps];

    
    self.distance_meters= [[UILabel alloc] initWithFrame:CGRectZero];
    self.distance_meters.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 410.0f, 170.0f, 32.0f);
    self.distance_meters.numberOfLines = 1;
    self.distance_meters.backgroundColor = [UIColor clearColor];
    self.distance_meters.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.distance_meters.textColor = [UIColor greenColor];
    self.distance_meters.textAlignment = NSTextAlignmentCenter;
    self.distance_meters.text = @"Distance_meters : ";
    [self.view addSubview:self.distance_meters];
    
    
    self.pacePerMeter= [[UILabel alloc] initWithFrame:CGRectZero];
    self.pacePerMeter.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 380.0f, 170.0f, 32.0f);
    self.pacePerMeter.numberOfLines = 1;
    self.pacePerMeter.backgroundColor = [UIColor clearColor];
    self.pacePerMeter.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.pacePerMeter.textColor = [UIColor greenColor];
    self.pacePerMeter.textAlignment = NSTextAlignmentCenter;
    self.pacePerMeter.text = @"secondsPerMeter : ";
    [self.view addSubview:self.pacePerMeter];
    
    self.cadenceLabel= [[UILabel alloc] initWithFrame:CGRectZero];
    self.cadenceLabel.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 350.0f, 170.0f, 32.0f);
    self.cadenceLabel.numberOfLines = 1;
    self.cadenceLabel.backgroundColor = [UIColor clearColor];
    self.cadenceLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.cadenceLabel.textColor = [UIColor greenColor];
    self.cadenceLabel.textAlignment = NSTextAlignmentCenter;
    self.cadenceLabel.text = @"stepsPerSecond : ";
    [self.view addSubview:self.cadenceLabel];
  
    self.floors_ascended= [[UILabel alloc] initWithFrame:CGRectZero];
    self.floors_ascended.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 320.0f, 170.0f, 32.0f);
    self.floors_ascended.numberOfLines = 1;
    self.floors_ascended.backgroundColor = [UIColor clearColor];
    self.floors_ascended.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.floors_ascended.textColor = [UIColor greenColor];
    self.floors_ascended.textAlignment = NSTextAlignmentCenter;
    self.floors_ascended.text = @"floors_ascended : ";
    [self.view addSubview:self.floors_ascended];
    
    self.floors_descended= [[UILabel alloc] initWithFrame:CGRectZero];
    self.floors_descended.frame = CGRectMake(screenRect.size.width/2 - 80.0f, screenRect.size.height - 290.0f, 170.0f, 32.0f);
    self.floors_descended.numberOfLines = 1;
    self.floors_descended.backgroundColor = [UIColor clearColor];
    self.floors_descended.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    self.floors_descended.textColor = [UIColor greenColor];
    self.floors_descended.textAlignment = NSTextAlignmentCenter;
    self.floors_descended.text = @"floors_descended : ";
    [self.view addSubview:self.floors_descended];
    
 

    
    self.longLabel.hidden = true;
    self.latLabel.hidden = true;
    self.headingXLabel.hidden = true;
    self.headingYLabel.hidden = true;
    self.headingZLabel.hidden = true;
    
    self.activityType.hidden = true;
    self.activityStartDate.hidden = true;
//    self.activityEndDate.hidden = true;
    self.confidence.hidden = true;
    
    
    self.numberOfSteps.hidden = true;
    self.distance_meters.hidden = true;
    self.pacePerMeter.hidden = true;
    self.cadenceLabel.hidden = true;
    self.floors_ascended.hidden = true;
    self.floors_descended.hidden = true;
    
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Show",@"Hide"]];
    self.segmentedControl.frame = CGRectMake(12.0f, screenRect.size.height - 67.0f, 120.0f, 32.0f);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    

    self.segmentedSensorSelectControl = [[UISegmentedControl alloc] initWithItems:@[@"Motion", @"Location", @"Activity"]];
    self.segmentedSensorSelectControl.frame = CGRectMake(12.0f, screenRect.size.height - 160.0f, 250.0f, 32.0f );
    self.segmentedSensorSelectControl.selectedSegmentIndex=0;
    self.segmentedSensorSelectControl.tintColor = [UIColor redColor];
    [self.segmentedSensorSelectControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedSensorSelectControl];
    
    
 
//    [self.segmentedControl setSelectedSegmentIndex:1];
//    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
//    [self.backButton setTitle : @"Back"  forState:UIControlStateNormal];
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.backButton addTarget:self action:@selector(backPage:) forControlEvents:UIControlEventTouchUpInside];
    if(self.view.width> self.view.height)
    {
        [self setScreenLandscape];
    }
    else
    {
        [self setScreenPortrait];
    }
    [self.view addSubview:self.backButton];
    Gyro_x = 0;
    Gyro_y = 0;
    Gyro_z = 0;
    Rotate_x = 0;
    Rotate_y = 0;
    Rotate_z = 0;

    Roll = 0;
    Pitch =0;
    Yaw = 0;
    
    
    Acc_x =0;
    Acc_y=0;
    Acc_z=0;
    Grav_x = 0;
    Grav_y = 0;
    Grav_z = 0;
    
    
    Quater_w = 0;
    Quater_x = 0;
    Quater_y = 0;
    Quater_z = 0;
    devicemotionData_timestamp = 0;
    heading_x = 0;
    heading_y = 0;
    heading_z =0;
    lon = 0;
    lat = 0;
    [self sensorStartUpdate];
    [self createUpdateUITimer];
    
    
 }

-(void) backPage:(UIButton *)button{
   
   
   
    [self.navigationController popToRootViewControllerAnimated:YES];
    if(_csvFilePath ==nil) return;
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:_csvFilePath];
    NSArray *arr = [NSArray arrayWithObjects:fileURL, outputURL, nil];
    
    [self.delegate addItemViewController:self didFinishEnteringItem:arr];
}
- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    NSLog(@"Segment value changed!");
        if(self.segmentedControl.selectedSegmentIndex == 0) {

        _networkTimeLabel.hidden = false;
        self.segmentedSensorSelectControl.hidden = false;
        if(self.segmentedSensorSelectControl.selectedSegmentIndex == 0) {
            
            self.rotateXLabel.hidden =false;
            self.rotateYLabel.hidden =false;
            self.rotateZLabel.hidden =false;
            
            self.quaterWLabel.hidden =false;
            self.quaterXLabel.hidden =false;
            self.quaterYLabel.hidden =false;
            self.quaterZLabel.hidden =false;
            
            self.accXLabel.hidden =false;
            self.accYLabel.hidden =false;
            self.accZLabel.hidden =false;
            
            self.rollLabel.hidden =false;
            self.pitchLabel.hidden =false;
            self.yawLabel.hidden =false;
            
            self.headingXLabel.hidden =true;
            self.headingYLabel.hidden =true;
            self.headingZLabel.hidden =true;
            self.longLabel.hidden =true;
            self.latLabel.hidden =true;
            
            self.activityType.hidden = true;
            self.activityStartDate.hidden = true;
//            self.activityEndDate.hidden = true;
            self.confidence.hidden = true;
            
            
            self.numberOfSteps.hidden = true;
            self.distance_meters.hidden = true;
            self.pacePerMeter.hidden = true;
            self.cadenceLabel.hidden = true;
            self.floors_ascended.hidden = true;
            self.floors_descended.hidden = true;

        }
        if(self.segmentedSensorSelectControl.selectedSegmentIndex == 1)
        {
            self.rotateXLabel.hidden =true;
            self.rotateYLabel.hidden =true;
            self.rotateZLabel.hidden =true;
            
            self.quaterWLabel.hidden =true;
            self.quaterXLabel.hidden =true;
            self.quaterYLabel.hidden =true;
            self.quaterZLabel.hidden =true;
            
            self.accXLabel.hidden =true;
            self.accYLabel.hidden =true;
            self.accZLabel.hidden =true;
            
            self.rollLabel.hidden =true;
            self.pitchLabel.hidden =true;
            self.yawLabel.hidden =true;
            
            self.headingXLabel.hidden =false;
            self.headingYLabel.hidden =false;
            self.headingZLabel.hidden =false;
            
            self.longLabel.hidden =false;
            self.latLabel.hidden =false;
            self.activityType.hidden = true;
            self.activityStartDate.hidden = true;
//            self.activityEndDate.hidden = true;
            self.confidence.hidden = true;
            
            
            self.numberOfSteps.hidden = true;
            self.distance_meters.hidden = true;
            self.pacePerMeter.hidden = true;
            self.cadenceLabel.hidden = true;
            self.floors_ascended.hidden = true;
            self.floors_descended.hidden = true;

            
        }
        if(self.segmentedSensorSelectControl.selectedSegmentIndex == 2)
        {
            self.rotateXLabel.hidden =true;
            self.rotateYLabel.hidden =true;
            self.rotateZLabel.hidden =true;
            
            self.quaterWLabel.hidden =true;
            self.quaterXLabel.hidden =true;
            self.quaterYLabel.hidden =true;
            self.quaterZLabel.hidden =true;
            
            self.accXLabel.hidden =true;
            self.accYLabel.hidden =true;
            self.accZLabel.hidden =true;
            
            self.rollLabel.hidden =true;
            self.pitchLabel.hidden =true;
            self.yawLabel.hidden =true;
            
            self.headingXLabel.hidden =true;
            self.headingYLabel.hidden =true;
            self.headingZLabel.hidden =true;
            
            self.longLabel.hidden =true;
            self.latLabel.hidden =true;
            
            self.activityType.hidden = false;
            self.activityStartDate.hidden = false;
//            self.activityEndDate.hidden = false;
            self.confidence.hidden = false;
            
            
            self.numberOfSteps.hidden = false;
            self.distance_meters.hidden = false;
            self.pacePerMeter.hidden = false;
            self.cadenceLabel.hidden = false;
            self.floors_ascended.hidden = false;
            self.floors_descended.hidden = false;

            
        }

        
    }
    else{
        _networkTimeLabel.hidden = true;
        self.segmentedSensorSelectControl.hidden = true;
        
        self.rotateXLabel.hidden =true;
        self.rotateYLabel.hidden =true;
        self.rotateZLabel.hidden =true;
        
        self.quaterWLabel.hidden =true;
        self.quaterXLabel.hidden =true;
        self.quaterYLabel.hidden =true;
        self.quaterZLabel.hidden =true;
        
        self.accXLabel.hidden =true;
        self.accYLabel.hidden =true;
        self.accZLabel.hidden =true;
        
        self.rollLabel.hidden =true;
        self.pitchLabel.hidden =true;
        self.yawLabel.hidden =true;
        
        self.headingXLabel.hidden =true;
        self.headingYLabel.hidden =true;
        self.headingZLabel.hidden =true;
        
        self.longLabel.hidden =true;
        self.latLabel.hidden =true;
        self.activityType.hidden = true;
        self.activityStartDate.hidden = true;
//        self.activityEndDate.hidden = true;
        self.confidence.hidden = true;
        
        
        self.numberOfSteps.hidden = true;
        self.distance_meters.hidden = true;
        self.pacePerMeter.hidden = true;
        self.cadenceLabel.hidden = true;
        self.floors_ascended.hidden = true;
        self.floors_descended.hidden = true;

    }

}
/* Timer Active */
//////////////////


- (NSString *)dataFilePath:(NSString*) cfileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:cfileName];
}
- (void) dataWrite:(NSString *) str {
    if (fh) {
        [fh writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)updateLabels:(CMPedometerData *)pedometerData {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    if (pedometerData == nil) {
     
        numberOfSteps_v=0;
        distance_meters_v=0;
        pacePerMeter_v=0;
        cadence_v=0;
        floors_ascended_v=0;
        floors_descended_v=0;
//        self.numberOfSteps.text = @"";
//        self.distance_meters.text = @"";
//        self.pacePerMeter.text = @"";
//        self.cadenceLabel.text = @"";
//        self.floors_ascended.text = @"";
//        self.floors_descended.text = @"";
        return;
    }

    // step counting
    if ([CMPedometer isStepCountingAvailable]) {
        numberOfSteps_v = [pedometerData numberOfSteps];
        self.numberOfSteps.text = [NSString stringWithFormat:@"numberOfSteps: %@", [formatter stringFromNumber:pedometerData.numberOfSteps]];
    } else {
        numberOfSteps_v = 0;
        self.numberOfSteps.text = @"";
    }
    
    // distance
    if ([CMPedometer isDistanceAvailable]) {
                distance_meters_v = [pedometerData distance];
        self.distance_meters.text = [NSString stringWithFormat:@"distance_meters:%@", [formatter stringFromNumber:pedometerData.distance]];
    } else {
        distance_meters_v = 0;
        self.distance_meters.text = @"";
    }
    
    // pace
    if ([CMPedometer isPaceAvailable] && pedometerData.currentPace) {
        self.pacePerMeter.text = [NSString stringWithFormat:@"secondsPerMeter:%@", [formatter stringFromNumber:pedometerData.currentPace]];
        pacePerMeter_v = [pedometerData currentPace];
    } else {
        pacePerMeter_v =0;
        self.pacePerMeter.text = @"";
    }
    
    // cadence
    if ([CMPedometer isCadenceAvailable] && pedometerData.currentCadence) {
        cadence_v =[pedometerData currentCadence];
        self.cadenceLabel.text = [NSString stringWithFormat:@"stepsPerSecond:%@ ", [formatter stringFromNumber: pedometerData.currentCadence]];
    } else {
        cadence_v = 0;
        self.cadenceLabel.text = @"";
    }
    
    // flights climbed
    if ([CMPedometer isFloorCountingAvailable] && pedometerData.floorsAscended) {
        self.floors_ascended.text = [NSString stringWithFormat:@"Floors ascended: %@", pedometerData.floorsAscended];
        floors_ascended_v = [pedometerData floorsAscended];
    } else {
        floors_ascended_v=0;
        self.floors_ascended.text = @"";
    }
    
    if ([CMPedometer isFloorCountingAvailable] && pedometerData.floorsDescended) {
        self.floors_descended.text =[NSString stringWithFormat:@"Floors descended: %@", pedometerData.floorsDescended];
        floors_descended_v = [pedometerData floorsAscended];
    } else {
        floors_descended_v = 0;
        self.floors_descended.text = @"";
    }
}
- (void) sensorStartUpdate{
//    [pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError * _Nullable error) {
//        
//        // this block is called for each live update
//        [self updateLabels:pedometerData];
//        
//    }];
    
    BOOL b=  [CMMotionActivityManager isActivityAvailable];
    if(b)
    {
        [motionActivityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init]
                                               withHandler:
         ^(CMMotionActivity *activity) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                                  if([activity startDate])
                     activityStartDate_v = [activity startDate];
                 else
                     activityStartDate_v = [NSDate date];
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                 NSString *formattedDateString = [dateFormatter stringFromDate:activityStartDate_v];
                 NSLog(@"Current activity date is %f, %@",activity.timestamp, formattedDateString);

                 self.activityStartDate.text = formattedDateString;
                
                 if (activity.confidence == CMMotionActivityConfidenceMedium) confidence_v = @"medium";
                 if (activity.confidence == CMMotionActivityConfidenceHigh) confidence_v = @"high";
                 _confidence.text = [NSString stringWithFormat:@"Confidence: %@",confidence_v ];
                 

                 if ([activity stationary]) {
                     self.activityType.text = [NSString stringWithFormat:@"%@%@", @"Type: ", @"stationary" ];
                     activityType_v = @"stationary";
                     
                     NSLog(@"stationary");
                     [pedometer stopPedometerUpdates];
                 }
                 if ([activity walking]) {
                    self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"walking" ];
                     NSLog(@"walking");
                      activityType_v = @"walking";
                     [pedometer startPedometerUpdatesFromDate:activityStartDate_v withHandler:^(CMPedometerData *pedometerData, NSError * _Nullable error) {
                         
                         // this block is called for each live update
                         self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"walking" ];

                         [self updateLabels:pedometerData];
                         
                     }];
                 }
                 if ([activity running]) {
                     self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"running" ];
                     NSLog(@"running");
                      activityType_v = @"running";
                     [pedometer startPedometerUpdatesFromDate:activityStartDate_v withHandler:^(CMPedometerData * pedometerData, NSError * _Nullable error) {
                         
                         // this block is called for each live update
                         self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"running" ];

                         [self updateLabels:pedometerData];
                         
                     }];
                 }
                 if ([activity cycling]) {
                      self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"cycling" ];
                     NSLog(@"cycling");
                      activityType_v = @"cycling";
                     [pedometer stopPedometerUpdates];
                 }
                 if ([activity automotive]) {
                      self.activityType.text = [NSString stringWithFormat:@"%@%@",@"Type: ", @"automotive" ];
                     NSLog(@"automotive");
                      activityType_v = @"automotive";
                     [pedometer stopPedometerUpdates];
                 }
                 if ([activity unknown]) {
                      self.activityType.text = [NSString stringWithFormat:@"%@%@", @"Type: ",@"unknown" ];
                     NSLog(@"unknown");
                      activityType_v = @"unknown";
                     [pedometer stopPedometerUpdates];
                 }
             });
         }];

    }
    //    if (motionManager.isAccelerometerAvailable) {
//        motionManager.accelerometerUpdateInterval = 0.01;
//        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
//                                           withHandler: ^(CMAccelerometerData *accelerometerData, NSError *error)
//         {
//             Acc_x =accelerometerData.acceleration.x;
//             Acc_y =accelerometerData.acceleration.y;
//             Acc_z =accelerometerData.acceleration.z;
//         }];
//    }
    
    if (motionManager.gyroAvailable) {
        motionManager.gyroUpdateInterval = self.sensorInterval;
        [motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                   withHandler: ^(CMGyroData *gyroData, NSError *error)
         {
             
             CMRotationRate rotate = gyroData.rotationRate;
             Gyro_x = rotate.x;
             Gyro_y = rotate.y;
             Gyro_z = rotate.z;
             // GyroData_timestamp = gyroData.timestamp;
             
         }];
    }
    

    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = self.sensorInterval;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                           withHandler: ^(CMDeviceMotion *devicemotionData, NSError *error)
         {
             
             CMRotationRate rotate = devicemotionData.rotationRate;
             CMAcceleration grav = devicemotionData.gravity;
             CMAcceleration userAcc= devicemotionData.userAcceleration;
             CMQuaternion attitude = devicemotionData.attitude.quaternion;
             
             Roll = devicemotionData.attitude.roll;
             Pitch = devicemotionData.attitude.pitch;
             Yaw = devicemotionData.attitude.yaw;
             
             Rotate_x = rotate.x;
             Rotate_y = rotate.y;
             Rotate_z =  rotate.z;
             
             Acc_x =grav.x + userAcc.x;
             Acc_y =grav.y + userAcc.y;
             Acc_z =grav.z + userAcc.z;
             
             Grav_x = grav.x;
             Grav_y = grav.y;
             Grav_z = grav.z;
             
             Quater_w = attitude.w;
             Quater_x = attitude.x;
             Quater_y = attitude.y;
             Quater_z = attitude.z;
             devicemotionData_timestamp = devicemotionData.timestamp;
             
             self.rotateXLabel.text =[NSString stringWithFormat:@"%@%@", @"Rotate_X = ", [NSString stringWithFormat:@"%lf", Rotate_x]];;
             self.rotateYLabel.text =[NSString stringWithFormat:@"%@%@", @"Rotate_Y = ", [NSString stringWithFormat:@"%lf", Rotate_y]];;
             self.rotateZLabel.text =[NSString stringWithFormat:@"%@%@", @"Rotate_Z = ", [NSString stringWithFormat:@"%lf", Rotate_z]];;
             
             self.quaterWLabel.text =[NSString stringWithFormat:@"%@%@", @"Quater_W = ", [NSString stringWithFormat:@"%lf", Quater_w]];;
             self.quaterXLabel.text =[NSString stringWithFormat:@"%@%@", @"Quater_X = ", [NSString stringWithFormat:@"%lf", Quater_x]];;
             self.quaterYLabel.text =[NSString stringWithFormat:@"%@%@", @"Quater_Y = ", [NSString stringWithFormat:@"%lf", Quater_y]];;
             self.quaterZLabel.text =[NSString stringWithFormat:@"%@%@", @"Quater_Z = ", [NSString stringWithFormat:@"%lf", Quater_z]];;
             
             self.accXLabel.text =[NSString stringWithFormat:@"%@%@", @"Acc_X = ", [NSString stringWithFormat:@"%lf", Acc_x]];;
             self.accYLabel.text =[NSString stringWithFormat:@"%@%@", @"Acc_Y = ", [NSString stringWithFormat:@"%lf", Acc_y]];;
             self.accZLabel.text =[NSString stringWithFormat:@"%@%@", @"Acc_Z = ", [NSString stringWithFormat:@"%lf", Acc_z]];;
             
             self.rollLabel.text =[NSString stringWithFormat:@"%@%@", @"Roll = ", [NSString stringWithFormat:@"%lf", Roll]];;
             self.pitchLabel.text =[NSString stringWithFormat:@"%@%@", @"Pitch = ", [NSString stringWithFormat:@"%lf", Pitch]];;
             self.yawLabel.text =[NSString stringWithFormat:@"%@%@", @"Yaw = ", [NSString stringWithFormat:@"%lf", Yaw]];;
             
             
         }];
    }
    

}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    heading_x =  heading.x;
    heading_y = heading.y;
    heading_z = heading.z;
    
    self.headingXLabel.text = [NSString stringWithFormat:@"%@%@", @"Heading_X = ", [NSString stringWithFormat:@"%lf", heading_x]];
    self.headingYLabel.text =[NSString stringWithFormat:@"%@%@", @"Heading_Y = ", [NSString stringWithFormat:@"%lf", heading_y]];
    self.headingZLabel.text =[NSString stringWithFormat:@"%@%@", @"Heading_Z = ", [NSString stringWithFormat:@"%lf", heading_z]];
    
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // Assigning the last object as the current location of the device
    CLLocation *currentLocation = [locations lastObject];
    CLLocationDegrees latitude=currentLocation.coordinate.latitude;
    CLLocationDegrees longitude=currentLocation.coordinate.longitude;
    lon = longitude;
    lat = latitude;
    self.longLabel.text =[NSString stringWithFormat:@"%@%@", @"Longitude = ", [NSString stringWithFormat:@"%lf", lon]];
    self.latLabel.text =[NSString stringWithFormat:@"%@%@", @"Latitude = ", [NSString stringWithFormat:@"%lf", lat]];

    
}

- (void)actionstop
{
    
    if ([myTimer isValid]) {
        
        [myTimer invalidate];
    }
    myTimer = nil;
}

- (void)actionStart
{
    
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:myTimer_interval
                                                   target:self
                                                 selector:@selector(onTick:)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    
}

///////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [motionActivityManager stopActivityUpdates];
    [motionManager stopGyroUpdates];
    [motionManager stopDeviceMotionUpdates];
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    [pedometer stopPedometerUpdates];
    [super viewDidDisappear:animated];
    
}
/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)snapButtonPressed:(UIButton *)button
{

        if(!self.camera.isRecording) {
           
            
            self.segmentedControl.hidden = YES;
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            self.backButton.hidden = YES;
            
            self.snapButton.layer.borderColor = [UIColor redColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            // start recording sersor data
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss-SSS"];
            NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate networkDate]];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.csv",formattedDateString];
            _csvFilePath =[self dataFilePath:fileName];

            [[NSFileManager defaultManager] createFileAtPath:_csvFilePath contents:nil attributes:nil];
            
            fh = [NSFileHandle fileHandleForWritingAtPath:_csvFilePath];
            [fh seekToEndOfFile];
            NSArray *keys = @[@"FrameNO",
                              @"Sec",
                              @"Date",
                              
                              @"Roll",
                              @"Pitch",
                              @"Yaw",
                              @"Gyro_x",
                              @"Gyro_y",
                              @"Gyro_z",
                              
                              @"Rotate_x",
                              @"Rotate_y",
                              @"Rotate_z",
                              
                              @"Acc_x",
                              @"Acc_y",
                              @"Acc_z",
                              
                              @"Grav_x",
                              @"Grav_y",
                              @"Grav_z",
                              
                              @"Quater_w",
                              @"Quater_x",
                              @"Quater_y",
                              @"Quater_z",
                              
                              @"DeviceMotion_timestamp",
                              
                              @"Heading_x",
                              @"Heading_y",
                              @"Heading_z",
                              
                              @"Longitude",
                              @"Latitude",
                              
                              @"Act_type",
                              @"Act_startDate",
                              @"Confidence",
                              
                              @"NumberOfSteps",
                              @"Distance_meters",
                              @"SecondsPerMeter",
                              @"StepsPerSecond",
                              @"FloorsAscended",
                              @"FloorsDescended"

                              ];
            
            NSString *temp;
            sec_count =0;
            cDate1 = [NSDate networkDate];
            recStartDate = cDate1;
            temp = [NSString stringWithFormat:@"%@", [keys objectAtIndex:0]];
            
            for (int i = 1; i < [keys count]; i++) {
                
                temp = [temp stringByAppendingFormat:@", %@", [keys objectAtIndex:i]];
            }
            [self dataWrite:temp];
            [self actionStart];
            
            // start recording
            outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:formattedDateString] URLByAppendingPathExtension:@"mov"];
            
            
            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                
                recStopDate = [NSDate networkDate];
                [pedometer queryPedometerDataFromDate:recStartDate toDate:recStopDate withHandler:^(CMPedometerData *pedometerData, NSError *error)
                 {
                     if (error)
                     {
                         NSLog(@"error: %@", error);
                     }else{
                         NSLog(@"pedometerData: %@", pedometerData);
                         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                         [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss-SSS"];
                        
                         
                         NSString *pedofileName = [NSString stringWithFormat:@"%@~%@.csv",[dateFormatter stringFromDate:recStartDate], [dateFormatter stringFromDate:recStopDate]];
                         NSString *csvPedoFilePath =[self dataFilePath:pedofileName];
                         
                         [[NSFileManager defaultManager] createFileAtPath:csvPedoFilePath contents:nil attributes:nil];
                         
                         NSFileHandle *fh_pedo = [NSFileHandle fileHandleForWritingAtPath:csvPedoFilePath];
                         [fh_pedo seekToEndOfFile];
                         NSArray *keys = @[@"recStartDate",
                                           @"recEndDate",
                                           @"steps",
                                           @"Distance_meters",
                                           @"floorsAscended",
                                           @"floorsDescended",
                                           @"SecondsPerMeter",
                                           @"StepsPerSecond"
                                           
                                           ];
                         NSString *temp = [NSString stringWithFormat:@"%@", [keys objectAtIndex:0]];
                         
                         for (int i = 1; i < [keys count]; i++) {
                             
                             temp = [temp stringByAppendingFormat:@", %@", [keys objectAtIndex:i]];
                         }
                         [fh_pedo writeData:[temp dataUsingEncoding:NSUTF8StringEncoding]];
                         [fh_pedo writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                         [fh_pedo seekToEndOfFile];
                         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                         temp =@"";
                         temp = [temp stringByAppendingFormat:@"%@,", [dateFormatter stringFromDate:[pedometerData startDate]]];
                         temp = [temp stringByAppendingFormat:@"%@,", [dateFormatter stringFromDate:[pedometerData endDate]]];
                         temp = [temp stringByAppendingFormat:@"%@,", [pedometerData numberOfSteps]];
                         temp = [temp stringByAppendingFormat:@"%@,", [pedometerData distance]];
                         temp = [temp stringByAppendingFormat:@"%@,", [pedometerData floorsAscended]];
                         temp = [temp stringByAppendingFormat:@"%@,", [pedometerData floorsDescended]];
                         temp = [temp stringByAppendingFormat:@"%@,", [pedometerData currentPace]];
                         temp = [temp stringByAppendingFormat:@"%@", [pedometerData currentCadence]];

                         [fh_pedo writeData:[temp dataUsingEncoding:NSUTF8StringEncoding]];
                         [fh_pedo writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                         [fh_pedo closeFile];
                         
                     }
                 }];
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if(error) {
                        NSLog(@"CameraViewController: Error on saving movie : %@ {imagePickerController}", error);
                    } else {
                        NSLog(@"URL: %@", assetURL);
                    }
                }];
                
                VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:outputFileUrl];
                [self.navigationController pushViewController:vc animated:YES];
                
            }];
            
        } else {
            framecounter = 0;
            self.segmentedControl.hidden = NO;
            self.flashButton.hidden = NO;
            self.switchButton.hidden = NO;
            self.backButton.hidden = NO;
            self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            [self actionstop];
            [self.camera stopRecording];
            
           
        }

}

-(void)onTick:(NSTimer *)myTimer{
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS "];
    
     cDate2 = [NSDate networkDate];
    sec_count = sec_count +[cDate2 timeIntervalSinceDate:cDate1];
    cDate1 = cDate2;
    
    NSString *formattedDateString = [dateFormatter stringFromDate:cDate2];
    _networkTimeLabel.text = formattedDateString;
   
    framecounter +=1;
    NSString *csv;
    [fh seekToEndOfFile];
    csv = [NSString stringWithFormat:@"%d,%f,%@,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%@,%@,%@,%@,%@,%@,%@,%@,%@",
           framecounter,
           sec_count,
           formattedDateString,
    
           Roll,
           Pitch,
           Yaw,
           
           
           Gyro_x,
           Gyro_y,
           Gyro_z,
           
           Rotate_x,
           Rotate_y,
           Rotate_z,
           
           Acc_x,
           Acc_y,
           Acc_z,
           
           Grav_x,
           Grav_y,
           Grav_z,
           
           Quater_w,
           Quater_x,
           Quater_y,
           Quater_z,
           
           devicemotionData_timestamp,
           
           heading_x,
           heading_y,
           heading_z,
           
           lon,
           lat,
           activityType_v,
           [dateFormatter stringFromDate:activityStartDate_v],
           confidence_v,
           
           numberOfSteps_v,
           distance_meters_v,
           pacePerMeter_v,
           cadence_v,
           floors_ascended_v,
           floors_descended_v
           ];
    
       [self dataWrite:csv];
    
    
}

-(void ) setScreenPortrait
{
    left1 = self.view.width/2 - 80;
    self.quaterWLabel.left =left1;
    self.quaterXLabel.left =left1;
    self.quaterYLabel.left =left1;
    self.quaterZLabel.left =left1;
    
    self.accXLabel.left =left1;
    self.accYLabel.left =left1;
    self.accZLabel.left =left1;
    
    self.rotateXLabel.left =left1;
    self.rotateYLabel.left =left1;
    self.rotateZLabel.left =left1;
    
    self.rollLabel.left =left1;
    self.pitchLabel.left =left1;
    self.yawLabel.left =left1;
    
    self.headingXLabel.left =left1;
    self.headingYLabel.left =left1;
    self.headingZLabel.left =left1;
    
    self.longLabel.left =left1;
    self.latLabel.left =left1;
    self.activityType.left =left1  ;
    self.activityStartDate.left = left1;
    self.confidence.left = left1;
    
    self.numberOfSteps.left = left1;
    self.distance_meters.left = left1;
    self.pacePerMeter.left = left1;
    self.cadenceLabel.left = left1;
    self.floors_ascended.left = left1;
    self.floors_descended.left = left1;
    
    left1 = 50;
    self.quaterWLabel.top =left1 + 30;
    self.quaterXLabel.top =left1+ 60;
    self.quaterYLabel.top =left1+ 90;
    self.quaterZLabel.top =left1+ 120;
    
    self.accXLabel.top =left1+ 160;
    self.accYLabel.top =left1+ 190;
    self.accZLabel.top =left1+ 220;
    
    self.rotateXLabel.top =left1+ 260;
    self.rotateYLabel.top =left1+ 290;
    self.rotateZLabel.top =left1+ 320;
    
    self.rollLabel.top =left1+ 360;
    self.pitchLabel.top =left1+ 390;
    self.yawLabel.top =left1+ 420;
    
    self.headingXLabel.top =left1+ 50;
    self.headingYLabel.top =left1+ 100;
    self.headingZLabel.top =left1+ 150;
    
    self.longLabel.top =left1+ 230;
    self.latLabel.top =left1+ 280;
   
    self.activityType.top =left1 + 200 ;
    self.activityStartDate.top = left1+230;
    self.confidence.top = left1+ 260;
    
    self.numberOfSteps.top = left1+ 300;
    self.distance_meters.top = left1+ 330;
    self.pacePerMeter.top = left1+ 360;
    self.cadenceLabel.top = left1+ 390;
    self.floors_ascended.top = left1+ 430;
    self.floors_descended.top = left1+ 460;
}

-(void) setScreenLandscape
{
    left1 = self.view.width/2 - 80;
    self.quaterWLabel.left =left1;
    self.quaterXLabel.left =left1;
    self.quaterYLabel.left =left1;
    self.quaterZLabel.left =left1;
    
    self.accXLabel.left =left1;
    self.accYLabel.left =left1;
    self.accZLabel.left =left1;
    
    self.rotateXLabel.left =left1;
    self.rotateYLabel.left =left1;
    self.rotateZLabel.left =left1;
    
    self.rollLabel.left =left1;
    self.pitchLabel.left =left1;
    self.yawLabel.left =left1;
    
    self.headingXLabel.left =left1;
    self.headingYLabel.left =left1;
    self.headingZLabel.left =left1;
    
    self.longLabel.left =left1;
    self.latLabel.left =left1;
    self.activityType.left =left1  ;
    self.activityStartDate.left = left1;
    self.confidence.left = left1;
    
    self.numberOfSteps.left = left1;
    self.distance_meters.left = left1;
    self.pacePerMeter.left = left1;
    self.cadenceLabel.left = left1;
    self.floors_ascended.left = left1;
    self.floors_descended.left = left1;
    left1 = 5;
    self.quaterWLabel.top =left1 + 30;
    self.quaterXLabel.top =left1+ 50;
    self.quaterYLabel.top =left1+ 70;
    self.quaterZLabel.top =left1+ 90;
    
    self.accXLabel.top =left1+ 120;
    self.accYLabel.top =left1+ 140;
    self.accZLabel.top =left1+ 160;
    
    self.rotateXLabel.top =left1+ 190;
    self.rotateYLabel.top =left1+ 210;
    self.rotateZLabel.top =left1+ 230;
    
    self.rollLabel.top =left1+ 260;
    self.pitchLabel.top =left1+ 280;
    self.yawLabel.top =left1+ 300;
    
    left1 = 30;
    self.headingXLabel.top =left1+ 40;
    self.headingYLabel.top =left1+ 80;
    self.headingZLabel.top =left1+ 120;
    
    self.longLabel.top =left1+ 170;
    self.latLabel.top =left1+ 210;
    left1 = 10;
    self.activityType.top =left1 + 40 ;
    self.activityStartDate.top = left1+70;
    self.confidence.top = left1+ 100;
    
    self.numberOfSteps.top = left1+ 140;
    self.distance_meters.top = left1+ 170;
    self.pacePerMeter.top = left1+ 200;
    self.cadenceLabel.top = left1+ 230;
    self.floors_ascended.top = left1+ 260;
    self.floors_descended.top = left1+ 290;
    
  
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
        [self setScreenPortrait ];
            
            break;
            
        case UIDeviceOrientationLandscapeLeft :
            /* start special animation */
            [self setScreenLandscape];

              break;
        case UIDeviceOrientationLandscapeRight :
            /* start special animation */
            [self setScreenLandscape ];

            break;


            
        default:
            
            break;
    };
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 15.0f;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
    
    self.networkTimeLabel.left = 12.0f;
    self.networkTimeLabel.bottom = self.view.height - 60.0f;
    
    self.segmentedControl.left = 12.0f;
    self.segmentedControl.bottom = self.view.height - 35.0f;
    
    self.segmentedSensorSelectControl.left = 12.0f;
    self.segmentedSensorSelectControl.bottom = self.view.height - 120.0f;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createUpdateUITimer {
    double counter = 1.00;
    self.oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:counter target:self selector:@selector(oneSecondTimerTick1) userInfo:nil repeats:YES];
}

- (void)oneSecondTimerTick1 {
    [self updateDateToLabel];
}
-(void) updateDateToLabel{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate networkDate]];
    self.networkTimeLabel.text = formattedDateString;
}

@end
