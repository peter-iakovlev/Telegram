#import <Foundation/Foundation.h>

#import "TGWebPageMediaAttachment.h"
#import "TGInstantPageDisplayView.h"
#import "TGInstantPageLinkSelectionView.h"
#import "TGInstantPageMedia.h"

@class TGPIPSourceLocation;

@protocol TGInstantPageLayoutItem <NSObject>

@property (nonatomic) CGRect frame;

- (bool)hasLinks;
- (NSArray<TGInstantPageMedia *> *)medias;

@optional

- (bool)matchesAnchor:(NSString *)anchor;
- (void)drawInTile;
- (UIView<TGInstantPageDisplayView> *)view;
- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view;
- (bool)matchesEmbedIndex:(int32_t)embedIndex;
- (NSArray<TGInstantPageLinkSelectionView *> *)linkSelectionViews;

- (int32_t)distanceThresholdGroup;
- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *, NSNumber *> *)groupCount;

@end

@interface TGInstantPageLayout : NSObject

@property (nonatomic, readonly) CGPoint origin;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic, strong, readonly) NSArray<id<TGInstantPageLayoutItem> > *items;

- (instancetype)initWithOrigin:(CGPoint)origin contentSize:(CGSize)contentSize items:(NSArray<id<TGInstantPageLayoutItem> > *)items;

+ (TGInstantPageLayout *)makeLayoutForWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId boundingWidth:(CGFloat)boundingWidth;

@end
