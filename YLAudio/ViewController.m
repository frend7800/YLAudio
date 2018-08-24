//
//  ViewController.m
//  YLAudio
//
//  Created by 魏新杰 on 2018/8/24.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import "ViewController.h"
#import "YLAudioRecord.h"
#import "YLAudioPlayer.h"

@interface ViewController ()<YLAudioRecordDelegate>

@property (nonatomic, strong) YLAudioRecord   * recorder;

@property (nonatomic, strong)  YLAudioPlayer  * player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.recorder = [[YLAudioRecord alloc] init];
    self.recorder.delegate = self;
    
    self.player  = [[YLAudioPlayer alloc] init];
    
}

- (IBAction)beginButtonClick:(id)sender {
    
     [self.recorder startRecordVoice];
    
}

- (IBAction)cancelButtonClick:(id)sender {
    
     [self.recorder cancelRecordVoice];
    
}

- (IBAction)finishButtonClick:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    
    self.recorder.finishAudioRecord = ^(NSData *data, CGFloat duration) {
        
        // NSLog(@"--------------- %@",data);
        
    };
    
    self.recorder.outputAudioRecord = ^(NSString *path) {
        
        [weakSelf.player playAudioWithContentUrl:path];
        
    };
    
    [self.recorder stopRecordVoice];
    
}



- (void)audioRecordPowerProgress:(CGFloat)progress recordTime:(CGFloat)recordTime{
    
    NSLog(@"audioRecordPowerProgress---- progress = %.2f  recordTime = %.2f",progress,recordTime);
}

- (void)audioRecordUnavailable{
    
    NSLog(@"audioRecordUnavailable");
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
