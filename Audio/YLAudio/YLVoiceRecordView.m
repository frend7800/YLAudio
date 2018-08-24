//
//  YLVoiceRecordView.m
//  CameraTest
//
//  Created by 魏新杰 on 2018/8/24.
//  Copyright © 2018年 weixinjie. All rights reserved.
//

#import "YLVoiceRecordView.h"

@interface YLVoiceRecordView()

@property (nonatomic, strong) UIImageView  * recordImgView; //录音

@property (nonatomic, strong) UIImageView  * cancelImgView;//取消

@property (nonatomic, strong) UILabel      * hintLabel;//提示

@end

@implementation YLVoiceRecordView



- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor     = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        self.layer.cornerRadius  = 5.0;
        
        self.layer.masksToBounds = YES;
        
    }
    
    return self;
}

- (UIImageView *)recordImgView{
    
    if (!_recordImgView) {
        
        _recordImgView = [[UIImageView alloc] init];
        
        _recordImgView.backgroundColor  = [UIColor clearColor];
        
        _recordImgView.image   =  [UIImage imageNamed:@"voiceRecord_icon"];
    }
    
    return _recordImgView;
}

- (UIImageView *)soundwaveImgView{
    
    if (!_soundwaveImgView) {
        
        _soundwaveImgView = [[UIImageView alloc] init];
        
        _soundwaveImgView.backgroundColor  = [UIColor clearColor];
        
        _soundwaveImgView.image   =  [UIImage imageNamed:@""];
    }
    
    return _soundwaveImgView;
}

- (UIImageView *)cancelImgView{
    
    if (!_cancelImgView) {
        
        _cancelImgView = [[UIImageView alloc] init];
        
        _cancelImgView.backgroundColor  = [UIColor clearColor];
        
        _cancelImgView.image   =  [UIImage imageNamed:@"recordCancel_icon"];
    }
    
    return _cancelImgView;
}

- (UILabel *)hintLabel{
    
    if (!_hintLabel) {
        
        _hintLabel  =  [[UILabel alloc] init];
        
        _hintLabel.backgroundColor = [UIColor clearColor];
        
        _hintLabel.textColor       = [UIColor whiteColor];
        
        _hintLabel.textAlignment   = NSTextAlignmentCenter;
        
        _hintLabel.font            = [UIFont systemFontOfSize:12];
        
    }
    
    return _hintLabel;
}

- (void)startRecord{
    
    [_cancelImgView removeFromSuperview];
    [_recordImgView removeFromSuperview];
    [_soundwaveImgView removeFromSuperview];
    [_hintLabel removeFromSuperview];
    
    [self addSubview:self.recordImgView];
    [self addSubview:self.soundwaveImgView];
    [self addSubview:self.hintLabel];
    
    self.hintLabel.backgroundColor = [UIColor clearColor];
    self.hintLabel.text            = @"手指上滑，取消发送";
    
    self.hintLabel.frame = CGRectMake(15, self.bounds.size.height - 15 -18,
                                      self.bounds.size.width - 15*2, 18);
    
    self.recordImgView.frame = CGRectMake((self.bounds.size.width - 50)/2.0 - 10,
                                          (self.bounds.size.height - 65)/2.0 - 10,
                                          50, 65);
    
    self.soundwaveImgView.frame = CGRectMake(CGRectGetMaxX(self.recordImgView.frame) + 2,
                                             CGRectGetMinY(self.recordImgView.frame),
                                             20, 65);
}

- (void)cancelRecord{
    
    [_cancelImgView removeFromSuperview];
    [_recordImgView removeFromSuperview];
    [_soundwaveImgView removeFromSuperview];
    [_hintLabel removeFromSuperview];
    
    [self addSubview:self.cancelImgView];
    [self addSubview:self.hintLabel];
    
    self.hintLabel.backgroundColor = [UIColor redColor];
    self.hintLabel.text            = @"松开手指，取消发送";
    
    self.hintLabel.frame = CGRectMake(15, self.bounds.size.height - 15 -18,
                                      self.bounds.size.width - 15*2, 18);
    
    self.cancelImgView.frame = CGRectMake((self.bounds.size.width - 50)/2.0 ,
                                          (self.bounds.size.height - 65)/2.0 - 10,
                                          50, 65);
    
}


@end
