/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGAudioSliderArea;

@protocol TGAudioSliderAreaDelegate <NSObject>

@optional

- (void)audioSliderDidBeginDragging:(TGAudioSliderArea *)sliderArea withTouch:(UITouch *)touch;
- (void)audioSliderDidFinishDragging:(TGAudioSliderArea *)sliderArea;
- (void)audioSliderDidCancelDragging:(TGAudioSliderArea *)sliderArea;
- (void)audioSliderWillMove:(TGAudioSliderArea *)sliderArea withTouch:(UITouch *)touch;

@end

@interface TGAudioSliderArea : UISlider

@property (nonatomic, weak) id<TGAudioSliderAreaDelegate> delegate;

@end
