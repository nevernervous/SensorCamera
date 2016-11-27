//
//  ViewController.m
//  NHNetworkTimeExample
//
//  Created by Nguyen Cong Huy on 9/20/15.
//  Copyright © 2015 Nguyen Cong Huy. All rights reserved.
//

#import "FirstViewController.h"
#import "NHNetworkTime.h"
#import "HomeViewController.h"

#import "VideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface FirstViewController ()
{
    NSString *formattedDateString1;
//    float sensor_interval;
//    float sensor_interval_rec;
//    int framepersecond;
//    int frameperseecond_rec;
    
}


@property (nonatomic) float sensor_interval;
@property (nonatomic) int framepersecond;

@property (nonatomic) NSArray *fileNames;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncedLabel;

@property (nonatomic) NSTimer *oneSecondTimer;


@end

@implementation FirstViewController

- (id)init {
    if(self = [super init]) {
        
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self CheckFiles];
    
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _framepersecond = 24;
    _sensor_interval=0.01;
    self.navigationController.navigationBarHidden = YES;
    _cameraButton.enabled = false;
    _shareCSVButton.enabled = false;
    _ShareVideoButton.enabled = false;
    _playButton.enabled = false;
    [self updateDateToLabel];
    [self observeTimeSyncNotification];
    [self createUpdateUITimer];
    
    
}
-(void)returnFrameSliderValue:(int)item{
    _framepersecond = item;
}
-(void)returnSensorSliderValue:(float)item{
    _sensor_interval = item;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.oneSecondTimer invalidate];
}

#pragma mark - Notification

- (void)observeTimeSyncNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkTimeSyncCompleteNotification:) name:kNHNetworkTimeSyncCompleteNotification object:nil];
}

- (void)networkTimeSyncCompleteNotification:(NSNotification *)notification {
    [self updateDateToLabel];
}

#pragma mark - Update label timer

- (void)createUpdateUITimer {
    double counter = 1.00;
    self.oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:counter target:self selector:@selector(oneSecondTimerTick) userInfo:nil repeats:YES];
}

- (void)oneSecondTimerTick {
    [self updateDateToLabel];
}

#pragma mark - UI

- (void)updateDateToLabel {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
//    NSString *currentLabelText = [NSString stringWithFormat:@"%@", [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]]];
//    NSString *networkLabelText = [NSString stringWithFormat:@"%@", [[NSDate networkDate] descriptionWithLocale:[NSLocale systemLocale]]];
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate networkDate]];
    formattedDateString1 = [dateFormatter stringFromDate:[NSDate networkDate] ];

    self.currentLabel.text = formattedDateString;
    self.networkLabel.text = formattedDateString1;
    
   

    if([NHNetworkClock sharedNetworkClock].isSynchronized) {
        self.syncedLabel.text = @"Time is SYNCHRONIZED";
        _cameraButton.enabled =true;
        [_cameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.syncedLabel.textColor = [UIColor blueColor];
    }
    else {
        self.syncedLabel.text = @"Time is NOT synchronized";
        self.syncedLabel.textColor = [UIColor redColor];
        _cameraButton.enabled =false;
        [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (IBAction)openCamera:(id)sender {
   HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.strNetDate = formattedDateString1;
    homeVC.delegate = self;
    
    homeVC.fps = _framepersecond;
    homeVC.sensorInterval = _sensor_interval;
    [self.navigationController pushViewController:homeVC animated:YES];
    
}

- (IBAction)deleteFiles:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docDirectory = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *directory = [docDirectory stringByAppendingPathComponent:@"Photos/"];
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:docDirectory error:&error];
    for (NSString *file in files) {
        NSString *fullfile = [NSString stringWithFormat:@"%@/%@", docDirectory, file];
        BOOL success = [fm removeItemAtPath:fullfile error:&error];
        if (!success || error) {
            // it failed.
        }
    }
    [self CheckFiles];
}
-(void) CheckFiles{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docDirectory = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    //    NSString *directory = [docDirectory stringByAppendingPathComponent:@"Photos/"];
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:docDirectory error:&error];
    if([files count] ==0)
    {
        _fileNames = nil;
        self.delButton.enabled = NO;
        self.shareCSVButton.enabled = NO;
        self.ShareVideoButton.enabled = NO;
        self.playButton.enabled = NO;
        [_delButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        self.delButton.enabled = YES;
        if(_fileNames != nil)
        {
            self.shareCSVButton.enabled = YES;
            self.ShareVideoButton.enabled = YES;
            self.playButton.enabled = YES;
           
        }
        
        
        [_delButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    
}

- (void)addItemViewController:(HomeViewController *)controller didFinishEnteringItem:(NSArray *)item
{
//    NSLog(@"This was returned from ViewControllerB %@",item);
    _fileNames = item;
    [self CheckFiles];
}



- (IBAction)Share_CSV:(id)sender {
    //NSURL *url = [self fileToURL:self.documentName];
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *docDirectory = [paths objectAtIndex:0];
    //    NSString *filePath =  [docDirectory stringByAppendingPathComponent:_csvfileName];
    
    NSArray *objectsToShare = @[_fileNames[0]];
    if(_fileNames == nil) return;
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)Share_Video:(id)sender {
    NSArray *objectsToShare = @[_fileNames[1]];
    if(_fileNames == nil) return;
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SettingViewController *svc = [segue destinationViewController];
    svc.delegate = self;
}


- (IBAction)playVideo:(id)sender {
    if(_fileNames == nil) return;
    VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:_fileNames[1]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
