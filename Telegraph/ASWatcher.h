/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ASHandle.h"
#import "SGraphNode.h"

@protocol ASWatcher <NSObject>

@required

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@optional

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result;
- (void)actorReportedProgress:(NSString *)path progress:(float)progress;
- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments;
- (void)actionStageActionRequested:(NSString *)action options:(id)options;
- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message;

@end
