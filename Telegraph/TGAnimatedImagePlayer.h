/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGRemoteImageView.h"

@class TGAnimatedImagePlayer;

@protocol TGAnimatedImagePlayerDelegate <NSObject>

@optional

- (void)animationFrameReady:(UIImage *)frame;

@end

@interface TGAnimatedImagePlayer : NSObject

@property (nonatomic, weak) id<TGAnimatedImagePlayerDelegate> delegate;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, copy) TGImageProcessor filter;

- (instancetype)initWithDelegate:(id<TGAnimatedImagePlayerDelegate>)delegate path:(NSString *)path;

- (void)play;
- (void)stop;
- (void)pause;

@end
