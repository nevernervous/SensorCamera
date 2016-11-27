//
//  SettingViewController.m
//  SensorCamera
//
//  Created by borysM on 11/15/16.
//  Copyright © 2016 justin. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController (){
    float interval;
    int frames;
}
- (IBAction)sensorSlider_valuechange:(UISlider *)sender;
- (IBAction)framesSlider_valuechange:(UISlider*)sender;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden = NO;
    _sensorSlider.value =0;
    _frameSlider.value =0.24;
       }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    [self startUpdatesWithSensorSliderValue:(int)(self.sensorSlider.value * 100)];
    [self startUpdatesWithFramesSliderValue:(int)(self.frameSlider.value *100)];

}

- (IBAction)GoBack:(id)sender {
   
    [self.delegate returnFrameSliderValue:frames];
    [self.delegate returnSensorSliderValue:interval];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sensorSlider_valuechange:(UISlider*)sender {
    [self startUpdatesWithSensorSliderValue:(int)(sender.value * 100)];
   
}

- (IBAction)framesSlider_valuechange:(UISlider*)sender {
    [self startUpdatesWithFramesSliderValue:(int)(sender.value * 100)];
}
- (void)startUpdatesWithSensorSliderValue:(int)sliderValue{
    NSTimeInterval accelerometerMin = 0.01;
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = accelerometerMin + delta * sliderValue;
    interval = updateInterval;
     self.sensorIntervalLabel.text =[NSString stringWithFormat:@"%f",updateInterval];
    
    
    
}
- (void)startUpdatesWithFramesSliderValue:(int)sliderValue{
    
    
    int updateInterval =  sliderValue;
    self.framesLabel.text =[NSString stringWithFormat:@"%d",updateInterval];
    frames = updateInterval;
}

@end
