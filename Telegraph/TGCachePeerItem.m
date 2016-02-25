#import "TGCachePeerItem.h"

#import "TGCachePeerItemView.h"

@implementation TGCachePeerItem

- (instancetype)initWithPeer:(id)peer evaluatedPeerData:(TGEvaluatedPeerMediaCacheIndexData *)evaluatedPeerData {
    self = [super init];
    if (self != nil) {
        _peer = peer;
        _evaluatedPeerData = evaluatedPeerData;
        self.deselectAutomatically = true;
    }
    return self;
}

- (Class)itemViewClass {
    return [TGCachePeerItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize {
    return CGSizeMake(containerSize.width, 49.0f);
}

- (void)bindView:(TGCachePeerItemView *)view {
    [super bindView:view];
    
    [view setPeer:_peer totalSize:_evaluatedPeerData.totalSize];
}

- (void)itemSelected:(id)__unused actionTarget {
    if (_onSelected) {
        _onSelected(_evaluatedPeerData);
    }
}

@end
