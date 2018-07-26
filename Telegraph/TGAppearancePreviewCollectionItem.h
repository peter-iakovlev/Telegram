#import "TGCollectionItem.h"

@class TGWallpaperInfo;

@interface TGAppearancePreviewCollectionItem : TGCollectionItem

@property (nonatomic, assign) int32_t fontSize;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, copy) void (^heightChanged)();

- (void)updateWallpaper;
- (void)refreshMetrics;
- (void)reset;

@end
