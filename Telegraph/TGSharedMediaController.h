#import "TGViewController.h"

@interface TGSharedMediaController : TGViewController

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash important:(bool)important;

+ (NSArray *)thumbnailColorsForFileName:(NSString *)fileName;

@end
