#import <Foundation/Foundation.h>

#import "TGPIPAblePlayerView.h"

@class TGInstantPageMedia;

@protocol TGInstantPageDisplayView <NSObject>

- (void)setIsVisible:(bool)isVisible;

@optional

- (void)setOpenMedia:(void (^)(id))openMedia;
- (void)setOpenEmbedFullscreen:(id (^)(id, id))openEmbedFullscreen;
- (void)setOpenEmbedPIP:(id (^)(id, id, id, TGEmbedPIPCorner, id))openPIP;
- (void)setOpenFeedback:(void (^)())openFeedback;
- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media;
- (void)updateHiddenMedia:(TGInstantPageMedia *)media;

- (void)cancelPIP;
- (void)updateScreenPosition:(CGRect)screenPosition screenSize:(CGSize)screenSize;

@end
