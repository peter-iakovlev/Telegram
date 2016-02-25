#import "TGInternalGifSearchResult+TGMediaItem.h"

#import "TGStringUtils.h"

@implementation TGInternalGifSearchResult (TGMediaItem)

- (NSString *)uniqueIdentifier
{
    return [TGStringUtils stringByEscapingForURL:self.url];
}

@end
