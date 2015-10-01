/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@protocol ASWatcher;

@interface ASHandle : NSObject

@property (nonatomic, weak) id<ASWatcher> delegate;
@property (nonatomic) bool releaseOnMainThread;

- (id)initWithDelegate:(id<ASWatcher>)delegate;
- (id)initWithDelegate:(id<ASWatcher>)delegate releaseOnMainThread:(bool)releaseOnMainThread;
- (void)reset;

- (bool)hasDelegate;

- (void)requestAction:(NSString *)action options:(id)options;
- (void)receiveActorMessage:(NSString *)path messageType:(NSString *)messageType message:(id)message;
- (void)notifyResourceDispatched:(NSString *)path resource:(id)resource;
- (void)notifyResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments;

@end
