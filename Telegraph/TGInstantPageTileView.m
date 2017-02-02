#import "TGInstantPageTileView.h"

@interface TGInstantPageTileView () {
    TGInstantPageTile *_tile;
}

@end

@implementation TGInstantPageTileView

- (instancetype)initWithTile:(TGInstantPageTile *)tile {
    self = [super init];
    if (self != nil) {
        _tile = tile;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)drawRect:(CGRect)__unused rect {
    [_tile drawInContext];
}

@end
