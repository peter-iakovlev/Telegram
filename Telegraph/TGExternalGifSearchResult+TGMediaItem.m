#import "TGExternalGifSearchResult+TGMediaItem.h"

#import "TGStringUtils.h"

@implementation TGExternalGifSearchResult (TGMediaItem)

- (NSString *)uniqueIdentifier
{
    return [TGStringUtils stringByEscapingForURL:self.url];
}

@end
