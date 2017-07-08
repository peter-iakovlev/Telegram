/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import <MTProtoKit/MTTime.h>

@protocol TGModernViewInlineMediaContextDelegate <NSObject>

@optional

- (void)inlineMediaPlaybackStateUpdated:(bool)isPaused playbackPosition:(float)playbackPosition timestamp:(CFAbsoluteTime)timestamp preciseDuration:(NSTimeInterval)preciseDuration;

@end

@interface TGModernViewInlineMediaContext : NSObject

@property (nonatomic, weak) id<TGModernViewInlineMediaContextDelegate> delegate;

- (void)setDelegate:(id<TGModernViewInlineMediaContextDelegate>)delegate;
- (void)removeDelegate:(id<TGModernViewInlineMediaContextDelegate>)delegate;

- (bool)isPlaybackActive;
- (bool)isPaused;
- (float)playbackPosition:(CFAbsoluteTime *)timestamp;
- (float)playbackPosition:(CFAbsoluteTime *)timestamp sync:(bool)sync;
- (NSTimeInterval)preciseDuration;

- (void)play;
- (void)play:(float)playbackPosition;
- (void)pause;

- (void)postUpdatePlaybackPosition:(bool)sync;

@end
