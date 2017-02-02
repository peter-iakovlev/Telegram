#import <Foundation/Foundation.h>

#import "TGInstantPageLayout.h"

@interface TGInstantPageTile : NSObject

@property (nonatomic, readonly) CGRect frame;

+ (NSArray<TGInstantPageTile *> *)tilesWithLayout:(TGInstantPageLayout *)layout boundingWidth:(CGFloat)boundingWidth;

- (void)drawInContext;

@end
