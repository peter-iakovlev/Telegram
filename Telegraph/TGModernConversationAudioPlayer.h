/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGAudioPlayer.h"

@class TGModernConversationAudioPlayer;
@class TGModernViewInlineMediaContext;

@protocol TGModernConversationAudioPlayerDelegate <NSObject>

@optional

- (void)audioPlayerDidPause;
- (void)audioPlayerDidFinish;

@end

@interface TGModernConversationAudioPlayer : NSObject

@property (nonatomic, weak) id<TGModernConversationAudioPlayerDelegate> delegate;
@property (nonatomic, strong) SQueue *queue;
@property (nonatomic, readonly) TGAudioPlayer *audioPlayer;

- (instancetype)initWithFilePath:(NSString *)filePath music:(bool)music controlAudioSession:(bool)controlAudioSession;

- (TGModernViewInlineMediaContext *)inlineMediaContext;

- (void)play;
- (void)play:(float)playbackPosition;
- (void)pause;
- (void)pause:(void (^)())completion;
- (void)stop;

- (float)playbackPosition;
- (float)playbackPositionSync:(bool)sync;
- (NSTimeInterval)absolutePlaybackPosition;
- (NSTimeInterval)duration;
- (bool)isPaused;

@end
