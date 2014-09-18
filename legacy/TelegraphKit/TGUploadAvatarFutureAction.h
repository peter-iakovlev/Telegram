/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGUploadAvatarFutureActionType ((int)0xFC0408B6)

@interface TGUploadAvatarFutureAction : TGFutureAction

@property (nonatomic, strong) NSString *originalFileUrl;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

- (id)initWithOriginalFileUrl:(NSString *)originalFileUrl latitude:(double)latitude longitude:(double)longitude;

@end
