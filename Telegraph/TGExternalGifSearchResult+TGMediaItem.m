#import "TGExternalGifSearchResult+TGMediaItem.h"

#import <LegacyComponents/LegacyComponents.h>

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
