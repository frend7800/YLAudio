//
//  YLAudioRecord.h
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/21.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol  YLAudioRecordDelegate <NSObject>

//录音声波状态 录音时长
- (void)audioRecordPowerProgress:(CGFloat) progress recordTime:(CGFloat) recordTime;

//录音不可用
- (void)audioRecordUnavailable;

@end

@interface YLAudioRecord : NSObject

@property (nonatomic, weak) id <YLAudioRecordDelegate> delegate;

@property (nonatomic, copy) void(^finishAudioRecord)(NSData *data, CGFloat duration);

@property (nonatomic, copy) void(^outputAudioRecord)(NSString *path);

/*
 * 开始录制音频
 */
- (void)startRecordVoice;

/*
 * 停止录制音频
 */
- (void)stopRecordVoice;

/*
 * 取消录制音频
 */
- (void)cancelRecordVoice;


@end
