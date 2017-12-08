#import "TGGiphySearchResultItem+TGMediaItem.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGGiphySearchResultItem (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    return self.gifId;
}

@end
