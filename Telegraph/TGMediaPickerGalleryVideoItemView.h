#import "TGModernGalleryItemView.h"
#import "TGModernGalleryEditableItemView.h"
#import "AVFoundation/AVFoundation.h"

@class TGAssetImageView;

@interface TGMediaPickerGalleryVideoItemView : TGModernGalleryItemView <TGModernGalleryEditableItemView>

@property (nonatomic, strong) TGAssetImageView *imageView;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, readonly) bool isPlaying;

@property (nonatomic, readonly) bool hasTrimming;
@property (nonatomic, readonly) CMTimeRange trimRange;

- (void)play;
- (void)stop;

- (void)setPlayButtonHidden:(bool)hidden animated:(bool)animated;
- (void)rotate;

- (void)presentScrubbingPanelAfterReload:(bool)afterReload;
- (void)hideScrubbingPanelAnimated:(bool)animated;

- (UIImage *)screenImage;
- (UIImage *)transitionImage;
- (CGRect)editorTransitionViewRect;

@end
