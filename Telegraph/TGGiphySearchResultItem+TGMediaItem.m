#import "TGGiphySearchResultItem+TGMediaItem.h"

#import "TGStringUtils.h"

@implementation TGGiphySearchResultItem (TGMediaItem)

- (NSString *)uniqueIdentifier
{
    return self.gifId;
}

@end
