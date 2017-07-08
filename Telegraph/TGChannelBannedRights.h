#import <Foundation/Foundation.h>

#import "PSCoding.h"

@class TLChannelBannedRights;

@interface TGChannelBannedRights : NSObject <PSCoding>

@property (nonatomic, readonly) bool banReadMessages;
@property (nonatomic, readonly) bool banSendMessages;
@property (nonatomic, readonly) bool banSendMedia;
@property (nonatomic, readonly) bool banSendStickers;
@property (nonatomic, readonly) bool banSendGifs;
@property (nonatomic, readonly) bool banSendGames;
@property (nonatomic, readonly) bool banSendInline;
@property (nonatomic, readonly) bool banEmbedLinks;
@property (nonatomic, readonly) int32_t timeout;

- (instancetype)initWithBanReadMessages:(bool)banReadMessages banSendMessages:(bool)banSendMessages banSendMedia:(bool)banSendMedia banSendStickers:(bool)banSendStickers banSendGifs:(bool)banSendGifs banSendGames:(bool)banSendGames banSendInline:(bool)banSendInline banEmbedLinks:(bool)banEmbedLinks timeout:(int32_t)timeout;

- (instancetype)initWithTL:(TLChannelBannedRights *)tlRights;

- (TLChannelBannedRights *)tlRights;

- (int32_t)numberOfRestrictions;

@end
