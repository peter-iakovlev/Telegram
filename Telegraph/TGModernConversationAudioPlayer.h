/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGModernConversationAudioPlayer;
@class TGModernViewInlineMediaContext;

@protocol TGModernConversationAudioPlayerDelegate <NSObject>

@optional

- (void)audioPlayerDidFinish;

@end

@interface TGModernConversationAudioPlayer : NSObject

@property (nonatomic, weak) id<TGModernConversationAudioPlayerDelegate> delegate;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (TGModernViewInlineMediaContext *)inlineMediaContext;

- (void)play;
- (void)play:(float)playbackPosition;
- (void)pause;
- (void)stop;

- (float)playbackPosition;
- (float)playbackPositionSync:(bool)sync;
- (NSTimeInterval)duration;
- (bool)isPaused;

@end
