#import "TGMusicPlayerPlaylist.h"

@implementation TGMusicPlayerPlaylist

- (instancetype)initWithItems:(NSArray *)items itemKeyAliases:(NSDictionary *)itemKeyAliases
{
    self = [super init];
    if (self != nil)
    {
        _items = items;
        _itemKeyAliases = itemKeyAliases;
    }
    return self;
}

@end
