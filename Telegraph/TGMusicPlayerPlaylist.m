#import "TGMusicPlayerPlaylist.h"

@implementation TGMusicPlayerPlaylist

- (instancetype)initWithVoice:(bool)voice items:(NSArray *)items itemKeyAliases:(NSDictionary *)itemKeyAliases markItemAsViewed:(void (^)(TGMusicPlayerItem *item))markItemAsViewed
{
    self = [super init];
    if (self != nil)
    {
        _voice = voice;
        _items = items;
        _itemKeyAliases = itemKeyAliases;
        _markItemAsViewed = [markItemAsViewed copy];
    }
    return self;
}

@end
