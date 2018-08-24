//
//  YLVoiceRecordView.h
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/24.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLVoiceRecordView : UIView

@property (nonatomic, strong) UIImageView  * soundwaveImgView;//声波

//开始录制
- (void)startRecord;

//取消录制
- (void)cancelRecord;

@end
