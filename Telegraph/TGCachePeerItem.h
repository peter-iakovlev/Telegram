#import "TGCollectionItem.h"

#import "TGMediaCacheIndexData.h"

@interface TGCachePeerItem : TGCollectionItem

@property (nonatomic, strong, readonly) id peer;
@property (nonatomic, strong, readonly) TGEvaluatedPeerMediaCacheIndexData *evaluatedPeerData;
@property (nonatomic, copy) void (^onSelected)(TGEvaluatedPeerMediaCacheIndexData *);

- (instancetype)initWithPeer:(id)peer evaluatedPeerData:(TGEvaluatedPeerMediaCacheIndexData *)evaluatedPeerData;

@end
