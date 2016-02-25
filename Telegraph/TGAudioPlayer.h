/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class ASQueue;
@class TGAudioPlayer;

@protocol TGAudioPlayerDelegate <NSObject>

@optional

- (void)audioPlayerDidPause:(TGAudioPlayer *)audioPlayer;
- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer;

@end

@interface TGAudioPlayer : NSObject

@property (nonatomic, weak) id<TGAudioPlayerDelegate> delegate;

+ (TGAudioPlayer *)audioPlayerForPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession;

- (instancetype)init;
- (instancetype)initWithMusic:(bool)music controlAudioSession:(bool)controlAudioSession;

- (void)play;
- (void)playFromPosition:(NSTimeInterval)position;
- (void)pause:(void (^)())completion;
- (void)stop;
- (NSTimeInterval)currentPositionSync:(bool)sync;
- (NSTimeInterval)duration;

+ (ASQueue *)_playerQueue;
- (void)_beginAudioSession;
- (void)_endAudioSession;
- (void)_endAudioSessionFinal;
- (void)_notifyFinished;
- (void)_notifyPaused;

@end
