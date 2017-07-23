#import "TGWebSearchInternalGifResult+TGMediaItem.h"

@implementation TGWebSearchInternalGifResult (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    return [NSString stringWithFormat:@"%lld", self.documentId];
}

@end
