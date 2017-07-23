#import "TGInternalGifSearchResult+TGMediaItem.h"

#import "TGStringUtils.h"

@implementation TGInternalGifSearchResult (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    return [TGStringUtils stringByEscapingForURL:self.url];
}

@end
