#import "TGCollectionItemView.h"

@class TGWallpaperInfo;

@interface TGAppearancePreviewCollectionItemView : TGCollectionItemView

@property (nonatomic, readonly) CGFloat contentHeight;

@property (nonatomic, assign) int32_t fontSize;
@property (nonatomic, strong) NSArray *messages;

- (void)updateWallpaper;
- (void)refreshMetrics;
- (void)reset;

@end
