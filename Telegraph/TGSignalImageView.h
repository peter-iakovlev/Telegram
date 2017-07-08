#import "TGImageView.h"

#import "TGModernView.h"

#import <SSignalKit/SSignalKit.h>

@class TGModernGalleryVideoView;

@interface TGSignalImageView : TGImageView <TGModernView>

@property (nonatomic) CGRect transitionContentRect;

@property (nonatomic) UIEdgeInsets inlineVideoInsets;
@property (nonatomic) CGSize inlineVideoSize;
@property (nonatomic) CGFloat inlineVideoCornerRadius;

- (void)setVideoPathSignal:(SSignal *)videoPathSignal;
- (void)showVideo;
- (void)hideVideo;

- (void)setVideoView:(TGModernGalleryVideoView *)videoView;

@end
