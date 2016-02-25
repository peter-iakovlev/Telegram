#import "TGWebSearchInternalGifResult+TGMediaItem.h"

@implementation TGWebSearchInternalGifResult (TGMediaItem)

- (NSString *)uniqueIdentifier
{
    return [NSString stringWithFormat:@"%lld", self.documentId];
}

@end
