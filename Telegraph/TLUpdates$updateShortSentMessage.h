#import "TLUpdates.h"

@class TLMessageMedia;

@interface TLUpdates$updateShortSentMessage : TLUpdates

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;
@property (nonatomic) int32_t date;
@property (nonatomic, strong) TLMessageMedia *media;
@property (nonatomic, strong) NSArray *entities;

@end
