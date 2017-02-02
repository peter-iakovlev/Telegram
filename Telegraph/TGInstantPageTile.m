#import "TGInstantPageTile.h"

@interface TGInstantPageTile () {
    NSMutableArray<id<TGInstantPageLayoutItem>> *_items;
}

@end

@implementation TGInstantPageTile

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSArray<TGInstantPageTile *> *)tilesWithLayout:(TGInstantPageLayout *)layout boundingWidth:(CGFloat)boundingWidth {
    NSMutableDictionary<NSNumber *, TGInstantPageTile *> *tileByOrigin = [[NSMutableDictionary alloc] init];
    const CGFloat tileHeight = 256.0f;
    
    for (id<TGInstantPageLayoutItem> item in layout.items) {
        if ([item respondsToSelector:@selector(drawInTile)]) {
            int topTileIndex = MAX(0, (int)CGFloor((item.frame.origin.y - 10.0f) / tileHeight));
            int bottomTileIndex = MAX(topTileIndex, (int)CGFloor((item.frame.origin.y + item.frame.size.height + 10.0f) / tileHeight));
            for (int i = topTileIndex; i <= bottomTileIndex; i++) {
                TGInstantPageTile *tile = tileByOrigin[@(i)];
                if (tile == nil) {
                    tile = [[TGInstantPageTile alloc] initWithFrame:CGRectMake(0.0f, i * tileHeight, boundingWidth, tileHeight)];
                    tileByOrigin[@(i)] = tile;
                }
                [tile->_items addObject:item];
            }
        }
    }
    
    NSMutableArray<TGInstantPageTile *> *tiles = [[NSMutableArray alloc] init];
    [tileByOrigin enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageTile *tile, __unused BOOL *stop) {
        [tiles addObject:tile];
    }];
    [tiles sortUsingComparator:^NSComparisonResult(TGInstantPageTile *lhs, TGInstantPageTile *rhs) {
        if (lhs.frame.origin.y < rhs.frame.origin.y) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return tiles;
}

- (void)drawInContext {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, -_frame.origin.x, -_frame.origin.y);
    for (id<TGInstantPageLayoutItem> item in _items) {
        [item drawInTile];
    }
    CGContextTranslateCTM(context, _frame.origin.x, _frame.origin.y);
}

@end
