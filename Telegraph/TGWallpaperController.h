#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASWatcher.h>

@class TGWallpaperInfo;
@class TGWallpaperController;

@protocol TGWallpaperControllerDelegate <NSObject>

@optional

- (void)wallpaperController:(TGWallpaperController *)wallpaperController didSelectWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo;

@end

@interface TGWallpaperController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, weak) id<TGWallpaperControllerDelegate> delegate;
@property (nonatomic) bool enableWallpaperAdjustment;

- (instancetype)initWithWallpaperInfo:(TGWallpaperInfo *)wallpaperInfo thumbnailImage:(UIImage *)thumbnailImage;

@end
