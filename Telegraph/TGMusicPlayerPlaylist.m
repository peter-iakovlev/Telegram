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

- (bool)hasShuffle
{
    return (_shuffledItems != nil);
}

- (TGMusicPlayerPlaylist *)playlistWithShuffledItems
{
    TGMusicPlayerPlaylist *playlist = [[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:_items itemKeyAliases:_itemKeyAliases markItemAsViewed:[_markItemAsViewed copy]];
    
    NSMutableArray *itemsToShuffle = [_items mutableCopy];
    NSMutableArray *shuffledItems = [[NSMutableArray alloc] init];
    NSUInteger count = itemsToShuffle.count;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        NSUInteger idx = arc4random_uniform((uint32_t)itemsToShuffle.count);
        [shuffledItems addObject:itemsToShuffle[idx]];
        [itemsToShuffle removeObjectAtIndex:idx];
    }
    
    playlist->_shuffledItems = shuffledItems;
    
    return playlist;
}

- (TGMusicPlayerPlaylist *)playlistWithShuffleFromPlaylist:(TGMusicPlayerPlaylist *)previousPlaylist currentItem:(TGMusicPlayerItem *)currentItem
{
    if (![previousPlaylist hasShuffle])
        return [self playlistWithShuffledItems];
    
    TGMusicPlayerPlaylist *playlist = [[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:_items itemKeyAliases:_itemKeyAliases markItemAsViewed:[_markItemAsViewed copy]];
    
    NSMutableArray *itemsToShuffle = [_items mutableCopy];
    NSMutableArray *shuffledItems = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (TGMusicPlayerItem *item in itemsToShuffle)
    {
        if (item.key != nil)
            map[item.key] = item;
    }
    
    for (TGMusicPlayerItem *item in previousPlaylist.shuffledItems)
    {
        TGMusicPlayerItem *newItem = map[item.key];
        if (newItem != nil)
        {
            [shuffledItems addObject:newItem];
            [itemsToShuffle removeObject:newItem];
        }
        
        if (newItem.key == currentItem.key)
            break;
    }
    
    NSUInteger count = itemsToShuffle.count;

    for (NSUInteger i = 0; i < count; i++)
    {
        NSUInteger idx = arc4random_uniform((uint32_t)itemsToShuffle.count);
        [shuffledItems addObject:itemsToShuffle[idx]];
        [itemsToShuffle removeObjectAtIndex:idx];
    }
    
    playlist->_shuffledItems = shuffledItems;
    
    return playlist;
}

@end
