#import "TGGiphySearchResultItem+TGMediaItem.h"

#import "TGStringUtils.h"

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
