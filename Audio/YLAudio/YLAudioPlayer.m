//
//  YLAudioPlayer.m
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/23.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import "YLAudioPlayer.h"

@interface YLAudioPlayer() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer  * audioPlayer;

@property (nonatomic, strong) NSArray        * audioArray;//音频数组

@property (nonatomic, assign) NSInteger        index;//播放坐标

@end

@implementation YLAudioPlayer

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        //加入监听（扬声器与听筒模式）
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(sensorStateChange:)
         
                                                     name:@"UIDeviceProximityStateDidChangeNotification"
         
                                                   object:nil];
        
    }
    
    return self;
}

//处理监听触发事件

-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    
    //假设此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出。并将屏幕变暗（省电啊）
    
    if ([[UIDevice currentDevice] proximityState] == YES)//听筒模式
    {
        
        NSLog(@"Device is close to user");
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else //扬声器模式
    {
        
        NSLog(@"Device is not close to user");
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    }
    
}


//播放单个音频文件
- (void)playAudioWithContentUrl:(NSString *)url{
    
    //设置播放模式
    [self setDeviceVoiceOutputType];
    
    self.audioArray = nil;
    
    self.index = 0;
    
    NSURL * URL = nil;
    
    if ([url hasPrefix:@"http"]) {
        
        URL  = [NSURL URLWithString:url];
    }else{
        
        URL  = [NSURL fileURLWithPath:url];
    
    }
   
   //静音判断...
    if ([self checkDeviceIsSilence]) {

       // return;
    }
    NSLog(@"开始播放了---------%@",URL);
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:URL error:nil];
    
    self.audioPlayer.delegate  = self;
    
    //设置声音的大小
    self.audioPlayer.volume = 0.5;//范围为（0到1）；
    
    //准备播放
    [self.audioPlayer prepareToPlay];
    
    [self.audioPlayer play];
    
}

//播放多个音频文件
- (void)playAudioWithUrlArray:(NSArray *)array{
    
    //设置播放模式
    [self setDeviceVoiceOutputType];
    
    self.audioArray    = array;
    
    self.index  = 0;
    
    NSString  * string = self.audioArray[self.index];
    
    NSURL * URL = nil;
    
    if ([string hasPrefix:@"http"]) {
        
        URL  = [NSURL URLWithString:string];
    }else{
        
        URL  = [NSURL fileURLWithPath:string];
    }
    
    //静音判断...
    if ([self checkDeviceIsSilence]) {


       // return;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:URL error:nil];
    
    //设置声音的大小
    self.audioPlayer.volume = 0.5;//范围为（0到1）；
    
    //准备播放
    [self.audioPlayer prepareToPlay];
    
    [self.audioPlayer play];
    
}

#pragma Mark -- AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    NSLog(@"播放音频成功---------%f",player.duration);
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    self.audioPlayer = nil;
    self.audioPlayer.delegate  = nil;
        
     if (flag && self.audioArray != nil){
        
        self.index ++;
        
        if (self.index == self.audioArray.count) {
        
            self.audioArray  = nil;
            
            self.index  = 0;
            
        }else{
            
            
            NSString  * string = self.audioArray[self.index];
            
            NSURL * URL = nil;
            
            if ([string hasPrefix:@"http"]) {
                
                URL  = [NSURL URLWithString:string];
            }else{
                
                URL  = [NSURL fileURLWithPath:string];
            }
            
            //设置播放模式
            [self setDeviceVoiceOutputType];
            
            //静音判断...
            if ([self checkDeviceIsSilence]) {
                
                
                return;
            }
            
            self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:URL error:nil];
            
            //设置声音的大小
            self.audioPlayer.volume = 0.5;//范围为（0到1）；
            
            //准备播放
            [self.audioPlayer prepareToPlay];
            
            [self.audioPlayer play];
            
        }
    
    }
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    NSLog(@"播放音频出错了---------%@",error);
    
}

- (BOOL)checkDeviceIsSilence{
    
   float volume = [[AVAudioSession sharedInstance] outputVolume];

    if (volume <= 0) {
        
         NSLog(@"当前音量为静音....");
        UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请调大音量后播放" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return YES;
    }else{
        
        return NO;
    }
    
}

//设置设备声音播放模式
- (void)setDeviceVoiceOutputType{
    
    //初始化播放器的时候例如以下设置
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            
                            sizeof(sessionCategory),
                            
                            &sessionCategory);
    
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             
                             sizeof (audioRouteOverride),
                             
                             &audioRouteOverride);
    
    //传感器设置
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO。这个功能是开启红外感应
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //默认情况下扬声器播放
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    self.audioPlayer = nil;
    
    self.audioPlayer.delegate  = nil;
    
}

//


@end
