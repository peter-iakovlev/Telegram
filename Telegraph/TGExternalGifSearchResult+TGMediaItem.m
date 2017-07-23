#import "TGExternalGifSearchResult+TGMediaItem.h"

#import "TGStringUtils.h"

@implementation TGExternalGifSearchResult (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    return [TGStringUtils stringByEscapingForURL:self.url];
}

@end
