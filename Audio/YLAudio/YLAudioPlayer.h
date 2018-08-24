//
//  YLAudioPlayer.h
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/23.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface YLAudioPlayer : NSObject

//- (void)playAudioData:(NSData *)data;

//播放单个音频文件
- (void)playAudioWithContentUrl:(NSString *)url;

//播放多个音频文件
- (void)playAudioWithUrlArray:(NSArray *)array;


@end
