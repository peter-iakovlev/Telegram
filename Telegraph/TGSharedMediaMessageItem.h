#import "TGSharedMediaItem.h"

@class TGMessage;

@interface TGSharedMediaMessageItem : NSObject <TGSharedMediaItem>

- (instancetype)initWithMessage:(TGMessage *)message;

@end
