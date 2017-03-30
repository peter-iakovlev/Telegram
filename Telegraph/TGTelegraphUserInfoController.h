/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoController.h"

@class TGUserInfoVariantCollectionItem;

@interface TGTelegraphUserInfoController : TGUserInfoController

@property (nonatomic) int32_t uid;

@property (nonatomic, strong) TGCollectionMenuSection *sharedMediaSection;
@property (nonatomic, strong) TGUserInfoVariantCollectionItem *sharedMediaItem;
@property (nonatomic, strong) TGUserInfoVariantCollectionItem *groupsInCommonItem;
@property (nonatomic, copy) void (^shareVCard)();

- (instancetype)initWithUid:(int32_t)uid;
- (instancetype)initWithUid:(int32_t)uid callMessages:(NSArray *)callMessages;
- (instancetype)initWithUid:(int32_t)uid withoutCompose:(bool)withoutCompose;
- (instancetype)initWithUid:(int32_t)uid withoutActions:(bool)withoutActions sharedMediaPeerId:(int64_t)sharedMediaPeerId sharedMediaOptions:(NSDictionary *)sharedMediaOptions;

@end
