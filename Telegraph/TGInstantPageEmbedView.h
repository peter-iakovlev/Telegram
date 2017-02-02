#import <UIKit/UIKit.h>

#import "TGInstantPageDisplayView.h"
#import "TGEmbedPlayerView.h"

@class TGPIPSourceLocation;

@class TGImageMediaAttachment;

@interface TGInstantPageEmbedView : UIView <TGInstantPageDisplayView, TGEmbedPlayerWrapperView>

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *html;
@property (nonatomic, strong, readonly) TGImageMediaAttachment *posterMedia;
@property (nonatomic, strong, readonly) TGPIPSourceLocation *location;
@property (nonatomic, readonly) bool enableScrolling;

- (void)setOpenEmbedFullscreen:(id (^)(id, id))openEmbedFullscreen;
- (void)setOpenEmbedPIP:(id (^)(id, id, id, TGEmbedPIPCorner, id))openEmbedPIP;

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url html:(NSString *)html posterMedia:(TGImageMediaAttachment *)posterMedia location:(TGPIPSourceLocation *)location enableScrolling:(bool)enableScrolling;

@end
