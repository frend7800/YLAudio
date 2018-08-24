//
//  YLAudioRecord.m
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/21.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import "YLAudioRecord.h"
#import "PFAudio.h"
#import "YLVoiceRecordView.h"
#import "AppDelegate.h"

#define KRecordAudioFile @"myRecord.caf"

#define KMaxRecord_Duration    60.0

@interface YLAudioRecord()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder  *  audioRecorder;//音频录音机

@property (nonatomic, strong) NSTimer          *  timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (nonatomic, strong) AVAudioSession   *  audioSession;//

@property (nonatomic, strong) NSDictionary     *  recordSetting;//录音配置信息

@property (nonatomic, copy)   NSString         *  firstFilePath;//第一次生成文件的路径

@property (nonatomic, copy)   NSString         *  recordPath;//录音存储文件夹地址

@property (nonatomic, copy)   NSString         *  fileName;//录音文件名(不带后缀)

@property (nonatomic, assign) CGFloat             timeCount;//录音计时

@property (nonatomic, strong) YLVoiceRecordView * recordView;

@end

@implementation YLAudioRecord

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
      
        _timeCount = 0;
        
        [self setAudioSession];
        
        self.recordView  =  [[YLVoiceRecordView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
        
    }
    
    return self;
}

/**
 
 *  设置音频会话
 
 */

-(void)setAudioSession{
    
    AVAudioSession *audioSession =  [AVAudioSession sharedInstance];
    
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    self.audioSession = audioSession;
}


-(void)createFileName{
    
    //这里需要修改路径。。。
    NSTimeInterval time  =  [[NSDate date] timeIntervalSince1970];
    
    self.fileName =  [NSString stringWithFormat:@"%d",(int)time];
    
}

/**
 
 *  取得录音文件保存路径
 
 */

- (NSString *)recordPath{
    
    if (!_recordPath) {
        
        NSString * urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
        
        urlStr = [urlStr stringByAppendingPathComponent:@"Record"];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:urlStr withIntermediateDirectories:YES attributes:nil error:nil];
        
         NSLog(@"file path:%@",urlStr);
        
        _recordPath = urlStr;
    }
    
    return _recordPath;
}

/**
 
 *  取得录音文件设置
 
 *  @return 录音设置
 
 */

-(NSDictionary *)recordSetting{
    
    if (!_recordSetting) {
        
        NSMutableDictionary * dicM  =  [NSMutableDictionary dictionary];
        
        //设置录音格式 aac(kAudioFormatMPEG4AAC)  pcm(kAudioFormatLinearPCM) 
        
        [dicM setObject:@(kAudioFormatLinearPCM)forKey:AVFormatIDKey];
        
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        
        [dicM setObject:@(8000)forKey:AVSampleRateKey];
        
        //设置编码器比特率 8
       // [dicM setObject:@(8) forKey:AVEncoderBitRateKey];
        
        //设置通道,这里采用单声道
        
        [dicM setObject:@(2)forKey:AVNumberOfChannelsKey];
        
        //每个采样点位数,分为8、16、24、32
        
       // [dicM setObject:@(16)forKey:AVLinearPCMBitDepthKey];
        
        //声音质量  高质量
        [dicM setObject:@(AVAudioQualityLow) forKey:AVEncoderAudioQualityKey];
        
        //是否使用浮点数采样
        
       // [dicM setObject:@(YES)forKey:AVLinearPCMIsFloatKey];
        
        //....其他设置等
        
        _recordSetting = dicM;
        
    }
    
    return _recordSetting;
    
}

- (void)setupAudioRecord{
    
    
    //创建录音文件保存路径
    
    NSString  * path     = self.recordPath;
    
    [self createFileName];
    
    NSString  * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pcm",self.fileName]];
    
    self.firstFilePath   = filePath;
    
    NSURL *url = [NSURL URLWithString:filePath];
    
    //创建录音格式设置
    
    NSDictionary *setting = self.recordSetting;
    
    //创建录音机
    
    NSError *error =nil;
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    
    _audioRecorder.delegate =self;
    
    _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    
    //准备记录录音
    [_audioRecorder prepareToRecord];
    
    if (error) {
        
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
        
        _audioRecorder = nil;
        
    }
    
}

/**
 
 *  录音声波监控定制器
 
 *  @return 定时器
 
 */

-(NSTimer *)timer{
    
    if (!_timer) {
        
        _timer  =  [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
        
    }
    
    return _timer;
    
}

/**
 
 *  录音声波状态设置
 
 */

-(void)audioPowerChange{
    
    [self.audioRecorder updateMeters];//更新测量值
    
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    
    CGFloat progress=(1.0/160.0)*(power+160.0);
    
    self.timeCount = self.timeCount + 0.5f;
    
    self.recordView.soundwaveImgView.backgroundColor = [UIColor colorWithRed:200/255.0 green:progress blue:180/255.0 alpha:1.0];

    
    if ([self.delegate respondsToSelector:@selector(audioRecordPowerProgress:recordTime:)]) {
        
        [self.delegate audioRecordPowerProgress:progress recordTime:self.timeCount];
    }
    
    if (self.timeCount >= KMaxRecord_Duration) {
        
        [self stopRecordVoice];
    }
    
}

/*
 * 开始录制音频
 */
- (void)startRecordVoice{
    
    //[self.audioRecorder record];
    //音频播放录音设置
    [self setAudioSession];
    
    //录音参数及路径初始化
    [self setupAudioRecord];
    
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder stop];
        [self.audioRecorder deleteRecording];
    }
    [self checkAudioRecordAvailable];
}

/*
 * 停止录制音频
 */
- (void)stopRecordVoice{
    
    [self.audioRecorder stop];
    
    [_timer invalidate];
     _timer   =  nil;
    [self.recordView removeFromSuperview];
    
    //将录制的默认为pcm的音频格式转换为arm 格式
    if ([PFAudio pcm2Mp3:self.firstFilePath isDeleteSourchFile:YES]) {

        NSString  * audioPath    = [NSString stringWithFormat:@"%@/%@.mp3",self.recordPath,self.fileName];
        
        NSURL     * audioUrlPath = [NSURL fileURLWithPath:audioPath];
        
        NSData    *  data        = [NSData dataWithContentsOfURL:audioUrlPath];
        
        if (self.finishAudioRecord) {
            
            self.finishAudioRecord(data, self.timeCount);
            
        }
        
        if (self.outputAudioRecord) {
            
            self.outputAudioRecord(audioPath);
        }
        
        NSFileManager *mgr = [NSFileManager defaultManager];

        [mgr removeItemAtPath:audioPath error:nil];
        
    }else{
        
        if (self.finishAudioRecord) {
            self.finishAudioRecord(nil, self.timeCount);
        }
    }
   // [self.audioRecorder deleteRecording];
     self.timeCount = 0;
     self.firstFilePath = nil;
     self.fileName = nil;
    
}

/*
 * 取消录制音频
 */
- (void)cancelRecordVoice{
    
    [self.audioRecorder stop];
    [self.audioRecorder deleteRecording];
    
    [_timer invalidate];
    _timer   =  nil;
    
    self.timeCount = 0;
    self.firstFilePath = nil;
    
     [self.recordView cancelRecord];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.recordView removeFromSuperview];
    });
    
}

- (void)checkAudioRecordAvailable{
    
    if ([self.audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        __weak __typeof(self) weakSelf = self;
        [self.audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                
                // 用户同意获取麦克风，一定要在主线程中执行UI操作！！！
                dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queueOne, ^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"可以开始进行录音了。。。。");
                        //在主线程中执行UI，这里主要是执行录音和计时的UI操作
                       [weakSelf.audioRecorder record];
                       [weakSelf loadRecordView];
                       [weakSelf.timer fire];
                        
                    });
                });
            } else {
                
                // 用户不同意获取麦克风
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"麦克风不可用" message:@"请在“设置 - 隐私 - 麦克风”中允许XXX访问你的麦克风" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                
                [alert  show];
                
                if ([self.delegate respondsToSelector:@selector(audioRecordUnavailable)]) {
                    [self.delegate audioRecordUnavailable];
                }

            }
        }];
    }
    
}

- (void)loadRecordView{
    
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    CGSize  size  = [UIScreen mainScreen].bounds.size;
    
    self.recordView.frame = CGRectMake((size.width - 150)/2.0, (size.height - 150)/2.0, 150, 150);
    
    [app.window addSubview:self.recordView];
    
    [self.recordView startRecord];
    
}


- (void)dealloc{
    
    _audioRecorder     = nil;
    
    _audioSession      = nil;
    
    _recordPath        = nil;
    
    _timer             = nil;
    
    _recordSetting     = nil;
    
}


@end
