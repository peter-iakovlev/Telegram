/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernView.h"

@class TGAudioSliderView;

@protocol TGAudioSliderViewDelegate <NSObject>

@optional

- (void)audioSliderViewDidBeginPositionAdjustment:(TGAudioSliderView *)audioSliderView;
- (void)audioSliderViewDidEndPositionAdjustment:(TGAudioSliderView *)audioSliderView atPosition:(CGFloat)position;
- (void)audioSliderViewDidCancelPositionAdjustment:(TGAudioSliderView *)audioSliderView;

@end

@interface TGAudioSliderView : UIView <TGModernView>

@property (nonatomic, weak) id<TGAudioSliderViewDelegate> delegate;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) bool incoming;
@property (nonatomic, strong) NSString *audioDurationText;
@property (nonatomic) bool manualPositionAdjustmentEnabled;
@property (nonatomic) bool progressMode;
@property (nonatomic) NSTimeInterval preciseDuration;
@property (nonatomic) bool listenedStatus;

- (void)setAudioPosition:(float)audioPosition animated:(bool)animated timestamp:(NSTimeInterval)timestamp isPlaying:(bool)isPlaying immediate:(bool)immediate;
- (void)stopAnimations;

@end
