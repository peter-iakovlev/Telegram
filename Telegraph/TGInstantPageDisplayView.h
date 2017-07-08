#import <Foundation/Foundation.h>

#import "TGPIPAblePlayerView.h"

@class TGConversation;
@class TGInstantPageMedia;
@class TGInstantPagePresentation;
@class TGDocumentMediaAttachment;

@protocol TGInstantPageDisplayView <NSObject>

- (void)setIsVisible:(bool)isVisible;

@optional

- (void)setOpenMedia:(void (^)(id))openMedia;
- (void)setOpenAudio:(void (^)(TGDocumentMediaAttachment *))openAudio;
- (void)setOpenEmbedFullscreen:(id (^)(id, id))openEmbedFullscreen;
- (void)setOpenEmbedPIP:(id (^)(id, id, id, TGEmbedPIPCorner, id))openPIP;
- (void)setOpenFeedback:(void (^)())openFeedback;
- (void)setOpenChannel:(void (^)(TGConversation *))openChannel;
- (void)setJoinChannel:(void (^)(TGConversation *))joinChannel;
- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media;
- (void)updateHiddenMedia:(TGInstantPageMedia *)media;

- (void)cancelPIP;
- (void)updateScreenPosition:(CGRect)screenPosition screenSize:(CGSize)screenSize;

- (void)updatePresentation:(TGInstantPagePresentation *)presentation;

@end
